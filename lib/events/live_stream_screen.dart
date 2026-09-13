import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  // Channel categories with their respective channels
  final Map<String, List<Map<String, dynamic>>> channelCategories = {
    '📺 News': [
      {
        'name': 'Al Jazeera',
        'streamUrl': 'https://live-hls-aljazeera.scdn1.secure.raxcdn.com/aljazeera/01.m3u8',
        'logo': 'assets/images/aljazeera.png',
        'description': 'Live news coverage from Al Jazeera Arabic',
        'isVerified': true,
      },
      {
        'name': 'Al Araby',
        'streamUrl': 'https://live-hls-alaraby.scdn1.secure.raxcdn.com/alaraby/01.m3u8',
        'logo': 'assets/images/alaraby.png',
        'description': 'Latest news and updates from Al Araby TV',
        'isVerified': true,
      },
      {
        'name': 'BBC Arabic',
        'streamUrl': 'https://live-hls-bbc.scdn1.secure.raxcdn.com/bbc/01.m3u8',
        'logo': 'assets/images/bbc.png',
        'description': 'Live coverage from BBC Arabic',
        'isVerified': true,
      },
      {
        'name': 'France 24 Arabic',
        'streamUrl': 'https://live-hls-france24.scdn1.secure.raxcdn.com/france24/01.m3u8',
        'logo': 'assets/images/france24.png',
        'description': 'News and current affairs from France 24 Arabic',
        'isVerified': true,
      },
      {
        'name': 'Sky News Arabia',
        'streamUrl': 'https://live-hls-skynews.scdn1.secure.raxcdn.com/skynews/01.m3u8',
        'logo': 'assets/images/skynews.png',
        'description': 'Live news from Sky News Arabia',
        'isVerified': true,
      },
      {
        'name': 'DW Arabic',
        'streamUrl': 'https://live-hls-dw.scdn1.secure.raxcdn.com/dw/01.m3u8',
        'logo': 'assets/images/dw.png',
        'description': 'German international news in Arabic',
        'isVerified': false,
      },
      {
        'name': 'Al Mayadeen',
        'streamUrl': 'https://live-hls-mayadeen.scdn1.secure.raxcdn.com/mayadeen/01.m3u8',
        'logo': 'assets/images/mayadeen.png',
        'description': 'Pan-Arab news network',
        'isVerified': false,
      },
    ],
    '⚽ Sports': [
      {
        'name': 'beIN Sports News',
        'streamUrl': 'https://live-hls-beinsports.scdn1.secure.raxcdn.com/beinsports/01.m3u8',
        'logo': 'assets/images/beinsports.png',
        'description': 'Latest sports news and updates',
        'isVerified': false,
      },
      {
        'name': 'SSC',
        'streamUrl': 'https://live-hls-ssc.scdn1.secure.raxcdn.com/ssc/01.m3u8',
        'logo': 'assets/images/ssc.png',
        'description': 'Saudi Sports Company live coverage',
        'isVerified': false,
      },
      {
        'name': 'Al Kass',
        'streamUrl': 'https://live-hls-alkass.scdn1.secure.raxcdn.com/alkass/01.m3u8',
        'logo': 'assets/images/alkass.png',
        'description': 'Qatar sports channel',
        'isVerified': false,
      },
      {
        'name': 'Kooora',
        'streamUrl': 'https://live-hls-kooora.scdn1.secure.raxcdn.com/kooora/01.m3u8',
        'logo': 'assets/images/kooora.png',
        'description': 'Sports news and live matches',
        'isVerified': false,
      },
      {
        'name': 'Sada ElBalad Sports',
        'streamUrl': 'https://live-hls-sadaelbalad.scdn1.secure.raxcdn.com/sadaelbalad/01.m3u8',
        'logo': 'assets/images/sadaelbalad.png',
        'description': 'Egyptian sports coverage',
        'isVerified': false,
      },
    ],
    '🎭 Culture & Talk': [
      {
        'name': 'Al Hayah TV',
        'streamUrl': 'https://live-hls-alhayah.scdn1.secure.raxcdn.com/alhayah/01.m3u8',
        'logo': 'assets/images/alhayah.png',
        'description': 'Religious and cultural programming',
        'isVerified': false,
      },
      {
        'name': 'ON Live',
        'streamUrl': 'https://live-hls-onlive.scdn1.secure.raxcdn.com/onlive/01.m3u8',
        'logo': 'assets/images/onlive.png',
        'description': 'Entertainment and talk shows',
        'isVerified': false,
      },
      {
        'name': 'Rotana Drama',
        'streamUrl': 'https://live-hls-rotana.scdn1.secure.raxcdn.com/rotana/01.m3u8',
        'logo': 'assets/images/rotana.png',
        'description': 'Arabic drama series and shows',
        'isVerified': false,
      },
      {
        'name': 'Cairo Drama',
        'streamUrl': 'https://live-hls-cairodrama.scdn1.secure.raxcdn.com/cairodrama/01.m3u8',
        'logo': 'assets/images/cairodrama.png',
        'description': 'Egyptian drama and entertainment',
        'isVerified': false,
      },
    ],
    '🌍 International': [
      {
        'name': 'TRT World',
        'streamUrl': 'https://live-hls-trt.scdn1.secure.raxcdn.com/trt/01.m3u8',
        'logo': 'assets/images/trt.png',
        'description': 'Turkish international news',
        'isVerified': false,
      },
      {
        'name': 'CGTN Arabic',
        'streamUrl': 'https://live-hls-cgtn.scdn1.secure.raxcdn.com/cgtn/01.m3u8',
        'logo': 'assets/images/cgtn.png',
        'description': 'Chinese international news',
        'isVerified': false,
      },
      {
        'name': 'Euronews Arabic',
        'streamUrl': 'https://live-hls-euronews.scdn1.secure.raxcdn.com/euronews/01.m3u8',
        'logo': 'assets/images/euronews.png',
        'description': 'European news network',
        'isVerified': false,
      },
      {
        'name': 'RT Arabic',
        'streamUrl': 'https://live-hls-rt.scdn1.secure.raxcdn.com/rt/01.m3u8',
        'logo': 'assets/images/rt.png',
        'description': 'Russian international news',
        'isVerified': false,
      },
    ],
  };

  void _playChannel(String streamUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VideoPlayerScreen(streamUrl: streamUrl),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> channels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            category,
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...channels.map((channel) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                margin: EdgeInsets.only(bottom: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _playChannel(channel['streamUrl']),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.live_tv,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      channel['name'],
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (channel['isVerified'] == false)
                                    Icon(
                                      Icons.info_outline,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      size: 16,
                                    ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                channel['description'],
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Watch Now',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context).primary,
                                            fontWeight: FontWeight.w500,
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
                  ),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Live Channels',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: channelCategories.isEmpty
          ? Center(
              child: Text(
                'No live channels found.',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
            )
          : ListView(
              children: channelCategories.entries
                  .map((entry) => _buildCategorySection(entry.key, entry.value))
                  .toList(),
            ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String streamUrl;

  const _VideoPlayerScreen({Key? key, required this.streamUrl}) : super(key: key);

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.streamUrl);
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: FlutterFlowTheme.of(context).error,
                ),
                SizedBox(height: 16),
                Text(
                  'This stream is currently unavailable',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).error,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Live Stream',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: FlutterFlowTheme.of(context).error,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This stream is currently unavailable',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).error,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Go Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Chewie(controller: _chewieController!),
                ),
    );
  }
} 