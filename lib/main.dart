// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:first/accessibility_settings.dart';
import 'package:first/secondPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class TTSService {
  FlutterTts flutterTts = FlutterTts();

  Future speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccessibilitySettings(),
      child: MyApp(cameras: cameras),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});
  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilitySettings>(
      builder: (context, settings, child) {
        final ThemeData customDarkTheme = ThemeData(
          primaryColor:
              const Color(0xff00061c), // Your specific color for dark theme
          brightness: Brightness.dark,
          scaffoldBackgroundColor:
              const Color(0xff00061c), // Ensures the overall theme is dark
          // Customize other aspects of the dark theme as needed
        );

        final ThemeData generalDarkTheme = ThemeData(
            brightness: Brightness.light,
            textTheme: const TextTheme(
                // bodyText1: TextStyle(color: Colors.black),
                // bodyText2: TextStyle(color: Colors.black),
                )
            // Ensures the overall theme is dark
            // You can customize this theme as well if needed
            );

        return MaterialApp(
          // Apply the theme based on the highContrastEnabled setting
          theme:
              settings.highContrastEnabled ? generalDarkTheme : customDarkTheme,
          home: MyHomePage(title: 'Flutter Demo Home Page', cameras: cameras),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MyHomePage({super.key, required this.title, required this.cameras});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SecondPage(cameras: widget.cameras)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer<AccessibilitySettings>(builder: (context, settings, child) {
        return Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.09,
                      top: MediaQuery.of(context).size.height * 0.135),
                  child: Image.asset(
                    "images/My-Seeing-Eye-Icon-Logo.png",
                    fit: BoxFit.contain,
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.001,
            ),
            Center(
              child: Text(
                "My Seeing Eye",
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: MediaQuery.of(context).size.width *
                        0.1 *
                        settings.fontSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              // Use Expanded widget here
              child: Align(
                // Align widget aligns its child within itself and optionally sizes itself based on the child's size.
                alignment: Alignment
                    .bottomCenter, // Align the image at the bottom center
                child: Image.asset(
                  "images/my-seen-eye-image.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
