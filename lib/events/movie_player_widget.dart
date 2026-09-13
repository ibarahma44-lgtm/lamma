import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MoviePlayerWidget extends StatefulWidget {
  const MoviePlayerWidget({
    super.key,
    required this.movieTitle,
    required this.videoUrl,
  });

  final String movieTitle;
  final String videoUrl;

  @override
  State<MoviePlayerWidget> createState() => _MoviePlayerWidgetState();
}

class _MoviePlayerWidgetState extends State<MoviePlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  String _remainingTime = '00:00';
  String _totalTime = '00:00';
  bool _isFullscreen = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Set initial system UI mode with proper overlays
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      String url = widget.videoUrl;
      if (url.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(url);
        url = await ref.getDownloadURL();
      }
      _controller = VideoPlayerController.network(
        url,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'Range': 'bytes=0-',
        },
      );
      await _controller!.initialize();
      _controller!.setVolume(1.0);
      _controller!.setPlaybackSpeed(1.0);
      _controller!.addListener(_updateTime);
      setState(() {
        _isInitialized = true;
        _totalTime = _formatDuration(_controller!.value.duration);
      });
    } catch (e) {
      print('Error initializing video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading video: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  void _updateTime() {
    if (!mounted || _controller == null) return;
    setState(() {
      _remainingTime = _formatDuration(
        _controller!.value.duration - _controller!.value.position,
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _showControls = true;
    });
    _resetHideTimer();
  }

  void _seekForward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position + Duration(seconds: 10);
    if (newPosition <= _controller!.value.duration) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(_controller!.value.duration);
    }
    _resetHideTimer();
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPosition = _controller!.value.position - Duration(seconds: 10);
    if (newPosition >= Duration.zero) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(Duration.zero);
    }
    _resetHideTimer();
  }

  void _toggleFullscreen() async {
    if (_isFullscreen) {
      // Exiting fullscreen
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // Entering fullscreen
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    setState(() {
      _showControls = true;
    });
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _resetSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Cleanup when widget is disposed
    _controller?.pause();
    _controller?.dispose();
    _hideTimer?.cancel();

    // Reset system UI and orientation
    _resetSystemUI();

    super.dispose();
  }

  @override
  void deactivate() {
    // Cleanup when widget is deactivated (e.g., navigating away)
    _controller?.pause();
    _resetSystemUI();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset system UI when back button is pressed
        await _resetSystemUI();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: !_isFullscreen
            ? AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  widget.movieTitle,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                ),
                iconTheme: IconThemeData(color: Colors.white),
              )
            : null,
        body: _controller == null || !_isInitialized
            ? Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).secondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Loading movie...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                  if (_showControls)
                    Container(
                      color: Colors.black26,
                      child: Stack(
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.replay_10,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed:
                                      _isInitialized ? _seekBackward : null,
                                ),
                                SizedBox(width: 24),
                                IconButton(
                                  icon: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  onPressed:
                                      _isInitialized ? _togglePlayPause : null,
                                ),
                                SizedBox(width: 24),
                                IconButton(
                                  icon: Icon(
                                    Icons.forward_10,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  onPressed:
                                      _isInitialized ? _seekForward : null,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: _isFullscreen
                                ? 24
                                : 80, // Adjusted position for portrait mode
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Text(
                                    _remainingTime,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _controller!
                                          .value.position.inSeconds
                                          .toDouble(),
                                      min: 0,
                                      max: _controller!.value.duration.inSeconds
                                          .toDouble(),
                                      activeColor: FlutterFlowTheme.of(context)
                                          .secondary,
                                      inactiveColor: Colors.white30,
                                      onChanged: _isInitialized
                                          ? (value) {
                                              _controller!.seekTo(
                                                Duration(
                                                    seconds: value.toInt()),
                                              );
                                              _resetHideTimer();
                                            }
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    _totalTime,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isFullscreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: _isInitialized
                                        ? _toggleFullscreen
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
