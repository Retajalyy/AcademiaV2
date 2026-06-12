import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the file in the system's native in-app browser
/// (Chrome Custom Tabs on Android / SFSafariViewController on iOS).
/// No extra platform setup required.
Future<void> openFilePreview({
  required String fileUrl,
  required String fileName,
  required String fileType,
}) async {
  if (fileUrl.isEmpty) return;

  final type = fileType.toLowerCase();
  // DOCX/PPT go through Google Docs Viewer; PDFs open directly
  final viewUrl = (type == 'pdf')
      ? fileUrl
      : 'https://docs.google.com/viewer?url=${Uri.encodeComponent(fileUrl)}';

  final uri = Uri.parse(viewUrl);
  try {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } catch (_) {
    Get.snackbar('Error', 'Could not open file',
        snackPosition: SnackPosition.BOTTOM);
  }
}
