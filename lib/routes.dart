/// Names for every screen. Use `Routes.title` etc. instead of typing the
/// path strings by hand, so a typo is caught by the editor.
///
/// This class only holds constants; the private `Routes._()` constructor
/// stops anyone creating an instance of it.
class Routes {
  Routes._();

  static const String title = '/';
  static const String mainMenu = '/menu';
  static const String newGame = '/new-game';
  static const String loadGame = '/load-game';
  static const String leaderboard = '/leaderboard';
  static const String controls = '/controls';
  static const String settings = '/settings';
  static const String saveLoad = '/save-load';
  static const String gameplay = '/gameplay';
  static const String exam = '/exam';
  static const String examResult = '/exam-result';
  static const String progressTracker = '/progress';
  static const String certificate = '/certificate';
}
