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
  static const varta = '/varta';
  static const vartaList = '/varta/:collection';
  static String vartaListFor(String collection) => '/varta/$collection';
  static const vartaRead = '/varta/:collection/:id';
  static String vartaReadFor(String collection, String id) => '/varta/$collection/$id';
  static const lyrics = '/lyrics/:id';
  static String lyricsFor(String id) => '/lyrics/$id';
}
