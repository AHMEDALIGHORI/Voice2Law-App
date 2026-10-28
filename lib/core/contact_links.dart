/// Builds launchable contact URIs from untrusted directory/server data.
///
/// Values are normalised instead of interpolated into a URI string, so a
/// malicious phone number or address cannot append extra URI parameters
/// (`tel:123;`, `mailto:a@b.c?bcc=…`) or a `javascript:`/`intent:` payload.
class ContactLinks {
  const ContactLinks._();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns a `tel:` URI, or null when [raw] is not a usable number.
  static Uri? tel(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.replaceAll('+', '').length < 7) return null;
    return Uri(scheme: 'tel', path: digits);
  }

  /// Returns a `https://wa.me/…` URI, or null when [raw] is not usable.
  static Uri? whatsapp(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) return null;
    return Uri.https('wa.me', '/$digits');
  }

  /// Returns a `mailto:` URI, or null when [raw] is not a usable address.
  static Uri? mailto(String raw) {
    final String email = raw.trim();
    if (!_email.hasMatch(email)) return null;
    return Uri(scheme: 'mailto', path: email);
  }
}
