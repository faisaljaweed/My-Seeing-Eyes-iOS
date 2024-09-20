// ignore_for_file: file_names
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:first/accessibility_settings.dart';
import 'package:first/comingsoon.dart';
import 'package:first/dualbrowser.dart';
import 'package:first/dualsocial.dart';
import 'package:first/recordsplitbackcamera.dart';
import 'package:first/recordsplitfrontcamera.dart';
import 'package:first/splitbackcamera.dart';
import 'package:first/splitfrontcamera.dart';
import 'package:first/video.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class TTSService {
  FlutterTts flutterTts = FlutterTts();

  Future speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }
}

class SecondPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SecondPage({super.key, required this.cameras});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with WidgetsBindingObserver {
  final floating = Floating();
  CameraController? _controller;
  bool isPiPEnabled = false;
  bool _isButtonVisible = true;
  bool isRecording = false;
  int _recordingDuration = 0;
  Timer? _timer;
  // ignore: unused_field
  String? _message;
  @override
  void initState() {
    super.initState();
    _initializeApp();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeApp() async {
    await _checkPermissions();

    if (widget.cameras.isNotEmpty) {
      _controller =
          CameraController(widget.cameras[0], ResolutionPreset.medium);
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((e) {
        print('Error initializing camera: $e');
      });
    } else {
      print('No cameras found on this device.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    if (lifecycleState == AppLifecycleState.resumed) {
      if (isRecording) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Save Video',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Do you want to save the video?',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xff00061c),
            actions: [
              TextButton(
                onPressed: () async {
                  await stopRecordingAndSave(save: false);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {
                    isPiPEnabled = false;
                    _isButtonVisible = true;
                  });
                },
                child: const Text(
                  'No',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await stopRecordingAndSave(save: true);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {
                    isPiPEnabled = false;
                    _isButtonVisible = true;
                  });
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          isPiPEnabled = false;
          _isButtonVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<void> enablePiPs(bool useFrontCamera) async {
  //   if (!isPiPEnabled) {
  //     CameraDescription cameraToUse;

  //     if (useFrontCamera) {
  //       // Use front camera
  //       cameraToUse = widget.cameras.firstWhere(
  //         (camera) => camera.lensDirection == CameraLensDirection.front,
  //       );
  //     } else {
  //       // Use back camera
  //       cameraToUse = widget.cameras.firstWhere(
  //         (camera) => camera.lensDirection == CameraLensDirection.back,
  //       );
  //     }

  //     // ignore: unnecessary_null_comparison
  //     if (cameraToUse != null) {
  //       // Enable Picture-in-Picture mode with the selected camera
  //       await floating.enable(aspectRatio: const Rational(4, 3));
  //       setState(() {
  //         isPiPEnabled = true;
  //         _isButtonVisible = false;
  //       });

  //       // Initialize the selected camera
  //       _controller = CameraController(cameraToUse, ResolutionPreset.medium);
  //       await _controller!.initialize();
  //       if (useFrontCamera) {
  //         _controller!.setZoomLevel(1); // Set zoom level for front camera
  //       } else {
  //         _controller!.setZoomLevel(1); // Set zoom level for back camera
  //       }
  //       setState(() {});
  //     } else {
  //       print('Selected camera not found.');
  //     }
  //   } else {
  //     setState(() {
  //       _isButtonVisible = true;
  //     });
  //   }
  // }

  // Future<void> enablePiP(bool useFrontCamera) async {
  //   if (!isPiPEnabled) {
  //     CameraDescription cameraToUse;

  //     if (useFrontCamera) {
  //       // Use front camera
  //       cameraToUse = widget.cameras.firstWhere(
  //         (camera) => camera.lensDirection == CameraLensDirection.front,
  //       );
  //     } else {
  //       // Use back camera
  //       cameraToUse = widget.cameras.firstWhere(
  //         (camera) => camera.lensDirection == CameraLensDirection.back,
  //       );
  //     }

  //     // ignore: unnecessary_null_comparison
  //     if (cameraToUse != null) {
  //       // Enable Picture-in-Picture mode with the selected camera
  //       await floating.enable(aspectRatio: const Rational(4, 3));
  //       setState(() {
  //         isPiPEnabled = true;
  //         _isButtonVisible = false;
  //       });

  //       // Initialize the selected camera
  //       _controller = CameraController(cameraToUse, ResolutionPreset.medium);
  //       await _controller!.initialize();
  //       if (useFrontCamera) {
  //         _controller!.setZoomLevel(1); // Set zoom level for front camera
  //       } else {
  //         _controller!.setZoomLevel(1); // Set zoom level for back camera
  //       }
  //       setState(() {});
  //       startRecording();
  //     } else {
  //       print('Selected camera not found.');
  //     }
  //   } else {
  //     setState(() {
  //       _isButtonVisible = true;
  //     });
  //   }
  // }

  void startRecording() async {
    if (_controller!.value.isInitialized && !isRecording) {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          isRecording = true;
          _recordingDuration = 0;
        });
        _startTimer();
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  Future<void> stopRecordingAndSave({required bool save}) async {
    if (_controller!.value.isRecordingVideo) {
      try {
        XFile videoFile = await _controller!.stopVideoRecording();
        setState(() {
          isRecording = false;
          _stopTimer();
        });
        if (save) {
          await _saveVideo(videoFile);
        }
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future<void> _saveVideo(XFile videoFile) async {
    if (videoFile.path.isNotEmpty) {
      bool success = await GallerySaver.saveVideo(videoFile.path,
              albumName: 'TestVideo') ??
          false;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Video Recording Saved Successfully"
                : "Failed to Save Video",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: success ? const Color(0xff00061c) : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _checkPermissions() async {
    await Permission.location.request();
    await Permission.phone.request();
  }

  Future<String> getEmergencyNumber() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String? countryCode = placemarks[0].isoCountryCode;

      // Print the country code for debugging
      print('Country Code: $countryCode');

      // Map country codes to emergency numbers
      Map<String, String> emergencyNumbers = {
        'IN': '+112', // India
        'US': '+911', // USA
        'GB': '+999', // United Kingdom
        'PK': '+15', // Pakistan
        'CA': '+911', // Canada
        'AU': '+000', // Australia
        'NZ': '+111', // New Zealand
        'ZA': '+10111', // South Africa
        'FR': '+112', // France
        'DE': '+112', // Germany
        'IT': '+112', // Italy
        'ES': '+112', // Spain
        'BR': '+190', // Brazil
        'AR': '+911', // Argentina
        'MX': '+911', // Mexico
        'RU': '+112', // Russia
        'CN': '+110', // China
        'JP': '+110', // Japan
        'KR': '+112', // South Korea
        'SG': '+999', // Singapore
        'MY': '+999', // Malaysia
        'TH': '+191', // Thailand
        'PH': '+117', // Philippines
        'ID': '+112', // Indonesia
        'VN': '+113', // Vietnam
        'SA': '+999', // Saudi Arabia
        'AE': '+999', // United Arab Emirates
        'EG': '+122', // Egypt
        'NG': '+112', // Nigeria
        'KE': '+999', // Kenya
        'TZ': '+112', // Tanzania
        'UG': '+999', // Uganda
        'GH': '+112', // Ghana
        'BD': '+999', // Bangladesh
        'LK': '+119', // Sri Lanka
        'NP': '+100', // Nepal
        'BE': '+112', // Belgium
        'NL': '+112', // Netherlands
        'SE': '+112', // Sweden
        'NO': '+112', // Norway
        'DK': '+112', // Denmark
        'FI': '+112', // Finland
        'IS': '+112', // Iceland
        'CH': '+112', // Switzerland
        'PT': '+112', // Portugal
        'GR': '+112', // Greece
        'IE': '+112', // Ireland
        'PL': '+112', // Poland
        'AT': '+112', // Austria
        'HU': '+112', // Hungary
        'CZ': '+112', // Czech Republic
        'SK': '+112', // Slovakia
        'SI': '+112', // Slovenia
        'HR': '+112', // Croatia
        'RS': '+112', // Serbia
        'RO': '+112', // Romania
        'BG': '+112', // Bulgaria
        'UA': '+112', // Ukraine
        'BY': '+112', // Belarus
        'TR': '+112', // Turkey
        'IR': '+110', // Iran
        'IQ': '+104', // Iraq
        'IL': '+100', // Israel
        'JO': '+911', // Jordan
        'LB': '+112', // Lebanon
        'SY': '+112', // Syria
        'AF': '+119', // Afghanistan
        'OM': '+9999', // Oman
        'QA': '+999', // Qatar
        'KW': '+112', // Kuwait
        'BH': '+999', // Bahrain
        'YE': '+199', // Yemen
        'MA': '+19', // Morocco
        'DZ': '+14', // Algeria
        'TN': '+197', // Tunisia
        'LY': '+193', // Libya
        'SD': '+999', // Sudan
        'SS': '+777', // South Sudan
        'ET': '+911', // Ethiopia
        'CM': '+112', // Cameroon
        'CI': '+170', // Ivory Coast
        'SN': '+17', // Senegal
        'ML': '+112', // Mali
        'ZM': '+991', // Zambia
        'ZW': '+995', // Zimbabwe
        'MW': '+997', // Malawi
        'MZ': '+119', // Mozambique
        'AO': '+113', // Angola
        'NA': '+10111', // Namibia
        'BW': '+911', // Botswana
        'SZ': '+999', // Eswatini
        'LS': '+123', // Lesotho
        'MG': '+117', // Madagascar
        'MU': '+999', // Mauritius
        'SC': '+999', // Seychelles
        'KM': '+17', // Comoros
        'CV': '+132', // Cape Verde
        'DJ': '+17', // Djibouti
        'ER': '+113', // Eritrea
        'SO': '+888', // Somalia
        'MM': '+199', // Myanmar
        'KH': '+117', // Cambodia
        'LA': '+119', // Laos
        'TL': '+112', // Timor-Leste
        'BT': '+113', // Bhutan
        'MV': '+119', // Maldives
        'BN': '+993', // Brunei
        'MO': '+999', // Macau
        'HK': '+999', // Hong Kong
        'MN': '+102', // Mongolia
        'KP': '+112', // North Korea
      };

      String emergencyNumber = emergencyNumbers[countryCode] ??
          '+911'; // Default to '112' if the country is not in the map
      print('Emergency Number: $emergencyNumber');
      return emergencyNumber;
    } catch (e) {
      print('Error: $e');
      return '+911'; // Default emergency number
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AccessibilitySettings>(
        builder: (context, settings, child) {
          return Stack(
            children: <Widget>[
              // Camera Preview
              _controller != null && _controller!.value.isInitialized
                  ? SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: PiPSwitcher(
                        childWhenEnabled: PinchZoom(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CameraPreview(_controller!),
                              ),
                              if (isRecording)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      _formatDuration(_recordingDuration),
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        childWhenDisabled: Scrollbar(
                          child: SingleChildScrollView(
                            child: Stack(
                              children: [
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height * 0.05,
                                  left:
                                      MediaQuery.of(context).size.width * 0.07,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ComingSoon(),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.165 *
                                              settings.fontSize,
                                          child: Image.asset(
                                            "images/dany.png",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top:
                                      MediaQuery.of(context).size.height * 0.05,
                                  left:
                                      MediaQuery.of(context).size.width * 0.78,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          String emergencyNumber =
                                              await getEmergencyNumber();
                                          bool? callMade =
                                              await FlutterPhoneDirectCaller
                                                  .callNumber(emergencyNumber);
                                          print('Call Made: $callMade');
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.165 *
                                              settings.fontSize,
                                          child: Image.asset(
                                            "images/sos-global.png",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.09,
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.16),
                                        child: Image.asset(
                                          "images/My-Seeing-Eye-Icon-Logo.png",
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.165,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      const Color(0xff00061c),
                                                  title: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Choose Options',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                            'View',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const SplitScreenPage(),
                                                              ),
                                                            ).then(
                                                              (_) =>
                                                                  Navigator.pop(
                                                                      context),
                                                            );
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Recording',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          onPressed: () {
                                                            // Placeholder for screen reader functionality
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const RecordSplitBackCameraPage(),
                                                              ),
                                                            ).then(
                                                              (_) =>
                                                                  Navigator.pop(
                                                                      context),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.175 *
                                                    settings.fontSize,
                                                child: Image.asset(
                                                  "images/split-browser-icon.png",
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              Text(
                                                "Front Split \n Browser\n",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.035 *
                                                          settings.fontSize,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.19,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      const Color(0xff00061c),
                                                  title: const Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Choose Options',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                            'View',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        const SplitViewFrontCamers())).then(
                                                                (_) => Navigator
                                                                    .pop(
                                                                        context));
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Recording',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          onPressed: () {
                                                            // Placeholder for screen reader functionality
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        const RecordSplitFrontCamers())).then(
                                                                (_) => Navigator
                                                                    .pop(
                                                                        context));
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.175 *
                                                    settings.fontSize,
                                                child: Image.asset(
                                                  "images/split-browser-icon.png",
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              Text(
                                                "Back Split \n Browser \n",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.035 *
                                                          settings.fontSize,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        SizedBox(
                                          child: Image.asset(
                                            "images/my-seen-eye-image.png",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const DualBrowserPage(),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.175 *
                                                              settings.fontSize,
                                                      child: Image.asset(
                                                        "images/split-browser-icon.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.02,
                                                    ),
                                                    Text(
                                                      "Dual \n Browser \n",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.035 *
                                                            settings.fontSize,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          const DualSocialPage(),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.175 *
                                                              settings.fontSize,
                                                      child: Image.asset(
                                                        "images/split-browser-icon.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.02,
                                                    ),
                                                    Text(
                                                      "Social Dual \n Browser \n",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.035 *
                                                            settings.fontSize,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Loading Camera...",
                        key: Key('loadingCamera'),
                      ),
                    ),

              // Floating Window
            ],
          );
        },
      ),
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.11,
          ),
          if (_isButtonVisible)
            FloatingActionButton(
              backgroundColor: const Color(0xff2abfdb),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Home1(),
                  ),
                );
              },
              heroTag: null,
              child: Icon(
                Icons.play_circle,
                color: const Color(0xff00061c),
                size: MediaQuery.of(context).size.width * 0.09,
              ),
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          if (_isButtonVisible)
            FloatingActionButton(
              backgroundColor: const Color(0xff2abfdb),
              onPressed: () {
                // Action for the button; adjust as needed or use a menu for multiple options
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xff00061c),
                      title: const Text(
                        'Accessibility Options',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextButton(
                              child: const Text(
                                'Font Size',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Provider.of<AccessibilitySettings>(context,
                                        listen: false)
                                    .toggleFontSize(context);
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Screen Reader',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                // Placeholder for screen reader functionality
                                Navigator.of(context).pop();
                                TTSService ttsService = TTSService();
                                await ttsService.speak(
                                    "In This Screen 5 icons Front Split Browser , Back Split Browser , Dual Browser , Social Dual Browser , SOS , Danny and Americans with Disabilities Act");
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Contrast',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Provider.of<AccessibilitySettings>(context,
                                        listen: false)
                                    .toggleHighContrast();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              heroTag: null,
              tooltip: 'Accessibility Options',
              child: Icon(
                Icons.accessibility,
                color: const Color(0xff00061c),
                size: MediaQuery.of(context).size.width * 0.09,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int duration) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
