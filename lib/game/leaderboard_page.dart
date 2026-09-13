import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'stranger_game_widget.dart';

class LeaderboardPage extends StatefulWidget {
  final String gameId;

  const LeaderboardPage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Future<void> _playAgain() async {
    try {
      final gameDoc = await FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId)
          .get();

      if (!gameDoc.exists) return;

      final data = gameDoc.data() as Map<String, dynamic>;
      final familyId = data['familyId'] as String;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StrangerGameWidget(
            familyId: familyId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء بدء لعبة جديدة'),
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
          'النتائج النهائية',
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
          final points = Map<String, int>.from(data['points'] ?? {});
          final strangerId = data['strangerId'] as String;
          final topic = data['topic'] as String;
          final strangerGuess = data['strangerGuess'] as String?;
          final category = data['category'] as String;

          // Sort players by points
          final sortedPlayers = points.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Summary
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص اللعبة',
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'التصنيف: $category',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                        Text(
                          'الموضوع: $topic',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                        if (strangerGuess != null)
                          Text(
                            'تخمين الغريب: $strangerGuess',
                            style:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Inter Tight',
                                      color: strangerGuess == topic
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Leaderboard
                Text(
                  'الترتيب',
                  style: FlutterFlowTheme.of(context).titleLarge,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = sortedPlayers[index];
                      final isStranger = player.key == strangerId;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(player.key)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text('جاري التحميل...');
                              }
                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Text(
                                userData['display_name'] ?? 'لاعب',
                                style: FlutterFlowTheme.of(context).bodyLarge,
                              );
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${player.value} نقطة',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                              if (isStranger)
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Play Again Button
                FFButtonWidget(
                  onPressed: _playAgain,
                  text: 'العب مرة أخرى',
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
