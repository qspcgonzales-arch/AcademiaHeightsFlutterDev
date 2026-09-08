// Academia Heights - Quiz question data.
//
// The full bank, mirrored in docs/quiz_bank.md. One shared set of exams
// across every module; difficulty rises Prelim -> Midterm -> Finals.
// Uses the project Question model (lib/models/question.dart).

import '../models/question.dart';

// ---------------------------------------------------------------------
// PRELIM — 10 questions (foundational: Flutter basics, Arduino intro, HCI intro)
// ---------------------------------------------------------------------
const List<Question> prelimQuestions = [
  Question(
    prompt: "What is Flutter?",
    choices: [
      "A database management system",
      "An open-source UI toolkit by Google for building cross-platform apps",
      "A web hosting service",
      "An operating system",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which of the following is a system requirement to run Flutter?",
    choices: [
      "A game console",
      "A computer with enough disk space and a supported OS (Windows/macOS/Linux)",
      "A physical Android phone only",
      "A dedicated GPU",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What command checks if Flutter is installed correctly?",
    choices: ["flutter check", "flutter doctor", "flutter verify", "flutter status"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What type of applications can Flutter build?",
    choices: [
      "Only Android apps",
      "Only websites",
      "Mobile, web, and desktop apps from one codebase",
      "Only games",
    ],
    correctIndex: 2,
  ),
  Question(
    prompt: "What programming language does Flutter use?",
    choices: ["Java", "Swift", "Dart", "Kotlin"],
    correctIndex: 2,
  ),
  Question(
    prompt: "What is Arduino?",
    choices: [
      "A programming language only",
      "An open-source electronics platform with programmable boards",
      "A mobile operating system",
      "A web browser",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What software is commonly used to write and upload Arduino code?",
    choices: ["Android Studio", "Arduino IDE", "Xcode", "Visual Studio"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What does Human-Computer Interaction (HCI) mainly study?",
    choices: [
      "How computers talk to each other",
      "How people interact with computers and interfaces",
      "How to build computer hardware",
      "How to write operating systems",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the main difference between UI and UX?",
    choices: [
      "They mean the same thing",
      "UI is the look of the interface; UX is the overall experience of using it",
      "UI is for mobile, UX is for web",
      "UX is only about colors",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What does WWW stand for?",
    choices: ["World Wide Web", "World Web Wiring", "Wide World Web", "World Wide Wireless"],
    correctIndex: 0,
  ),
];

// ---------------------------------------------------------------------
// MIDTERM — 15 questions (mid-level: architecture/Dart, loops/arrays, HCI)
// ---------------------------------------------------------------------
const List<Question> midtermQuestions = [
  Question(
    prompt: "In Flutter's architecture, what is the basic building block of the UI?",
    choices: ["A page", "A widget", "A controller", "A module"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What best describes Flutter's \"everything is a widget\" idea?",
    choices: [
      "Only buttons are widgets",
      "Layout, styling, and UI elements are all built by composing widgets",
      "Widgets are only used for animations",
      "Widgets replace the need for Dart code",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is \"null safety\" in Dart used for?",
    choices: [
      "Making apps run faster",
      "Preventing errors caused by unexpected null values",
      "Reducing app size",
      "Improving image rendering",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the main purpose of Tinkercad for Arduino?",
    choices: [
      "Writing mobile apps",
      "Simulating Arduino circuits online without physical hardware",
      "Hosting websites",
      "Designing UI mockups",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "The Arduino programming language is based on which languages?",
    choices: ["Python and Java", "C and C++", "Dart and Kotlin", "JavaScript and PHP"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is a \"for loop\" typically used for?",
    choices: [
      "Declaring variables",
      "Repeating a block of code a set number of times",
      "Storing multiple values",
      "Displaying text on an LCD",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the key difference between a while loop and a do-while loop?",
    choices: [
      "There is no difference",
      "A do-while loop runs its code at least once before checking the condition",
      "A while loop can only run once",
      "A do-while loop cannot use conditions",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is an array?",
    choices: [
      "A single value that never changes",
      "A collection of values stored under one variable name, accessed by index",
      "A type of loop",
      "A function that returns text",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What library is commonly used to control an Arduino LCD display?",
    choices: ["Serial.h", "LiquidCrystal", "Wire.h", "Stepper.h"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What does \"usability\" mean in HCI?",
    choices: [
      "How expensive a system is",
      "How easy and efficient a system is for people to use",
      "How many features a system has",
      "How fast a system loads",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which of these is one of the 6 Design Principles discussed in HCI?",
    choices: ["Randomness", "Feedback (letting the user know an action happened)", "Complexity", "Ambiguity"],
    correctIndex: 1,
  ),
  Question(
    prompt: "Why is \"consistency\" important as a design principle?",
    choices: [
      "It makes every screen look different",
      "It helps users predict how the interface will behave across the app",
      "It only matters for animations",
      "It slows down development",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the difference between HTTP and HTTPS?",
    choices: [
      "They are exactly the same",
      "HTTPS is the secure, encrypted version of HTTP",
      "HTTP is only for images",
      "HTTPS is older than HTTP",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "In web development, what do \"frontend\" and \"backend\" refer to?",
    choices: [
      "Frontend is the server, backend is the browser",
      "Frontend is what users see/interact with; backend handles data and server logic",
      "They both mean the same part of a website",
      "Frontend refers to mobile only",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the main difference between native and cross-platform mobile development?",
    choices: [
      "Native apps don't need code",
      "Native apps are built for one platform (e.g., Android only); cross-platform apps run on multiple platforms from one codebase",
      "Cross-platform apps only work offline",
      "There is no real difference",
    ],
    correctIndex: 1,
  ),
];

// ---------------------------------------------------------------------
// FINALS — 20 questions (harder / integration: usability metrics, design
// thinking, full Web & Mobile Development module, cross-topic synthesis)
// ---------------------------------------------------------------------
const List<Question> finalsQuestions = [
  Question(
    prompt: "What rendering technology does Flutter use to draw its UI?",
    choices: [
      "The device's native UI components only",
      "Its own rendering engine (e.g., Skia/Impeller), drawn pixel-by-pixel",
      "HTML and CSS",
      "A third-party browser engine",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the purpose of async/await in Dart?",
    choices: [
      "To make code run in a strict straight line only",
      "To handle operations that take time (like loading data) without freezing the app",
      "To declare variables",
      "To style widgets",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "In most programming languages, how are array indexes typically counted?",
    choices: ["Starting from 1", "Starting from 0", "Starting from -1", "Arrays don't use indexes"],
    correctIndex: 1,
  ),
  Question(
    prompt: "When wiring an LCD to a microcontroller, why does pin configuration matter?",
    choices: [
      "It doesn't matter as long as it's plugged in",
      "The code must match the actual pins used, or the display won't work correctly",
      "LCDs don't use pins",
      "Pin configuration only affects color",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the main idea behind \"Design is not Easy\" in HCI?",
    choices: [
      "Good design has no trade-offs",
      "Designers must balance competing needs (simplicity, functionality, usability) and iterate",
      "Design should never change once started",
      "Only programmers should make design decisions",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which usability metric measures how quickly users can complete a task?",
    choices: ["Satisfaction", "Efficiency", "Error rate", "Learnability only"],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which usability metric tracks how often users make mistakes while using a system?",
    choices: ["Efficiency", "Error rate", "Satisfaction", "Aesthetics"],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which usability metric measures how happy users are with a system?",
    choices: ["Error rate", "Satisfaction", "Efficiency", "Speed"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What is the correct general order of the Design Thinking stages?",
    choices: [
      "Test, Prototype, Define, Empathize, Ideate",
      "Empathize, Define, Ideate, Prototype, Test",
      "Ideate, Empathize, Test, Define, Prototype",
      "Define, Test, Empathize, Prototype, Ideate",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which of the following is an example of a Content Management System (CMS)?",
    choices: ["Arduino IDE", "WordPress", "Android Studio", "Flutter"],
    correctIndex: 1,
  ),
  Question(
    prompt: "What does \"web hosting\" provide?",
    choices: [
      "A programming language",
      "Server space where a website's files are stored so it can be accessed online",
      "A mobile app store",
      "A design principle",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which of these is a real trend in mobile technology?",
    choices: [
      "Removing all buttons from phones",
      "Foldable screens and 5G connectivity",
      "Phones without operating systems",
      "Mobile apps that don't need testing",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "\"Fragmentation\" is a common mobile development challenge because:",
    choices: [
      "Every phone runs the exact same software",
      "Devices vary widely in screen size, OS version, and hardware",
      "Mobile apps can't be updated",
      "There is only one phone manufacturer",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Flutter is best described as which mobile development approach?",
    choices: ["Purely native (per platform)", "Cross-platform (one codebase, multiple platforms)", "Web-only", "Hardware-only"],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which of the following is a correct step when building a mobile app?",
    choices: [
      "Skip planning and go straight to publishing",
      "Plan, design, develop, test, then deploy",
      "Testing is optional if the app looks good",
      "Deployment always comes before development",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Why is Dart a good fit for Flutter specifically?",
    choices: [
      "Dart cannot compile to native code",
      "Dart compiles efficiently and integrates tightly with Flutter's widget/rendering system",
      "Dart is only used for backend servers",
      "Dart doesn't support object-oriented programming",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Why does usability matter especially in mobile app design?",
    choices: [
      "Mobile screens are large, so usability doesn't matter",
      "Small screens and touch input make poor usability more noticeable and frustrating",
      "Usability only matters on desktop",
      "Mobile users never make mistakes",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What happens when you combine a loop with an array in code?",
    choices: [
      "Nothing, they can't be used together",
      "The loop can process or access each value in the array one at a time",
      "It deletes the array",
      "It only works with Arduino, not other languages",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "What does \"deploying\" a mobile app typically mean?",
    choices: [
      "Deleting the app from a device",
      "Publishing the finished app so users can download and install it (e.g., to an app store)",
      "Writing the first line of code",
      "Designing the app icon only",
    ],
    correctIndex: 1,
  ),
  Question(
    prompt: "Which best describes the \"hybrid\" approach to mobile development?",
    choices: [
      "Building two completely separate native apps",
      "Using web technologies wrapped in a native container to run on multiple platforms",
      "Only building for the web, never mobile",
      "Avoiding all code and using drag-and-drop only",
    ],
    correctIndex: 1,
  ),
];
