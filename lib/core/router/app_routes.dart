/// Route paths and names in one place.
abstract final class AppRoutes {
  static const signIn = '/sign-in';

  // Shell tabs
  static const home = '/home';
  static const bhajans = '/bhajans';
  static const favourites = '/favourites';
  static const settings = '/settings';

  // Pushed screens
  static const calendar = '/calendar';
  static const search = '/search';
  static const lyrics = '/lyrics/:id';
  static String lyricsFor(String id) => '/lyrics/$id';
}
