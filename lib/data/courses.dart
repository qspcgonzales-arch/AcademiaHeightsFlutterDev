import '../models/course.dart';

/// Stable id for the single academic track. Used in save files and
/// [Exam]/[ExamAttempt] records.
const String trackCourseId = 'ite013';

/// Academia Heights is one academic track: the player passes the Prelim,
/// Midterm, and Finals — each covering every module — to graduate. The
/// [Course] model and this list are kept so the progress tracker and
/// save/leaderboard code can stay generic if more tracks are added later.
const List<Course> courses = [
  Course(
    id: trackCourseId,
    title: 'ITE 013 — Application Development & Emerging Technologies',
    instructorName: 'the Instructor',
    blurb:
        'Flutter & Dart, app planning, variables/loops/arrays, '
        'Human-Computer Interaction, Arduino, and web & mobile development.',
  ),
];

Course courseById(String id) => courses.firstWhere((c) => c.id == id);

/// The single track (convenience for call sites that never need the list).
Course get track => courses.first;
