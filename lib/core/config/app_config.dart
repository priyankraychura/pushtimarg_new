/// App-wide runtime configuration.
///
/// [demoMode] is switched on automatically when Firebase has not been
/// configured yet (see `main.dart`), so the app runs with bundled sample data
/// and an in-memory auth stub until `flutterfire configure` has been run.
abstract final class AppConfig {
  static const String appName = 'Pushti Kirtan';
  static const String version = '0.1.0';

  /// Published privacy policy, linked from the sign-in screen and Settings.
  static const String privacyPolicyUrl =
      'https://priyank-raychura.vercel.app/privacy-policy/pushtimarg';

  static bool demoMode = false;

  /// Accounts that get the Firestore seeding tools in Settings on a release
  /// build, not just in debug. Lower-case; compared against the signed-in
  /// email lower-cased.
  ///
  /// This only decides whether the buttons are drawn. It is not a security
  /// boundary — what an account may actually write to Firestore is decided by
  /// the Firestore security rules, and has to be enforced there.
  static const Set<String> maintainerEmails = {'priyankraychura@gmail.com'};

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
