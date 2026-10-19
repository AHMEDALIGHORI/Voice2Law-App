import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_scope.dart';
import '../core/language_helper.dart';
import '../services/ai_features_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/legal_ux_components.dart';

/// Snap & Explain — upload a photo of a legal document (FIR, notice,
/// contract, court order) and get a plain-language English + Urdu
/// explanation powered by Voice2Law's AI.
///
/// On Flutter web, `ImagePicker` picks from the file system. On Android /
/// iOS it opens the camera or gallery.
class DocumentExplainerScreen extends StatefulWidget {
  const DocumentExplainerScreen({super.key});

  @override
  State<DocumentExplainerScreen> createState() =>
      _DocumentExplainerScreenState();
}

class _DocumentExplainerScreenState extends State<DocumentExplainerScreen> {
  final TextEditingController _textController = TextEditingController();
  AiFeaturesService? _ai;

  Uint8List? _imageBytes;
  String? _imagePath;
  String _imageMime = 'image/jpeg';
  bool _isProcessing = false;
  AiFeatureResult? _result;
  String? _error;

  bool get _hasImage => _imageBytes != null || _imagePath != null;

  /// Sniffs the image format from its magic bytes. `XFile.mimeType` is not
  /// always populated on every platform, and Gemini needs a correct MIME type.
  String _detectMime(Uint8List bytes) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ai == null) {
      final AppServices services = AppScope.of(context);
      _ai = services.aiFeatures;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file == null) return;
      if (!mounted) return;

      // Read bytes so we can preview and send the image to the vision model.
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = file.path;
        _imageMime = (file.mimeType ?? _detectMime(bytes));
        _error = null;
        _result = null;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = 'Could not load image: $err');
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imagePath = null;
      _error = null;
      _result = null;
    });
  }

  Future<void> _explainDocument() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _imageBytes == null) {
      setState(
        () => _error =
            'Add a photo of the document, or paste its text, and try again.',
      );
      return;
    }
    if (_ai == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
      _result = null;
    });

    try {
      final AiFeatureResult res;
      if (_imageBytes != null) {
        // Let the vision model read the document directly. Typed text, when
        // present, is added only as context (useful for blurry photos).
        res = await _ai!.explainDocumentImage(
          _imageBytes!,
          mimeType: _imageMime,
          extraContext: text.isEmpty
              ? ''
              : 'The user also typed this text from the document: $text',
        );
      } else {
        res = await _ai!.explainDocument(text);
      }
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _result = res;
        if (!res.success) _error = res.content;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = 'AI explanation failed: $err';
      });
    }
  }

  Future<void> _copyResult() async {
    if (_result == null) return;
    await Clipboard.setData(ClipboardData(text: _result!.content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Explanation copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = LanguageHelper.isRtl(
      LanguageHelper.resolve(AppScope.of(context).config.languagePreference),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Snap & Explain',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Photo or text → plain language',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.gold),
            ),
          ],
        ),
        actions: <Widget>[
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: LanguageSwitcherChip(
              current: AppScope.of(context).config.languagePreference,
              light: true,
              onChanged: (String lang) async {
                await AppScope.of(
                  context,
                ).config.update(languagePreference: lang);
                if (mounted) setState(() {});
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How to use',
            onPressed: () =>
                showDialog(context: context, builder: (_) => _howToUseDialog()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Cloud status banner
            _cloudStatusBanner(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  // ── Step 1: Pick image ──
                  const Text(
                    'Step 1 — Add document',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: BrandButton(
                          label: _hasImage ? 'Change image' : 'Choose photo',
                          icon: Icons.photo_library_outlined,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BrandButton(
                          label: 'Camera',
                          icon: Icons.camera_alt_outlined,
                          onPressed: () => _pickImage(ImageSource.camera),
                          color: AppColors.darkGreen.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_hasImage) ...<Widget>[
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : const Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: AppColors.textSecondary,
                                  ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Photo attached',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    _hasImage
                        ? 'Step 2 — Optional: add text for a sharper answer'
                        : 'Step 2 — Or paste the document text',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hasImage
                        ? 'The AI reads the photo directly. Typing a few key '
                              'lines helps when the photo is blurry.'
                        : 'No photo? Paste the text and Voice2Law will still '
                              'explain it.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    minLines: 4,
                    maxLines: 8,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _hasImage
                          ? 'Optional: type or paste any text you can read...'
                          : 'Paste the FIR, notice, contract or court order text here...',
                      border: const OutlineInputBorder(),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _textController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  if (_hasImage) ...<Widget>[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.privacy_tip_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'The photo is sent to the selected AI provider '
                            'only when you tap Explain. Voice2Law does not '
                            'store it.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // ── Step 3: Explain ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BrandButton(
                      label: _isProcessing
                          ? 'Analyzing...'
                          : (_hasImage
                                ? 'Explain this photo'
                                : 'Explain document'),
                      icon: Icons.psychology_outlined,
                      onPressed: _isProcessing ? null : _explainDocument,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13.5,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_result != null) ...<Widget>[
                    const Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.deepPurple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Explanation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.deepPurple.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                      ),
                      child: Directionality(
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          _result!.content,
                          style: TextStyle(
                            fontSize: 14.5,
                            height:
                                LanguageHelper.isRtl(
                                  LanguageHelper.resolve(
                                    AppScope.of(
                                      context,
                                    ).config.languagePreference,
                                  ),
                                )
                                ? 2.0
                                : 1.7,
                            fontFamily: LanguageHelper.metaFor(
                              LanguageHelper.resolve(
                                AppScope.of(context).config.languagePreference,
                              ),
                            ).fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_result!.offline)
                      const OfflineBanner(isUrdu: false, statusCode: null),
                    const SizedBox(height: 10),
                    BrandButton(
                      label: 'Copy explanation',
                      icon: Icons.content_copy,
                      onPressed: _copyResult,
                      color: AppColors.deepPurple.withValues(alpha: 0.85),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cloudStatusBanner(BuildContext context) {
    final config = AppScope.of(context).config;
    final bool visionReady =
        config.cloudEnabled && config.selectedAiProvider == 'gemini';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: config.cloudEnabled
            ? AppColors.emerald.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: config.cloudEnabled
                ? AppColors.emerald.withValues(alpha: 0.3)
                : AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            config.cloudEnabled ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: config.cloudEnabled ? AppColors.emerald : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !config.cloudEnabled
                  ? 'Cloud AI off — paste text for offline answers, or enable '
                        'AI in Settings.'
                  : (visionReady
                        ? 'Cloud AI active — photo and text explanation ready'
                        : 'Cloud AI active — photo reading needs Gemini; text '
                              'works with your current provider.'),
              style: TextStyle(
                fontSize: 11.5,
                color: config.cloudEnabled
                    ? AppColors.emeraldText
                    : const Color(0xFF9A4708),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Dialog _howToUseDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'How to use Snap & Explain',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 14),
            _step(
              '1.',
              'Take a clear photo or pick an image of the legal document '
                  '(FIR, notice, contract, court order).',
            ),
            _step(
              '2.',
              'Optional: type a few key lines if the photo is blurry. The AI '
                  'reads the image directly — no typing needed.',
            ),
            _step(
              '3.',
              'Tap “Explain this photo” — Voice2Law AI tells you what it '
                  'means, the key dates, your obligations, and what to do next.',
            ),
            _step(
              '4.',
              'Read the answer in English or Urdu, then copy it if needed.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '⚠️ This is general legal information, not legal advice. Verify with a licensed lawyer before taking action.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
