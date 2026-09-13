import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'vote_for_topic_page.dart';
import 'leaderboard_page.dart';

class VoteForStrangerPage extends StatefulWidget {
  final String gameId;

  const VoteForStrangerPage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _VoteForStrangerPageState createState() => _VoteForStrangerPageState();
}

class _VoteForStrangerPageState extends State<VoteForStrangerPage> {
  String? _selectedPlayerId;
  bool _hasVoted = false;
  bool _hasClickedNext = false;

  Future<void> _voteForStranger() async {
    if (_selectedPlayerId == null || _hasVoted) return;

    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);

      await gameRef.update({
        'strangerVotes': FieldValue.arrayUnion([
          {
            'voterId': currentUserUid,
            'votedForId': _selectedPlayerId,
          }
        ]),
        'nextVotePlayers': FieldValue.arrayUnion([currentUserUid]),
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

  Future<void> _clickNext() async {
    if (_hasClickedNext) return;

    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);

      await gameRef.update({
        'nextVotePlayers': FieldValue.arrayUnion([currentUserUid]),
      });

      setState(() => _hasClickedNext = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ'),
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
          'من هو الغريب؟',
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
          final players = List<String>.from(data['players'] ?? []);
          final strangerId = data['strangerId'] as String?;
          final strangerVotes =
              List<Map<String, dynamic>>.from(data['strangerVotes'] ?? []);
          final nextVotePlayers =
              List<String>.from(data['nextVotePlayers'] ?? []);
          final myVote = strangerVotes.firstWhere(
            (vote) => vote['voterId'] == currentUserUid,
            orElse: () => {},
          );
          final isStranger = currentUserUid == strangerId;
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

          // Only navigate stranger to vote for topic when ALL players have clicked next
          if (nextVotePlayers.length == players.length && isStranger) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VoteForTopicPage(
                    gameId: widget.gameId,
                  ),
                ),
              );
            });
            return Center(child: CircularProgressIndicator());
          }

          // Calculate points if all votes are in
          if (strangerVotes.length == players.length - 1) {
            // Excluding stranger
            final correctVotes = strangerVotes
                .where((vote) => vote['votedForId'] == strangerId)
                .length;

            // Update points for correct guesses
            if (!data.containsKey('pointsUpdated')) {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                final gameDoc = await transaction.get(FirebaseFirestore.instance
                    .collection('stranger_games')
                    .doc(widget.gameId));

                if (!gameDoc.exists) return;

                final gameData = gameDoc.data() as Map<String, dynamic>;
                final points = Map<String, int>.from(gameData['points'] ?? {});

                // Award 50 points to each correct guesser
                for (var vote in strangerVotes) {
                  if (vote['votedForId'] == strangerId) {
                    final voterId = vote['voterId'];
                    points[voterId] = (points[voterId] ?? 0) + 50;
                  }
                }

                transaction.update(gameDoc.reference, {
                  'points': points,
                  'pointsUpdated': true,
                });
              });
            }
          }

          if (isStranger) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/strangerhush.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'جاري التصويت عليك...',
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
                        tween: Tween<double>(
                            begin: 0,
                            end: strangerVotes.length / (players.length - 1)),
                        duration: Duration(milliseconds: 1500),
                        builder: (context, double value, child) {
                          // Check if animation is complete and all votes are in
                          if (value >= 1.0 &&
                              strangerVotes.length == players.length - 1) {
                            // Add a small delay before navigation
                            Future.delayed(Duration(milliseconds: 500), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VoteForTopicPage(
                                    gameId: widget.gameId,
                                  ),
                                ),
                              );
                            });
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(value * 100).toInt()}%',
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                              ),
                              SizedBox(height: 8),
                              CircularProgressIndicator(
                                value: value,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${strangerVotes.length} / ${players.length - 1}',
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
          } else if (strangerVotes.length == players.length - 1) {
            // Show waiting message for other players after voting is complete
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
                if (!isStranger && !_hasVoted) ...[
                  Text(
                    'اختر من تعتقد أنه الغريب:',
                    style: FlutterFlowTheme.of(context).titleLarge,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final playerId = players[index];
                        if (playerId == currentUserUid)
                          return SizedBox.shrink();

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(playerId)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text('جاري التحميل...');
                                }
                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                return Text(
                                  userData['display_name'] ?? 'لاعب',
                                  style: FlutterFlowTheme.of(context).bodyLarge,
                                );
                              },
                            ),
                            selected: _selectedPlayerId == playerId,
                            onTap: () =>
                                setState(() => _selectedPlayerId = playerId),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  FFButtonWidget(
                    onPressed:
                        _selectedPlayerId != null ? _voteForStranger : null,
                    text: 'تصويت',
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
                ],
                if (_hasVoted || isStranger) ...[
                  Text(
                    'نتائج التصويت:',
                    style: FlutterFlowTheme.of(context).titleLarge,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'عدد الأصوات: ${strangerVotes.length}/${players.length - 1}',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                  if (strangerVotes.length == players.length - 1) ...[
                    SizedBox(height: 16),
                    FFButtonWidget(
                      onPressed: _hasClickedNext ? null : _clickNext,
                      text:
                          'التالي (${nextVotePlayers.length}/${players.length})',
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
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
