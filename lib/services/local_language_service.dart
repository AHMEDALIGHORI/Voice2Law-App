import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import '../core/app_config.dart';

class LocalLanguageException implements Exception {
  const LocalLanguageException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The separate LAN client never calls a cloud provider or sends admin tokens.
class LocalLanguageService {
  LocalLanguageService(this.config, {http.Client? client})
    : _client = client ?? http.Client();
  final AppConfig config;
  http.Client _client;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _audio;
  Timer? _limit;
  final BytesBuilder _pcm = BytesBuilder(copy: true);
  int _epoch = 0;
  bool _recording = false;

  static String validateUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    final parts = uri?.host.split('.').map(int.tryParse).toList();
    final ipv4 = parts != null && parts.length == 4 &&
        parts.every((p) => p != null && p >= 0 && p <= 255);
    final private = ipv4 && (parts[0] == 10 || parts[0] == 127 ||
        (parts[0] == 192 && parts[1] == 168) ||
        (parts[0] == 172 && parts[1]! >= 16 && parts[1]! <= 31));
    if (uri == null || !private || !['http', 'https'].contains(uri.scheme) ||
        uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw const FormatException('Use your PC’s private IPv4 address, for example http://192.168.1.20:8765.');
    }
    return uri.toString().replaceFirst(RegExp(r'/$'), '');
  }

  Future<Map<String, dynamic>> _request(String path, {Map<String, dynamic>? data,
    String? url, String? key, Duration timeout = const Duration(minutes: 3)}) async {
    if (url == null && !config.localLanguagesEnabled) {
      throw const LocalLanguageException('Enable Free local languages in Preferences first.');
    }
    final address = validateUrl(url ?? config.localLanguageUrl);
    final secret = key ?? config.localLanguageKey;
    if (secret.trim().length < 16) {
      throw const LocalLanguageException('Enter the pairing key shown on your PC.');
    }
    final epoch = _epoch;
    final request = http.Request(data == null ? 'GET' : 'POST', Uri.parse('$address$path'))
      ..followRedirects = false
      ..headers.addAll({'Authorization': 'Bearer $secret', 'Content-Type': 'application/json'});
    if (data != null) request.body = jsonEncode(data);
    try {
      final response = await (() async => http.Response.fromStream(await _client.send(request)))().timeout(timeout);
      if (epoch != _epoch) throw const LocalLanguageException('Request cancelled.');
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      if (response.statusCode != 200) {
        throw LocalLanguageException(decoded['error']?.toString() ?? 'PC request failed.');
      }
      return decoded;
    } on LocalLanguageException { rethrow; }
    on TimeoutException {
      throw const LocalLanguageException('The PC took too long. Wait for its current task to finish, then retry.');
    } catch (_) {
      throw const LocalLanguageException('Cannot reach the language service. Keep your PC running on the same Wi-Fi; check its address, pairing key and Private-network firewall access.');
    }
  }

  Future<Map<String, dynamic>> check({String? url, String? key}) async {
    final result = await _request('/health', url: url, key: key, timeout: const Duration(seconds: 8));
    if (result['service'] != 'voice2law-local' || result['version'] != 1) {
      throw const LocalLanguageException('This is not a compatible Voice2Law language service.');
    }
    return result;
  }

  Future<String> translate(String text, {required String source, required String target}) async {
    final result = await _request('/translate', data: {'text': text, 'source': source, 'target': target});
    final translated = result['text'];
    if (translated is! String || translated.trim().isEmpty) {
      throw const LocalLanguageException('The PC returned an empty translation.');
    }
    return translated;
  }

  Future<String> transcribe(Uint8List wav, String language) async {
    final result = await _request('/transcribe', data: {'audio': base64Encode(wav), 'language': language});
    final text = result['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const LocalLanguageException('No clear speech found. Please record again.');
    }
    return text;
  }

  Future<void> startRecording({required void Function() onLimit}) async {
    final epoch = _epoch;
    _recorder ??= AudioRecorder();
    if (!await _recorder!.hasPermission()) {
      throw const LocalLanguageException('Allow microphone access in your phone’s app settings.');
    }
    if (epoch != _epoch) return;
    _pcm.clear();
    final stream = await _recorder!.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1,
    ));
    if (epoch != _epoch) { await _recorder!.cancel(); return; }
    _recording = true;
    _audio = stream.listen((bytes) {
      if (!_recording) return;
      // Hard memory bound independent of timer delivery.
      final remaining = 16000 * 2 * 60 - _pcm.length;
      if (remaining > 0) _pcm.add(bytes.length <= remaining ? bytes : bytes.sublist(0, remaining));
    });
    _limit = Timer(const Duration(seconds: 59), onLimit);
  }

  Future<Uint8List> stopRecording() async {
    _limit?.cancel();
    await _recorder?.stop();
    _recording = false;
    await _audio?.cancel();
    _audio = null;
    final bytes = _pcm.takeBytes();
    if (bytes.length < 8000) throw const LocalLanguageException('Record at least a quarter of a second.');
    return wavFromPcm(bytes);
  }

  static Uint8List wavFromPcm(Uint8List pcm) {
    final result = Uint8List(44 + pcm.length);
    final header = ByteData.sublistView(result);
    void label(int offset, String text) => result.setRange(offset, offset + text.length, ascii.encode(text));
    label(0, 'RIFF'); header.setUint32(4, 36 + pcm.length, Endian.little);
    label(8, 'WAVE'); label(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little); header.setUint32(24, 16000, Endian.little);
    header.setUint32(28, 32000, Endian.little); header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little); label(36, 'data');
    header.setUint32(40, pcm.length, Endian.little); result.setRange(44, result.length, pcm);
    return result;
  }

  Future<void> cancelPending() async {
    _epoch++;
    _client.close(); _client = http.Client();
    _limit?.cancel(); _recording = false;
    await _audio?.cancel(); _audio = null; _pcm.clear();
    await _recorder?.cancel();
  }
}
