import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Home1 extends StatefulWidget {
  const Home1({
    super.key,
  });

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/video/guide.mp4',
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        // title:
        //     const Text('Guide Video'), // Optional: Add a title for the AppBar
      ),
      body: Center(
        child: _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Chewie(
                  controller: chewieController,
                ),
              )
            : const CircularProgressIndicator(), // Show a loading indicator while video is initializing
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}
