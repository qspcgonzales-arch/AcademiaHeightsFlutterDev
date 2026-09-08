/// A course the player works through. Courses are unlocked in list order;
/// each is finished by passing its Prelim, Midterm, and Finals.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.blurb,
  });

  /// Stable key used in save files and question-bank lookups. Never rename
  /// an existing id without a save-file migration.
  final String id;

  final String title;
  final String instructorName;
  final String blurb;
}
