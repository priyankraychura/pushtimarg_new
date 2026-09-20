/// App-wide runtime configuration.
///
/// [demoMode] is switched on automatically when Firebase has not been
/// configured yet (see `main.dart`), so the app runs with bundled sample data
/// and an in-memory auth stub until `flutterfire configure` has been run.
abstract final class AppConfig {
  static const String appName = 'Pushti Kirtan';
  static const String version = '0.1.0';

  static bool demoMode = false;

  /// Default seva schedule (24h). Editable in Settings.
  static const Map<String, String> defaultSevaTimes = {
    'Mangala': '05:30',
    'Shringar': '07:00',
    'Gwal': '08:45',
    'Rajbhog': '11:30',
    'Utthapan': '15:30',
    'Bhog': '16:30',
    'Sandhya Aarti': '18:00',
    'Shayan': '20:00',
  };
}
