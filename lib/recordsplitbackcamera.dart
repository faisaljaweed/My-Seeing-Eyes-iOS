//=====================With Recording ======================//

// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_super_parameters
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:split_view/split_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecordSplitBackCameraPage extends StatefulWidget {
  const RecordSplitBackCameraPage({Key? key}) : super(key: key);

  @override
  _RecordSplitBackCameraPageState createState() =>
      _RecordSplitBackCameraPageState();
}

class _RecordSplitBackCameraPageState extends State<RecordSplitBackCameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  // ignore: unused_field
  late WebViewController _webViewController;
  bool showCamera = true; // Indicates whether to show the camera or map
  bool isRecording = false;
  int _recordingDuration = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
    startRecording();
  }

  void startRecording() async {
    if (_cameraController.value.isInitialized && !isRecording) {
      try {
        await _cameraController.startVideoRecording();
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
    if (_cameraController.value.isRecordingVideo) {
      try {
        XFile videoFile = await _cameraController.stopVideoRecording();
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
          duration: const Duration(seconds: 3),
        ),
      );
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
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (isRecording) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xff00061c),
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
              actions: [
                TextButton(
                  onPressed: () async {
                    await stopRecordingAndSave(save: false);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(true); // Pop the current route
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
                    Navigator.of(context).pop(true); // Pop the current route
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ) ??
          false; // Return false if the dialog is dismissed without a selection
    }
    return true; // Default behavior: pop the route
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SplitView(
          viewMode: SplitViewMode.Vertical,
          children: [
            showCamera
                ? (_cameraController.value.isInitialized
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: CameraPreview(_cameraController),
                          ),
                          Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                _formatDuration(_recordingDuration),
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container())
                : Container(),
            Center(
              child: WebView(
                initialUrl: 'https://www.google.com/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int duration) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
