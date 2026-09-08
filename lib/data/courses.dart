import '../models/course.dart';

/// Id for the single academic track. Stored in save files and exam records.
const String trackCourseId = 'ite013';

/// Academia Heights is one academic track: pass the Prelim, Midterm, and
/// Finals (each covering every module) to graduate. The [Course] model and
/// this list stay generic so more tracks could be added later, but today
/// there is exactly one.
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

/// The single track. Use this instead of writing `courses[0]` everywhere.
Course get track => courses[0];
