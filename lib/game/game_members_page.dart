import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'game_session_page.dart';
import 'game_data.dart';
import 'dart:math';
import 'stranger_game_widget.dart';

class GameMembersPage extends StatefulWidget {
  final String gameId;
  final String familyId;

  const GameMembersPage({
    Key? key,
    required this.gameId,
    required this.familyId,
  }) : super(key: key);

  @override
  _GameMembersPageState createState() => _GameMembersPageState();
}

class _GameMembersPageState extends State<GameMembersPage> {
  bool _isLoading = false;

  Future<void> _leaveGame() async {
    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('اللعبة غير موجودة'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
        return;
      }

      final data = gameDoc.data() as Map<String, dynamic>;
      final players = List<String>.from(data['players'] ?? []);
      final readyPlayers = List<String>.from(data['readyPlayers'] ?? []);
      final creatorId = data['creatorId'];

      // Remove player from players list
      await gameRef.update({
        'players': FieldValue.arrayRemove([currentUserUid]),
        'readyPlayers': FieldValue.arrayRemove([currentUserUid]),
      });

      // If this was the last player, delete the game
      if (players.length <= 1) {
        await gameRef.delete();
      }

      // Navigate back to the game list
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StrangerGameWidget(
              familyId: widget.familyId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء مغادرة اللعبة'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _toggleReady() async {
    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('اللعبة غير موجودة'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
        return;
      }

      final data = gameDoc.data() as Map<String, dynamic>;
      final readyPlayers = List<String>.from(data['readyPlayers'] ?? []);

      if (readyPlayers.contains(currentUserUid)) {
        await gameRef.update({
          'readyPlayers': FieldValue.arrayRemove([currentUserUid]),
        });
      } else {
        await gameRef.update({
          'readyPlayers': FieldValue.arrayUnion([currentUserUid]),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحديث الحالة'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _startGame() async {
    setState(() => _isLoading = true);
    try {
      final gameRef = FirebaseFirestore.instance
          .collection('stranger_games')
          .doc(widget.gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        throw Exception('اللعبة غير موجودة');
      }

      final data = gameDoc.data() as Map<String, dynamic>;
      final players = List<String>.from(data['players'] ?? []);
      final readyPlayers = List<String>.from(data['readyPlayers'] ?? []);
      final creatorId = data['creatorId'];

      if (currentUserUid != creatorId) {
        throw Exception('فقط منشئ اللعبة يمكنه بدء اللعبة');
      }

      if (players.length < 2) {
        throw Exception('يجب أن يكون هناك لاعبان على الأقل لبدء اللعبة');
      }

      if (readyPlayers.length != players.length) {
        throw Exception('يجب أن يكون جميع اللاعبين جاهزين لبدء اللعبة');
      }

      // Select random stranger
      final random = Random();
      final strangerId = players[random.nextInt(players.length)];

      // Select random category and topic
      final categories = GAME_CATEGORIES.keys.toList();
      final category = categories[random.nextInt(categories.length)];
      final topics = GAME_CATEGORIES[category]!;
      final topic = topics[random.nextInt(topics.length)];

      await gameRef.update({
        'isStarted': true,
        'startedAt': FieldValue.serverTimestamp(),
        'strangerId': strangerId,
        'category': category,
        'topic': topic,
        'points': Map.fromIterable(players, key: (p) => p, value: (_) => 0),
        'votedPlayers': [],
        'strangerVotes': [],
        'nextVotePlayers': [],
      });

      // Navigation will happen automatically through the stream
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'قائمة اللاعبين',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _leaveGame,
            tooltip: 'مغادرة الجلسة',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stranger_games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ في تحميل البيانات'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('اللعبة غير موجودة'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final players = List<String>.from(data['players'] ?? []);
          final readyPlayers = List<String>.from(data['readyPlayers'] ?? []);
          final creatorId = data['creatorId'];
          final isCreator = currentUserUid == creatorId;
          final allPlayersReady = readyPlayers.length == players.length;
          final isStarted = data['isStarted'] ?? false;

          // Automatically navigate all players when game is started
          if (isStarted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GameSessionPage(
                    gameId: widget.gameId,
                  ),
                ),
              );
            });
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'عدد اللاعبين: ${players.length}',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final playerId = players[index];
                      final isReady = readyPlayers.contains(playerId);
                      final isCurrentUser = playerId == currentUserUid;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(playerId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return CircleAvatar(
                                  child: Icon(Icons.person),
                                );
                              }
                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              final photoUrl = userData['photo_url'];
                              return CircleAvatar(
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? Icon(Icons.person)
                                    : null,
                              );
                            },
                          ),
                          title: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(playerId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Text('جاري التحميل...');
                              }
                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              return Text(
                                userData['display_name'] ?? 'لاعب',
                                style: FlutterFlowTheme.of(context).bodyLarge,
                              );
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isReady)
                                Icon(
                                  Icons.check_circle,
                                  color: FlutterFlowTheme.of(context).success,
                                ),
                              if (isCurrentUser && !data['isStarted'])
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: FFButtonWidget(
                                    onPressed: _toggleReady,
                                    text: isReady ? 'غير جاهز' : 'جاهز',
                                    options: FFButtonOptions(
                                      width: 100,
                                      height: 36,
                                      color: isReady
                                          ? FlutterFlowTheme.of(context)
                                              .secondary
                                          : FlutterFlowTheme.of(context)
                                              .primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Inter Tight',
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              if (playerId == creatorId)
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
                if (isCreator && !data['isStarted'])
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: FFButtonWidget(
                      onPressed: allPlayersReady ? _startGame : null,
                      text: _isLoading
                          ? 'جاري بدء اللعبة...'
                          : allPlayersReady
                              ? 'بدء اللعبة'
                              : 'انتظر حتى يصبح جميع اللاعبين جاهزين',
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
