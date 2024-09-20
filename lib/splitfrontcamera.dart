// =================== with out recording ===========//

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:split_view/split_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SplitViewFrontCamers extends StatefulWidget {
  const SplitViewFrontCamers({super.key});

  @override
  State<SplitViewFrontCamers> createState() => _SplitViewFrontCamersState();
}

class _SplitViewFrontCamersState extends State<SplitViewFrontCamers> {
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
    // Fetch the available cameras
    cameras = await availableCameras();

    // Select the front camera
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => throw Exception('Front camera not found.'),
    );

    // Initialize the front camera
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );
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
