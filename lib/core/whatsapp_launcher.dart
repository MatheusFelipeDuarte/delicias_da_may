import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncher {
  static Future<bool> open(String rawPhone, {String? message}) async {
    String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (!digits.startsWith('55')) digits = '55$digits';
    final text = Uri.encodeComponent(message ?? '');
    final waApp = Uri.parse('whatsapp://send?phone=$digits&text=$text');
    final waWeb = Uri.parse('https://api.whatsapp.com/send?phone=$digits&text=$text');
    if (await canLaunchUrl(waApp)) {
      return launchUrl(waApp, mode: LaunchMode.externalApplication);
    }
    if (await canLaunchUrl(waWeb)) {
      return launchUrl(waWeb, mode: LaunchMode.externalApplication);
    }
    // Extra fallback: wa.me
    final waMe = Uri.parse('https://wa.me/$digits?text=$text');
    if (await canLaunchUrl(waMe)) {
      return launchUrl(waMe, mode: LaunchMode.externalApplication);
    }
    // Nothing handled. Let caller show an error instead of opening the store.
    return false;
  }
}
