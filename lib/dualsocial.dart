import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DualSocialPage extends StatefulWidget {
  const DualSocialPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DualSocialPageState createState() => _DualSocialPageState();
}

class _DualSocialPageState extends State<DualSocialPage> {
  late WebViewController _webViewController1;
  late WebViewController _webViewController2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press for WebView
        final canGoBack1 = await _webViewController1.canGoBack();
        final canGoBack2 = await _webViewController2.canGoBack();

        if (canGoBack1) {
          _webViewController1.goBack();
          return false; // Do not pop the route
        } else if (canGoBack2) {
          _webViewController2.goBack();
          return false; // Do not pop the route
        }
        // Default behavior: pop the route
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: SplitView(
          viewMode: SplitViewMode.Vertical,
          indicator: const SplitIndicator(viewMode: SplitViewMode.Vertical),
          gripSize: 8, // Set grip size for better adjustment
          children: [
            WebView(
              initialUrl: 'https://www.google.com',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController1 = webViewController;
              },
            ),
            WebView(
              initialUrl: 'https://www.facebook.com',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController2 = webViewController;
              },
            ),
          ],
        ),
      ),
    );
  }
}
