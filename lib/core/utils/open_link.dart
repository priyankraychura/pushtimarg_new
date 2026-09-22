import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'context_extensions.dart';

/// Opens [url] in the browser, telling the user when it cannot be opened
/// instead of failing silently.
Future<void> openLink(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) context.showSnack("Couldn't open the link. Try again later.");
}
