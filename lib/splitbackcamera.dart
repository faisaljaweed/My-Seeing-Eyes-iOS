//=================== without recording ===============//
// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:split_view/split_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SplitScreenPage extends StatefulWidget {
  const SplitScreenPage({Key? key}) : super(key: key);

  @override
  _SplitScreenPageState createState() => _SplitScreenPageState();
}

class _SplitScreenPageState extends State<SplitScreenPage> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  late WebViewController _webViewController;
  bool showCamera = true; // Indicates whether to show the camera or map

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
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press for WebView
        if (_webViewController != null) {
          final canGoBack = await _webViewController.canGoBack();
          if (canGoBack) {
            _webViewController.goBack();
            return false; // Do not pop the route
          }
        }
        // Default behavior: pop the route
        return true;
      },
      child: Scaffold(
        body: SplitView(
          viewMode: SplitViewMode.Vertical,
          indicator: SplitIndicator(viewMode: SplitViewMode.Vertical),
          gripSize: 8, // Set grip size for better adjustment
          children: [
            Stack(
              children: [
                showCamera
                    ? (_cameraController.value.isInitialized
                        ? SizedBox.expand(
                            child: CameraPreview(_cameraController),
                          )
                        : Container())
                    : Container(),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                  ),
                ),
              ],
            ),
            Center(
              child: WebView(
                initialUrl: 'https://www.google.com',
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
}
