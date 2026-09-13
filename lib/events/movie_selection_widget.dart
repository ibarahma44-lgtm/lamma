import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'movie_player_widget.dart';

class MovieSelectionWidget extends StatefulWidget {
  const MovieSelectionWidget({
    super.key,
    this.familyRef,
  });

  final DocumentReference? familyRef;

  @override
  State<MovieSelectionWidget> createState() => _MovieSelectionWidgetState();
}

class _MovieSelectionWidgetState extends State<MovieSelectionWidget> {
  final List<Map<String, dynamic>> movies = [
    {
      'title': 'فيلم الرسالة',
      'description':
          'The Message - A historical drama about the life of Prophet Muhammad',
      'thumbnail': 'assets/images/message_movie.jpg',
      'videoUrl':
          'gs://lamma-aq0sqq-knv7x/app_movies/[arabseed].The.Message.1976.1080p.WEB-DL.mp4',
    },
    {
      'title': 'فيلم عسل أسود',
      'description': 'Black Honey - A comedy drama about family relationships',
      'thumbnail': 'assets/images/black_honey_movie.jpg',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/lamma-aq0sqq-knv7x/o/app_movies%2F%5BCima-Now.CoM%5D%203sal.Eswad.2010.HD-1080p.mp4?alt=media&token=36dca8b9-1d89-4267-8618-0c42af616951',
    },
    {
      'title': 'فيلم العثور على نيمو',
      'description':
          'Finding Nemo - An animated adventure about a father\'s journey to find his son',
      'thumbnail': 'assets/images/nemo_movie.jpg',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/lamma-aq0sqq-knv7x/o/app_movies%2F%5BCima-Now.CoM%5D%20Finding.Nemo.2003.Dubbed.WEB-DL-1080p.mp4?alt=media&token=5e975c27-3e2d-41e3-a937-24830621d04b',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Watch our Movies',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  'MoviePlayer',
                  extra: <String, dynamic>{
                    'movieTitle': movie['title'],
                    'videoUrl': movie['videoUrl'],
                  },
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      movie['thumbnail'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          child: Icon(
                            Icons.movie,
                            size: 64,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['title'],
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          movie['description'],
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                context.pushNamed(
                                  'MoviePlayer',
                                  extra: <String, dynamic>{
                                    'movieTitle': movie['title'],
                                    'videoUrl': movie['videoUrl'],
                                  },
                                );
                              },
                              icon: Icon(Icons.play_arrow),
                              label: Text('Watch Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    FlutterFlowTheme.of(context).secondary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
