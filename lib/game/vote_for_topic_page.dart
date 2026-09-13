import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'game_data.dart';
import 'leaderboard_page.dart';

class VoteForTopicPage extends StatefulWidget {
  final String gameId;

  const VoteForTopicPage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _VoteForTopicPageState createState() => _VoteForTopicPageState();
}

class _VoteForTopicPageState extends State<VoteForTopicPage> {
  String? _selectedTopic;
  bool _hasVoted = false;

  Future<void> _voteForTopic() async {
    if (_selectedTopic == null || _hasVoted) return;

    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);

      final gameDoc = await gameRef.get();
      if (!gameDoc.exists) return;

      final data = gameDoc.data() as Map<String, dynamic>;
      final actualTopic = data['topic'] as String;
      final points = Map<String, int>.from(data['points'] ?? {});

      // Award 50 points if the stranger guessed correctly
      if (_selectedTopic == actualTopic) {
        points[currentUserUid] = (points[currentUserUid] ?? 0) + 50;
      }

      // Update game state with stranger's guess and mark game as ended
      await gameRef.update({
        'strangerGuess': _selectedTopic,
        'points': points,
        'gameEnded': true,
      });

      // Navigate to leaderboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardPage(
              gameId: widget.gameId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء التصويت'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'خمن الموضوع',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stranger_games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('اللعبة غير موجودة'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final category = data['category'] as String;
          final topics = GAME_CATEGORIES[category] ?? [];
          final strangerGuess = data['strangerGuess'];
          final strangerId = data['strangerId'] as String;
          final isStranger = currentUserUid == strangerId;

          // Navigate to leaderboard when stranger has made their guess
          if (strangerGuess != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(
                    gameId: widget.gameId,
                  ),
                ),
              );
            });
            return Center(child: CircularProgressIndicator());
          }

          if (!isStranger) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'الغريب يحاول معرفة الموضوع...',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 2000),
                        builder: (context, double value, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'انتظر...',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التصنيف: $category',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                SizedBox(height: 16),
                Text(
                  'اختر الموضوع الذي تعتقد أنه الصحيح:',
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            topic,
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                          selected: _selectedTopic == topic,
                          onTap: () => setState(() => _selectedTopic = topic),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: _selectedTopic != null ? _voteForTopic : null,
                  text: 'تأكيد',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    disabledColor:
                        FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
