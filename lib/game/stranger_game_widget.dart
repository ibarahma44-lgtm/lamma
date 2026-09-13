import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stranger_game_model.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'game_members_page.dart';
import 'package:intl/intl.dart';
export 'stranger_game_model.dart';

class StrangerGameWidget extends StatefulWidget {
  final String? gameId;
  final String familyId;
  const StrangerGameWidget({
    Key? key,
    this.gameId,
    required this.familyId,
  }) : super(key: key);

  @override
  State<StrangerGameWidget> createState() => _StrangerGameWidgetState();
}

class _StrangerGameWidgetState extends State<StrangerGameWidget> {
  bool _isLoading = false;
  late StrangerGameModel _model;
  DocumentReference? currentGameRef;
  bool isGameStarted = false;
  bool isStranger = false;
  String? currentTopic;
  String? currentCategory;
  late String familyId;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = StrangerGameModel();
    _initializeGame();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _checkAndCleanEmptyGames() async {
    try {
      final gamesSnapshot = await FirebaseFirestore.instance
          .collection('stranger_games')
          .where('familyId', isEqualTo: familyId)
          .where('isStarted', isEqualTo: false)
          .get();

      for (var gameDoc in gamesSnapshot.docs) {
        final data = gameDoc.data() as Map<String, dynamic>;
        final players = List<String>.from(data['players'] ?? []);

        if (players.isEmpty) {
          // Delete the game if it has no players
          await gameDoc.reference.delete();
        }
      }
    } catch (e) {
      print('Error cleaning empty games: $e');
    }
  }

  Future<void> _initializeGame() async {
    try {
      setState(() {
        familyId = widget.familyId;
      });

      // Check and clean empty games
      await _checkAndCleanEmptyGames();

      if (widget.gameId != null) {
        final gameDoc = await FirebaseFirestore.instance
            .collection('stranger_games')
            .doc(widget.gameId)
            .get();

        if (gameDoc.exists) {
          final data = gameDoc.data() as Map<String, dynamic>;
          setState(() {
            currentGameRef = gameDoc.reference;
            isGameStarted = data['isStarted'] ?? false;
            if (isGameStarted) {
              isStranger = data['strangerId'] == currentUserUid;
              currentTopic = data['topic'];
              currentCategory = data['category'];
            }
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل اللعبة'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  Future<void> _createNewGame() async {
    try {
      final gameRef = await _model.createGame(familyId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameMembersPage(
              gameId: gameRef.id,
              familyId: familyId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إنشاء اللعبة'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'لعبة الغريب',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).info,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (!isGameStarted) ...[
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'الجلسات النشطة',
                            style: FlutterFlowTheme.of(context).headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('stranger_games')
                                .where('familyId', isEqualTo: familyId)
                                .where('isStarted', isEqualTo: false)
                                .orderBy('createdTime', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text(
                                        'جاري تحميل الجلسات...',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        size: 60,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'حدث خطأ في تحميل الجلسات',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'يرجى التأكد من اتصالك بالإنترنت',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      FFButtonWidget(
                                        onPressed: () {
                                          setState(() {});
                                        },
                                        text: 'إعادة المحاولة',
                                        options: FFButtonOptions(
                                          width: 150,
                                          height: 40,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily: 'Inter Tight',
                                                    color: Colors.white,
                                                  ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.games_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 60,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'لا توجد جلسات نشطة',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'يمكنك إنشاء جلسة جديدة للعب',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Filter out games with no players
                              final games = snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final players =
                                    List<String>.from(data['players'] ?? []);
                                return players.isNotEmpty;
                              }).toList();

                              if (games.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.games_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 60,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'لا توجد جلسات نشطة',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'يمكنك إنشاء جلسة جديدة للعب',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: games.length,
                                itemBuilder: (context, index) {
                                  final gameDoc = games[index];
                                  final data =
                                      gameDoc.data() as Map<String, dynamic>;
                                  final players =
                                      List<String>.from(data['players'] ?? []);
                                  final createdTime =
                                      (data['createdTime'] as Timestamp?)
                                          ?.toDate();

                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        'جلسة ${index + 1}',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'عدد اللاعبين: ${players.length}',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                          ),
                                          if (createdTime != null)
                                            Text(
                                              'أنشئت: ${DateFormat('dd/MM/yyyy HH:mm', 'ar').format(createdTime)}',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                            ),
                                        ],
                                      ),
                                      trailing: players.contains(currentUserUid)
                                          ? ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GameMembersPage(
                                                      gameId: gameDoc.id,
                                                      familyId: familyId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                foregroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                              ),
                                              child: Text('متابعة'),
                                            )
                                          : ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'stranger_games')
                                                      .doc(gameDoc.id)
                                                      .update({
                                                    'players':
                                                        FieldValue.arrayUnion(
                                                            [currentUserUid]),
                                                  });

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GameMembersPage(
                                                        gameId: gameDoc.id,
                                                        familyId: familyId,
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'حدث خطأ أثناء الانضمام للجلسة'),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                foregroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                              ),
                                              child: Text('انضم'),
                                            ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (!isGameStarted)
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: FFButtonWidget(
                              onPressed: _createNewGame,
                              text: 'انشاء لعبة جديدة',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
