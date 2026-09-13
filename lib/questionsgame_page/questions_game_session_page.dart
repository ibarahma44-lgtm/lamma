import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'questionsgame_page_widget.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class QuestionsGameSessionPage extends StatefulWidget {
  const QuestionsGameSessionPage({Key? key}) : super(key: key);

  @override
  _QuestionsGameSessionPageState createState() =>
      _QuestionsGameSessionPageState();
}

class _QuestionsGameSessionPageState extends State<QuestionsGameSessionPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isCreatingSession = false;
  String? sessionCode;
  bool isJoiningSession = false;
  TextEditingController sessionCodeController = TextEditingController();
  List<Map<String, dynamic>> players = [];
  bool isGameStarted = false;
  String? currentPlayerId;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<String> shuffledOptions = [];
  bool isAnswering = false;
  String? lastCorrectAnswer;
  bool usedFiftyFifty = false;
  bool usedHint = false;
  bool usedPoll = false;
  bool usedSkip = false;
  List<String> removedChoices = [];
  String? hintText;
  Map<String, int>? pollResult;
  int timeLeft = 30;
  Timer? timer;
  Timer? emptySessionTimer;
  DateTime? lastEmptyTime;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    emptySessionTimer?.cancel();
    // Delete session if creator leaves
    if (sessionCode != null) {
      FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(sessionCode)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          if (data['createdBy'] == currentUserUid) {
            doc.reference.delete();
          }
        }
      });
    }
    super.dispose();
  }

  void startTimer() {
    timeLeft = 30;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        submitAnswer("_timeout_");
      }
    });
  }

  Color getTimerColor() {
    if (timeLeft > 20) {
      return Colors.orange;
    } else if (timeLeft > 10) {
      return Color.lerp(Colors.orange, Colors.red, (20 - timeLeft) / 10)!;
    } else {
      return Colors.red;
    }
  }

  Future<void> _loadQuestions() async {
    // Load questions from your JSON file
    // This should be similar to your offline game's question loading
  }

  void _checkEmptySession() {
    if (sessionCode == null) return;

    emptySessionTimer?.cancel();
    emptySessionTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (sessionCode == null) {
        timer.cancel();
        return;
      }

      final sessionRef = FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(sessionCode);

      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        timer.cancel();
        return;
      }

      final data = sessionDoc.data()!;
      final playersRaw = data['players'];
      final List<Map<String, dynamic>> currentPlayers = (playersRaw is List)
          ? playersRaw
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];

      if (currentPlayers.isEmpty) {
        if (lastEmptyTime == null) {
          lastEmptyTime = DateTime.now();
        } else {
          final difference = DateTime.now().difference(lastEmptyTime!);
          if (difference.inMinutes >= 2) {
            // Delete the session after 2 minutes of being empty
            await sessionRef.delete();
            timer.cancel();
            if (mounted) {
              setState(() {
                sessionCode = null;
                lastEmptyTime = null;
              });
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'تم حذف الجلسة',
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'تم حذف الجلسة لعدم وجود لاعبين',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                        ),
                        SizedBox(height: 20),
                        FFButtonWidget(
                          onPressed: () => Navigator.pop(context),
                          text: 'حسناً',
                          options: FFButtonOptions(
                            width: 120,
                            height: 40,
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).secondary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                ),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
        }
      } else {
        lastEmptyTime = null;
      }
    });
  }

  Future<void> createSession() async {
    if (isCreatingSession) return; // Prevent multiple clicks

    setState(() => isCreatingSession = true);

    try {
      // Generate session code first
      final newSessionCode =
          (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      // Prepare player data
      final playerData = {
        'uid': currentUserUid,
        'name': currentUserDisplayName ?? 'لاعب',
        'photoUrl': currentUserPhoto ?? '',
        'score': 0,
        'isReady': false,
        'usedFiftyFifty': false,
        'usedHint': false,
        'usedPoll': false,
        'usedSkip': false,
      };

      // Create session document
      final sessionRef = FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(newSessionCode);

      // Use batch write for better performance
      final batch = FirebaseFirestore.instance.batch();

      batch.set(sessionRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserUid,
        'status': 'waiting',
        'players': [playerData],
        'readyPlayers': [],
        'currentPlayerId': null,
        'currentQuestionIndex': 0,
        'questions': [],
      });

      // Commit the batch
      await batch.commit();

      // Update local state after successful creation
      if (mounted) {
        setState(() {
          sessionCode = newSessionCode;
          players = [playerData];
        });

        // Start listeners after state update
        _listenToSessionUpdates();
        _checkEmptySession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الجلسة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCreatingSession = false);
      }
    }
  }

  void _copySessionCode() {
    if (sessionCode != null) {
      Clipboard.setData(ClipboardData(text: sessionCode!));
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'تم النسخ',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12),
                Text(
                  'تم نسخ رقم الجلسة بنجاح',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
                SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () => Navigator.pop(context),
                  text: 'حسناً',
                  options: FFButtonOptions(
                    width: 120,
                    height: 40,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> joinSession() async {
    if (sessionCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('أدخل رمز الجلسة')));
      return;
    }
    setState(() => isJoiningSession = true);
    try {
      final sessionRef = FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(sessionCodeController.text);
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'خطأ',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'الجلسة غير موجودة',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                  ),
                  SizedBox(height: 20),
                  FFButtonWidget(
                    onPressed: () => Navigator.pop(context),
                    text: 'حسناً',
                    options: FFButtonOptions(
                      width: 120,
                      height: 40,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Colors.red,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Inter Tight',
                                color: Colors.white,
                              ),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        return;
      }
      final data = sessionDoc.data()!;
      if (data['status'] != 'waiting') throw Exception('الجلسة بدأت بالفعل');
      final List playersRaw = (data['players'] ?? []);
      if (!playersRaw.any((p) => p['uid'] == currentUserUid)) {
        await sessionRef.update({
          'players': FieldValue.arrayUnion([
            {
              'uid': currentUserUid,
              'name': currentUserDisplayName ?? 'لاعب',
              'photoUrl': currentUserPhoto ?? '',
              'score': 0,
              'isReady': false,
              'usedFiftyFifty': false,
              'usedHint': false,
              'usedPoll': false,
              'usedSkip': false,
            }
          ])
        });
      }
      sessionCode = sessionCodeController.text;
      _listenToSessionUpdates();
      _checkEmptySession(); // Start checking for empty session
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isJoiningSession = false);
    }
  }

  void _listenToSessionUpdates() {
    if (sessionCode == null) return;

    FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        if (mounted) {
          setState(() {
            sessionCode = null;
            isGameStarted = false;
            currentQuestionIndex = 0;
            questions = [];
            lastCorrectAnswer = null;
            removedChoices.clear();
            hintText = null;
            pollResult = null;
            usedFiftyFifty = false;
            usedHint = false;
            usedPoll = false;
            usedSkip = false;
          });
        }
        return;
      }

      if (!mounted) return;

      final data = snapshot.data()!;

      // Check if creator left
      if (data['createdBy'] == currentUserUid &&
          !players.any((p) => p['uid'] == currentUserUid)) {
        // Creator left, delete session immediately
        FirebaseFirestore.instance
            .collection('question_sessions')
            .doc(sessionCode)
            .delete();
        return;
      }

      setState(() {
        final playersRaw = data['players'];
        players = (playersRaw is List)
            ? playersRaw
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        isGameStarted = data['status'] == 'playing';
        currentPlayerId = data['currentPlayerId'];
        int newQuestionIndex = data['currentQuestionIndex'] ?? 0;
        questions = (data['questions'] is List)
            ? (data['questions'] as List)
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        isAnswering = currentPlayerId == currentUserUid;

        // Update help ways states from player data
        if (isAnswering) {
          final currentPlayer =
              players.firstWhere((p) => p['uid'] == currentUserUid);
          usedFiftyFifty = currentPlayer['usedFiftyFifty'] ?? false;
          usedHint = currentPlayer['usedHint'] ?? false;
          usedPoll = currentPlayer['usedPoll'] ?? false;
          usedSkip = currentPlayer['usedSkip'] ?? false;
        }

        // Shuffle options only when question changes
        if (questions.isNotEmpty &&
            (newQuestionIndex != currentQuestionIndex ||
                shuffledOptions.isEmpty)) {
          shuffledOptions =
              List<String>.from(questions[newQuestionIndex]['options']);
          shuffledOptions.shuffle();
        }
        currentQuestionIndex = newQuestionIndex;

        // Reset timer when question changes or when it's current player's turn
        if (isAnswering) {
          startTimer();
        } else {
          timer?.cancel();
        }
      });
    });
  }

  Future<void> toggleReady() async {
    try {
      final sessionRef = FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(sessionCode);
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) throw Exception('الجلسة غير موجودة');
      final data = sessionDoc.data()!;
      final playersRaw = data['players'];
      final List<Map<String, dynamic>> players = (playersRaw is List)
          ? playersRaw
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
      final playerIndex = players.indexWhere((p) => p['uid'] == currentUserUid);
      if (playerIndex == -1) throw Exception('لم يتم العثور على اللاعب');
      final newReady = !(players[playerIndex]['isReady'] ?? false);
      players[playerIndex]['isReady'] = newReady;
      await sessionRef.update({'players': players});
      if (newReady &&
          data['createdBy'] == currentUserUid &&
          players.length >= 2 &&
          players.every((p) => p['isReady'] == true)) {
        await _startGame(players);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في تحديث الجاهزية')));
    }
  }

  Future<void> _startGame(List<Map<String, dynamic>> players) async {
    try {
      final selectedQuestions =
          await _selectRandomQuestions(players.length * 5);
      await FirebaseFirestore.instance
          .collection('question_sessions')
          .doc(sessionCode)
          .update({
        'status': 'playing',
        'questions': selectedQuestions,
        'currentPlayerId': players[0]['uid'],
        'currentQuestionIndex': 0,
        'startedAt': FieldValue.serverTimestamp(),
      });
      startTimer(); // Start the timer when game begins
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في بدء اللعبة')));
    }
  }

  Future<List<Map<String, dynamic>>> _selectRandomQuestions(int count) async {
    final String jsonString =
        await rootBundle.loadString('assets/questions_arabic.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final allQuestions = jsonList.cast<Map<String, dynamic>>();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'لعبة الأسئلة عبر الإنترنت',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        centerTitle: true,
        elevation: 2,
        leading: sessionCode != null
            ? IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'تأكيد الخروج',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'هل أنت متأكد من الخروج من الجلسة؟',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FFButtonWidget(
                                  onPressed: () => Navigator.pop(context),
                                  text: 'إلغاء',
                                  options: FFButtonOptions(
                                    width: 100,
                                    height: 40,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                        ),
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                SizedBox(width: 12),
                                FFButtonWidget(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    leaveSession();
                                  },
                                  text: 'خروج',
                                  options: FFButtonOptions(
                                    width: 100,
                                    height: 40,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: Colors.red,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                        ),
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (sessionCode == null) ...[
                // Session creation/joining UI
                Text(
                  'اختر طريقة اللعب',
                  style: FlutterFlowTheme.of(context).headlineMedium,
                ),
                SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: createSession,
                  text: 'إنشاء جلسة جديدة',
                  icon: Icon(Icons.add_circle_outline),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'أو',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: sessionCodeController,
                  decoration: InputDecoration(
                    labelText: 'رمز الجلسة',
                    labelStyle:
                        FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: joinSession,
                  text: 'انضم إلى جلسة',
                  icon: Icon(Icons.login),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('question_sessions')
                        .doc(sessionCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      // Always show leaderboard if game is finished
                      if (data['status'] == 'finished') {
                        // Update local players list for leaderboard
                        final playersRaw = data['players'];
                        players = (playersRaw is List)
                            ? playersRaw
                                .map<Map<String, dynamic>>(
                                    (e) => Map<String, dynamic>.from(e))
                                .toList()
                            : [];
                        return _buildFinalLeaderboard();
                      }
                      // Show waiting room if not started
                      if (data['status'] == 'waiting' ||
                          !(data['status'] == 'playing')) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'رمز الجلسة: $sessionCode',
                                  style:
                                      FlutterFlowTheme.of(context).titleMedium,
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: _copySessionCode,
                                  tooltip: 'نسخ رمز الجلسة',
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'اللاعبون',
                              style: FlutterFlowTheme.of(context).titleMedium,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: players.length,
                                itemBuilder: (context, index) {
                                  final player = players[index];
                                  final playerName =
                                      player['name'] as String? ?? 'لاعب';
                                  final playerUid =
                                      player['uid'] as String? ?? '';
                                  final photoUrl =
                                      player['photoUrl'] as String? ?? '';
                                  final isReady = player['isReady'] ?? false;
                                  final isCreator = playerUid ==
                                      (data['createdBy'] as String? ?? '');
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      leading: (photoUrl.isNotEmpty)
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(photoUrl))
                                          : CircleAvatar(
                                              child: Icon(Icons.person)),
                                      title: Text(
                                        playerName,
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isReady)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                          if (isCreator)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: Icon(Icons.star,
                                                  color: Colors.amber),
                                            ),
                                          if (playerUid == currentUserUid &&
                                              !(data['status'] == 'playing'))
                                            FFButtonWidget(
                                              onPressed: toggleReady,
                                              text:
                                                  isReady ? 'غير جاهز' : 'جاهز',
                                              options: FFButtonOptions(
                                                width: 100,
                                                height: 36,
                                                color: isReady
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Inter Tight',
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                elevation: 2,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () {
                                if (players.length >= 2 &&
                                    players
                                        .every((p) => p['isReady'] == true)) {
                                  _startGame(players);
                                }
                              },
                              text: 'ابدأ اللعبة',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                    ),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        );
                      }
                      // Otherwise, show the game UI
                      return Column(
                        children: [
                          // Points counter container
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: players.map((player) {
                              return Column(
                                children: [
                                  Text(
                                    player['name'],
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'نقاط: ${player['score'] ?? 0}',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          // Question container with current player's profile
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Current player's turn indicator
                                Text(
                                  isAnswering
                                      ? 'دورك للإجابة'
                                      : 'دور ${players.firstWhere((p) => p['uid'] == currentPlayerId)['name']} للإجابة',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall,
                                ),
                                SizedBox(height: 12),
                                // Current player's profile picture
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    players.firstWhere((p) =>
                                            p['uid'] ==
                                            currentPlayerId)['photoUrl'] ??
                                        '',
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'سؤال ${currentQuestionIndex + 1} من ${questions.length}',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium,
                                    ),
                                    if (isAnswering)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              getTimerColor().withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: getTimerColor(),
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          '$timeLeft',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .copyWith(
                                                color: getTimerColor(),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  questions[currentQuestionIndex]['question'],
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Answer choices grid
                          Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 2.5,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                children: shuffledOptions
                                    .where((option) =>
                                        !removedChoices.contains(option))
                                    .map<Widget>((option) {
                                  return buildChoiceButton(
                                    option,
                                    lastCorrectAnswer,
                                    questions[currentQuestionIndex]['answer'],
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                              // Help ways container
                              Container(
                                decoration: BoxDecoration(
                                  color: darkenColor(
                                      FlutterFlowTheme.of(context).primary,
                                      0.02),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: darkenColor(
                                        FlutterFlowTheme.of(context).primary,
                                        0.10),
                                    width: 2,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // 50/50
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: usedFiftyFifty
                                            ? Colors.grey
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: usedFiftyFifty
                                            ? null
                                            : (isAnswering
                                                ? () => useFiftyFifty(
                                                    shuffledOptions,
                                                    questions[
                                                            currentQuestionIndex]
                                                        ['answer'])
                                                : () =>
                                                    showNotYourTurnDialog()),
                                        child: Center(
                                          child: Icon(
                                            Icons.filter_2,
                                            color: usedFiftyFifty
                                                ? Colors.white
                                                : Colors.blueAccent,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Hint
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: usedHint
                                            ? Colors.grey
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: usedHint
                                            ? null
                                            : (isAnswering
                                                ? () => useHint(questions[
                                                        currentQuestionIndex]
                                                    ['answer'])
                                                : () =>
                                                    showNotYourTurnDialog()),
                                        child: Center(
                                          child: Icon(
                                            Icons.lightbulb,
                                            color: usedHint
                                                ? Colors.white
                                                : FlutterFlowTheme.of(context)
                                                    .secondary,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Audience Poll
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: usedPoll
                                            ? Colors.grey
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: usedPoll
                                            ? null
                                            : (isAnswering
                                                ? () {
                                                    final answer = questions[
                                                            currentQuestionIndex]
                                                        ['answer'];
                                                    usePoll(shuffledOptions,
                                                        answer);
                                                  }
                                                : () =>
                                                    showNotYourTurnDialog()),
                                        child: Center(
                                          child: Icon(
                                            Icons.bar_chart,
                                            color: usedPoll
                                                ? Colors.white
                                                : Colors.deepPurple,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Skip
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: usedSkip
                                            ? Colors.grey
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: usedSkip
                                            ? null
                                            : (isAnswering
                                                ? () => useSkip()
                                                : () =>
                                                    showNotYourTurnDialog()),
                                        child: Center(
                                          child: Icon(
                                            Icons.skip_next,
                                            color: usedSkip
                                                ? Colors.white
                                                : Colors.teal,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalLeaderboard() {
    // Sort players by score in descending order
    final sortedPlayers = List<Map<String, dynamic>>.from(players)
      ..sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              FlutterFlowTheme.of(context).secondaryBackground,
            ],
          ),
        ),
        child: Column(
          children: [
            // Animated trophy icon
            TweenAnimationBuilder(
              duration: Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 60,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'النتيجة النهائية',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Leaderboard items with staggered animations
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500 + (index * 200)),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                            title: Text(
                              sortedPlayers[index]['name'],
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${sortedPlayers[index]['score'] ?? 0} نقطة',
                                style: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play again button
                FFButtonWidget(
                  onPressed: startNewGame,
                  text: 'العب مرة أخرى',
                  options: FFButtonOptions(
                    width: 160,
                    height: 50,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(width: 16),
                // Return to home button
                FFButtonWidget(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'العودة للرئيسية',
                  options: FFButtonOptions(
                    width: 160,
                    height: 50,
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> submitAnswer(String answer) async {
    if (!isAnswering) return;
    timer?.cancel(); // Cancel timer when answer is submitted
    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);
    final sessionDoc = await sessionRef.get();
    if (!sessionDoc.exists) return;
    final data = sessionDoc.data()!;
    final playersRaw = data['players'];
    final List<Map<String, dynamic>> players = (playersRaw is List)
        ? playersRaw
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList()
        : [];
    final playerIndex = players.indexWhere((p) => p['uid'] == currentUserUid);
    if (playerIndex != -1) {
      final isCorrect = answer == questions[currentQuestionIndex]['answer'];
      players[playerIndex]['score'] =
          (players[playerIndex]['score'] ?? 0) + (isCorrect ? 10 : 0);
      await sessionRef.update({'players': players});

      // Update lastCorrectAnswer for UI feedback
      setState(() {
        lastCorrectAnswer = answer;
      });

      // Wait for 2 seconds to show the feedback
      await Future.delayed(Duration(seconds: 2));

      // Reset the feedback state
      setState(() {
        lastCorrectAnswer = null;
        removedChoices.clear();
        hintText = null;
        pollResult = null;
        usedFiftyFifty = false;
        usedHint = false;
        usedPoll = false;
        usedSkip = false;
      });

      // Move to next player or end game
      final nextPlayerIndex = (playerIndex + 1) % players.length;
      if (currentQuestionIndex + 1 >= questions.length) {
        // End the game and show leaderboard
        await sessionRef.update({
          'status': 'finished',
          'endedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await sessionRef.update({
          'currentPlayerId': players[nextPlayerIndex]['uid'],
          'currentQuestionIndex': currentQuestionIndex + 1,
        });
      }
    }
  }

  Future<void> startNewGame() async {
    if (sessionCode == null) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    // Reset game state
    await sessionRef.update({
      'status': 'waiting',
      'currentPlayerId': null,
      'currentQuestionIndex': 0,
      'questions': [],
      'players': players
          .map((player) => {
                ...player,
                'score': 0,
                'isReady': false,
              })
          .toList(),
    });

    // Reset local state
    setState(() {
      isGameStarted = false;
      currentQuestionIndex = 0;
      questions = [];
      lastCorrectAnswer = null;
      removedChoices.clear();
      hintText = null;
      pollResult = null;
      usedFiftyFifty = false;
      usedHint = false;
      usedPoll = false;
      usedSkip = false;
    });
  }

  Future<void> useFiftyFifty(List<String> options, String answer) async {
    if (usedFiftyFifty || !isAnswering) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    try {
      await sessionRef.update({
        'players': players.map((player) {
          if (player['uid'] == currentUserUid) {
            return {...player, 'usedFiftyFifty': true};
          }
          return player;
        }).toList()
      });

      setState(() {
        usedFiftyFifty = true;
        removedChoices.clear();
        final wrongOptions = options.where((o) => o != answer).toList();
        wrongOptions.shuffle();
        removedChoices = wrongOptions.take(2).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في استخدام المساعدة')));
    }
  }

  Future<void> useHint(String answer) async {
    if (usedHint || !isAnswering) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    try {
      await sessionRef.update({
        'players': players.map((player) {
          if (player['uid'] == currentUserUid) {
            return {...player, 'usedHint': true};
          }
          return player;
        }).toList()
      });

      setState(() {
        usedHint = true;
        hintText = questions[currentQuestionIndex]['hint'];
      });

      // Show hint dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'تلميح',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12),
                Text(
                  hintText!,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
                SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () => Navigator.pop(context),
                  text: 'حسناً',
                  options: FFButtonOptions(
                    width: 120,
                    height: 40,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في استخدام المساعدة')));
    }
  }

  Future<void> usePoll(List<String> options, String answer) async {
    if (usedPoll || !isAnswering) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    try {
      await sessionRef.update({
        'players': players.map((player) {
          if (player['uid'] == currentUserUid) {
            return {...player, 'usedPoll': true};
          }
          return player;
        }).toList()
      });

      setState(() {
        usedPoll = true;
        pollResult = {};
        pollResult![answer] = 60; // Correct answer gets 60%
        final wrongs = options.where((o) => o != answer).toList();
        for (int i = 0; i < wrongs.length; i++) {
          pollResult![wrongs[i]] =
              (40 ~/ wrongs.length); // Distribute remaining 40%
        }
        if (wrongs.isNotEmpty)
          pollResult![wrongs.first] =
              pollResult![wrongs.first]! + (40 % wrongs.length);
      });

      // Show poll dialog with animation
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'استطلاع الجمهور',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 20),
                ...pollResult!.entries.map((e) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: e.value.toDouble()),
                    builder: (context, value, child) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.key,
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                                Text(
                                  '${value.toInt()}%',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value / 100,
                                backgroundColor:
                                    Colors.deepPurple.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
                SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () => Navigator.pop(context),
                  text: 'حسناً',
                  options: FFButtonOptions(
                    width: 120,
                    height: 40,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: Colors.deepPurple,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                        ),
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في استخدام المساعدة')));
    }
  }

  Future<void> useSkip() async {
    if (usedSkip || !isAnswering) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    try {
      await sessionRef.update({
        'players': players.map((player) {
          if (player['uid'] == currentUserUid) {
            return {...player, 'usedSkip': true};
          }
          return player;
        }).toList()
      });

      setState(() {
        usedSkip = true;
        lastCorrectAnswer = null;
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          removedChoices.clear();
          hintText = null;
          pollResult = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ في استخدام المساعدة')));
    }
  }

  void showNotYourTurnDialog() {
    final currentPlayerName =
        players.firstWhere((p) => p['uid'] == currentPlayerId)['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Text(
            'ليس دورك للإجابة',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: FlutterFlowTheme.of(context).primary,
              ),
              SizedBox(height: 16),
              Text(
                'انه دور $currentPlayerName',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: FFButtonWidget(
                onPressed: () => Navigator.pop(context),
                text: 'حسناً',
                options: FFButtonOptions(
                  width: 120,
                  height: 40,
                  color: FlutterFlowTheme.of(context).secondary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                      ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChoiceButton(
      String option, String? selectedAnswer, String correctAnswer) {
    bool isCorrect = option == correctAnswer;
    bool isSelected = selectedAnswer == option;
    Color backgroundColor = Colors.white;
    Color borderColor = FlutterFlowTheme.of(context).primary;
    Color textColor = FlutterFlowTheme.of(context).primary;

    if (selectedAnswer != null) {
      if (selectedAnswer == "_timeout_") {
        if (isCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green;
          textColor = Colors.green;
        }
      } else if (isSelected) {
        if (isCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green;
          textColor = Colors.green;
        } else {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red;
          textColor = Colors.red;
        }
      } else if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green;
      }
    }

    return Container(
      child: ElevatedButton(
        onPressed: selectedAnswer == null
            ? (isAnswering
                ? () => submitAnswer(option)
                : () => showNotYourTurnDialog())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
          elevation: 0,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: textColor,
        ),
        child: Text(
          option,
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Inter Tight',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Color darkenColor(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Future<void> leaveSession() async {
    if (sessionCode == null) return;

    final sessionRef = FirebaseFirestore.instance
        .collection('question_sessions')
        .doc(sessionCode);

    final sessionDoc = await sessionRef.get();
    if (!sessionDoc.exists) return;

    final data = sessionDoc.data()!;
    final isCreator = data['createdBy'] == currentUserUid;

    // If creator leaves, delete the session immediately
    if (isCreator) {
      await sessionRef.delete();
      if (mounted) {
        setState(() {
          sessionCode = null;
          isGameStarted = false;
          currentQuestionIndex = 0;
          questions = [];
          lastCorrectAnswer = null;
          removedChoices.clear();
          hintText = null;
          pollResult = null;
          usedFiftyFifty = false;
          usedHint = false;
          usedPoll = false;
          usedSkip = false;
        });
      }
      return;
    }

    // For non-creator players, just remove them from the session
    await sessionRef.update({
      'players': FieldValue.arrayRemove([
        {
          'uid': currentUserUid,
          'name': currentUserDisplayName ?? 'لاعب',
          'photoUrl': currentUserPhoto ?? '',
          'score': 0,
          'isReady': false,
          'usedFiftyFifty': false,
          'usedHint': false,
          'usedPoll': false,
          'usedSkip': false,
        }
      ])
    });

    if (mounted) {
      setState(() {
        sessionCode = null;
      });
    }
  }
}
