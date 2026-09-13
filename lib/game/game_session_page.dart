import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'vote_for_stranger_page.dart';
import 'vote_for_topic_page.dart';
import 'game_data.dart';
import 'leaderboard_page.dart';

class GameSessionPage extends StatefulWidget {
  final String gameId;

  const GameSessionPage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _GameSessionPageState createState() => _GameSessionPageState();
}

class _GameSessionPageState extends State<GameSessionPage> {
  bool _hasVoted = false;

  Future<void> _vote() async {
    if (_hasVoted) return;

    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);

      await gameRef.update({
        'votedPlayers': FieldValue.arrayUnion([currentUserUid]),
      });

      setState(() => _hasVoted = true);
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
          'جلسة اللعبة',
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
          final isStarted = data['isStarted'] ?? false;
          final category = data['category'] as String?;
          final topic = data['topic'] as String?;
          final players = List<String>.from(data['players'] ?? []);
          final strangerId = data['strangerId'] as String?;
          final votedPlayers = List<String>.from(data['votedPlayers'] ?? []);
          final isStranger = currentUserUid == strangerId;
          final strangerGuess = data['strangerGuess'];
          final gameEnded = data['gameEnded'] ?? false;

          // Navigate to leaderboard when game ends
          if (gameEnded) {
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

          // Check if all players have voted
          if (votedPlayers.length == players.length) {
            // Navigate to vote for stranger page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VoteForStrangerPage(
                    gameId: widget.gameId,
                  ),
                ),
              );
            });
          }

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Status
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالتك',
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          isStranger ? 'الغريب' : 'داخل الموضوع',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: 'Inter Tight',
                                color: isStranger ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category
                if (category != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التصنيف',
                            style: FlutterFlowTheme.of(context).titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            category,
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 16),

                // Topic (only shown for non-stranger players)
                if (!isStranger && topic != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الموضوع',
                            style: FlutterFlowTheme.of(context).titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            topic,
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 16),

                // Vote Button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: FFButtonWidget(
                    onPressed: _hasVoted ? null : _vote,
                    text: _hasVoted
                        ? 'تم التصويت (${votedPlayers.length}/${players.length})'
                        : 'تصويت (${votedPlayers.length}/${players.length})',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter Tight',
                                color: Colors.white,
                              ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      disabledColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                    ),
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
