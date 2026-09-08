import '../models/course.dart';

/// The courses the player works through, in unlock order. Course topics are
/// the ITE 013 modules themselves; ids are stable keys used in save files
/// and question-bank lookups (see `question_bank.dart`).
const List<Course> courses = [
  Course(
    id: 'flutter_intro',
    title: 'Introduction to Flutter',
    instructorName: 'Prof. Widget',
    blurb:
        'What Flutter is, the install steps, system requirements, project '
        'structure, and the Dart language.',
  ),
  Course(
    id: 'emerging_tech',
    title: 'Emerging Technologies',
    instructorName: 'Prof. Vega',
    blurb:
        'Planning an app before building it: what to consider and how to '
        'organize the work.',
  ),
  Course(
    id: 'vla',
    title: 'Variables, Loops, and Arrays',
    instructorName: 'Prof. Loop',
    blurb:
        'Variables for state, loops for the update-and-render cycle, and '
        'arrays (Dart lists) for game data.',
  ),
  Course(
    id: 'hci',
    title: 'Human-Computer Interaction',
    instructorName: 'Prof. Norman',
    blurb: 'Usability and design principles applied to on-screen interfaces.',
  ),
  Course(
    id: 'arduino_ai',
    title: 'Introduction to Arduino & AI',
    instructorName: 'Prof. Turing',
    blurb:
        'Microcontroller basics and core ideas behind artificial '
        'intelligence.',
  ),
];

Course courseById(String id) => courses.firstWhere((c) => c.id == id);
