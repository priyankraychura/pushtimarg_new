import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'features/settings/providers/settings_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);


  await _initFirebase();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PushtiKirtanApp(),
    ),
  );
}

/// Starts Firebase if `firebase_options.dart` has been generated; otherwise
/// falls back to demo mode (sample data + in-memory auth) so the app still runs.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppConfig.demoMode = false;
  } catch (e) {
    AppConfig.demoMode = true;
    debugPrint('Firebase not configured — running in demo mode. ($e)');
  }
}
