// التصميم المطور
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'questionsgame_page_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'questions_game_session_page.dart';
import '../services/sound_service.dart';

class QuestionsgamePageWidget extends StatefulWidget {
  const QuestionsgamePageWidget({super.key});

  static String routeName = 'questionsgamePage';
  static String routePath = '/questionsgamePage';

  @override
  State<QuestionsgamePageWidget> createState() =>
      _QuestionsgamePageWidgetState();
}

class _QuestionsgamePageWidgetState extends State<QuestionsgamePageWidget>
    with SingleTickerProviderStateMixin {
  late QuestionsgamePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  final SoundService _soundService = SoundService();

  int currentQuestionIndex = 0;
  int currentPlayer = 1;
  int player1Score = 0;
  int player2Score = 0;
  int player1Correct = 0;
  int player2Correct = 0;
  int timeLeft = 30;
  Timer? timer;
  bool gameEnded = false;
  String? lastCorrectAnswer;
  List<int> questionOrder = [];

  String player1Name = 'اللاعب 1';
  String player2Name = 'اللاعب 2';

  // Separate help ways for each player
  bool player1UsedFiftyFifty = false;
  bool player1UsedHint = false;
  bool player1UsedPoll = false;
  bool player1UsedSkip = false;
  bool player2UsedFiftyFifty = false;
  bool player2UsedHint = false;
  bool player2UsedPoll = false;
  bool player2UsedSkip = false;
  List<String> removedChoices = [];
  String? hintText;
  Map<String, int>? pollResult;

  List<Map<String, dynamic>> questions = [];
  List<String> shuffledOptions = [];

  Future<List<Map<String, dynamic>>> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions_arabic.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuestionsgamePageModel());
    _countdownController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _countdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _countdownController,
        curve: Curves.easeInOut,
      ),
    );
    loadQuestions().then((loadedQuestions) {
      setState(() {
        // Shuffle and pick only 10 questions
        loadedQuestions.shuffle();
        questions = loadedQuestions.take(10).toList();
        questionOrder = List.generate(questions.length, (index) => index);
        // Initialize shuffledOptions for the first question
        if (questions.isNotEmpty) {
          shuffledOptions =
              List<String>.from(questions[questionOrder[0]]['options']);
          shuffledOptions.shuffle();
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        askPlayerNames();
      });
    });
  }

  void askPlayerNames() async {
    final playerNames = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        String p1 = '';
        String p2 = '';
        return AlertDialog(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'أدخل أسماء اللاعبين',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'اسم اللاعب الأول',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => p1 = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'اسم اللاعب الثاني',
                  labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => p2 = value,
              ),
            ],
          ),
          actions: [
            Center(
              child: FFButtonWidget(
                onPressed: () => Navigator.pop(context, [p1, p2]),
                text: 'ابدأ',
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
            ),
          ],
        );
      },
    );

    if (playerNames != null) {
      setState(() {
        player1Name = playerNames[0].isEmpty ? 'اللاعب 1' : playerNames[0];
        player2Name = playerNames[1].isEmpty ? 'اللاعب 2' : playerNames[1];
        startTimer();
      });
    }
  }

  void startTimer() {
    timeLeft = 30;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 10) {
            _countdownController.forward(from: 0.0);
          }
        });
      } else {
        checkAnswer(null);
      }
    });
  }

  void checkAnswer(String? selected) {
    timer?.cancel();
    final correctAnswer =
        questions[questionOrder[currentQuestionIndex]]['answer'];
    setState(() {
      if (selected == null) {
        lastCorrectAnswer = "_timeout_";
      } else {
        lastCorrectAnswer = selected;
      }
      removedChoices.clear();
      hintText = null;
      pollResult = null;
    });

    bool isCorrect = (selected == correctAnswer);

    if (isCorrect) {
      SoundService().playWinSound();
      setState(() {
        if (currentPlayer == 1) {
          player1Score += 10;
          player1Correct++;
        } else {
          player2Score += 10;
          player2Correct++;
        }
      });
    }

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          currentPlayer = currentPlayer == 1 ? 2 : 1;
          lastCorrectAnswer = null;
          removedChoices.clear();
          hintText = null;
          pollResult = null;
          // Shuffle options for the new question
          shuffledOptions = List<String>.from(
              questions[questionOrder[currentQuestionIndex]]['options']);
          shuffledOptions.shuffle();
          startTimer();
        } else {
          gameEnded = true;
        }
      });
    });
  }

  void restartGame() {
    setState(() {
      currentQuestionIndex = 0;
      currentPlayer = 1;
      player1Score = 0;
      player2Score = 0;
      player1Correct = 0;
      player2Correct = 0;
      gameEnded = false;
      lastCorrectAnswer = null;
      questionOrder = List.generate(questions.length, (index) => index);
      // Reset help ways for both players
      player1UsedFiftyFifty = false;
      player1UsedHint = false;
      player1UsedPoll = false;
      player1UsedSkip = false;
      player2UsedFiftyFifty = false;
      player2UsedHint = false;
      player2UsedPoll = false;
      player2UsedSkip = false;
      removedChoices.clear();
      hintText = null;
      pollResult = null;
      // Shuffle options for the first question
      if (questions.isNotEmpty) {
        shuffledOptions =
            List<String>.from(questions[questionOrder[0]]['options']);
        shuffledOptions.shuffle();
      }
      startTimer();
    });
  }

  void useFiftyFifty(List<String> options, String answer) {
    if (currentPlayer == 1 && player1UsedFiftyFifty) return;
    if (currentPlayer == 2 && player2UsedFiftyFifty) return;

    setState(() {
      if (currentPlayer == 1) {
        player1UsedFiftyFifty = true;
      } else {
        player2UsedFiftyFifty = true;
      }
      removedChoices.clear();
      final wrongOptions = options.where((o) => o != answer).toList();
      wrongOptions.shuffle();
      removedChoices = wrongOptions.take(2).toList();
    });
  }

  void useHint(String answer) {
    if (currentPlayer == 1 && player1UsedHint) return;
    if (currentPlayer == 2 && player2UsedHint) return;

    setState(() {
      if (currentPlayer == 1) {
        player1UsedHint = true;
      } else {
        player2UsedHint = true;
      }
      hintText = questions[questionOrder[currentQuestionIndex]]['hint'];
    });
  }

  void usePoll(List<String> options, String answer) {
    if (currentPlayer == 1 && player1UsedPoll) return;
    if (currentPlayer == 2 && player2UsedPoll) return;

    setState(() {
      if (currentPlayer == 1) {
        player1UsedPoll = true;
      } else {
        player2UsedPoll = true;
      }
      pollResult = {};
      pollResult![answer] = 60;
      final wrongs = options.where((o) => o != answer).toList();
      for (int i = 0; i < wrongs.length; i++) {
        pollResult![wrongs[i]] = (40 ~/ wrongs.length);
      }
      if (wrongs.isNotEmpty)
        pollResult![wrongs.first] =
            pollResult![wrongs.first]! + (40 % wrongs.length);
    });
  }

  void useSkip() {
    if (currentPlayer == 1 && player1UsedSkip) return;
    if (currentPlayer == 2 && player2UsedSkip) return;

    setState(() {
      if (currentPlayer == 1) {
        player1UsedSkip = true;
      } else {
        player2UsedSkip = true;
      }
      lastCorrectAnswer = null;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        removedChoices.clear();
        hintText = null;
        pollResult = null;
        startTimer();
      } else {
        gameEnded = true;
      }
    });
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _model.dispose();
    timer?.cancel();
    super.dispose();
  }

  Color getTimerColor() {
    // Start with orange (30 seconds) and gradually change to red (0 seconds)
    if (timeLeft > 20) {
      return Colors.orange;
    } else if (timeLeft > 10) {
      // Mix orange and red for middle range
      return Color.lerp(Colors.orange, Colors.red, (20 - timeLeft) / 10)!;
    } else {
      return Colors.red;
    }
  }

  Color darkenColor(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  String cleanQuestionText(String question) {
    // Keeps everything up to and including the first question mark
    final idx = question.indexOf('؟');
    if (idx != -1) {
      return question.substring(0, idx + 1);
    }
    return question;
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final question = questions[questionOrder[currentQuestionIndex]];
    final answer = question['answer'] as String;
    final filteredOptions =
        shuffledOptions.where((o) => !removedChoices.contains(o)).toList();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        child: gameEnded
            ? _buildFinalLeaderboard()
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    player1Name,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'نقاط: $player1Score',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'الوقت',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _soundService.isMuted ? Icons.volume_off : Icons.volume_up,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _soundService.toggleMute();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$timeLeft ثانية',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: getTimerColor(),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    player2Name,
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'نقاط: $player2Score',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'سؤال ${currentQuestionIndex + 1} من 10',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                        const SizedBox(height: 12),
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
                          child: Text(
                            cleanQuestionText(question['question']),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'دور ${currentPlayer == 1 ? player1Name : player2Name} للإجابة',
                          style: FlutterFlowTheme.of(context).headlineSmall,
                        ),
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.5,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: filteredOptions.map((opt) {
                            return buildChoiceButton(
                                opt, lastCorrectAnswer, answer);
                          }).toList(),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: darkenColor(
                                  FlutterFlowTheme.of(context).primary, 0.02),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: darkenColor(
                                    FlutterFlowTheme.of(context).primary, 0.10),
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 50/50
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: (currentPlayer == 1 &&
                                                player1UsedFiftyFifty) ||
                                            (currentPlayer == 2 &&
                                                player2UsedFiftyFifty)
                                        ? null
                                        : () => useFiftyFifty(
                                            shuffledOptions, answer),
                                    child: Center(
                                      child: Icon(
                                        Icons.filter_2,
                                        color: (currentPlayer == 1 &&
                                                    player1UsedFiftyFifty) ||
                                                (currentPlayer == 2 &&
                                                    player2UsedFiftyFifty)
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
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: (currentPlayer == 1 &&
                                                player1UsedHint) ||
                                            (currentPlayer == 2 &&
                                                player2UsedHint)
                                        ? null
                                        : () => useHint(answer),
                                    child: Center(
                                      child: Icon(
                                        Icons.lightbulb,
                                        color: (currentPlayer == 1 &&
                                                    player1UsedHint) ||
                                                (currentPlayer == 2 &&
                                                    player2UsedHint)
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
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: (currentPlayer == 1 &&
                                                player1UsedPoll) ||
                                            (currentPlayer == 2 &&
                                                player2UsedPoll)
                                        ? null
                                        : () =>
                                            usePoll(shuffledOptions, answer),
                                    child: Center(
                                      child: Icon(
                                        Icons.bar_chart,
                                        color: (currentPlayer == 1 &&
                                                    player1UsedPoll) ||
                                                (currentPlayer == 2 &&
                                                    player2UsedPoll)
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
                                    color: FlutterFlowTheme.of(context).primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: (currentPlayer == 1 &&
                                                player1UsedSkip) ||
                                            (currentPlayer == 2 &&
                                                player2UsedSkip)
                                        ? null
                                        : () => useSkip(),
                                    child: Center(
                                      child: Icon(
                                        Icons.skip_next,
                                        color: (currentPlayer == 1 &&
                                                    player1UsedSkip) ||
                                                (currentPlayer == 2 &&
                                                    player2UsedSkip)
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
                        ),
                        if (hintText != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(hintText!,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .copyWith(
                                        color: FlutterFlowTheme.of(context)
                                            .secondary)),
                          ),
                        if (pollResult != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              children: pollResult!.entries
                                  .map((e) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('${e.key}: ',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall),
                                          Container(
                                            width: e.value.toDouble() * 2,
                                            height: 10,
                                            color: Colors.deepPurple
                                                .withOpacity(0.5),
                                          ),
                                          SizedBox(width: 8),
                                          Text('${e.value}%',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (timeLeft <= 10)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 170,
                      child: FadeTransition(
                        opacity: _countdownAnimation,
                        child: Text(
                          '$timeLeft',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Inter Tight',
                                color: Color(0xFFFF0000),
                                fontWeight: FontWeight.bold,
                                fontSize: 56,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildFinalLeaderboard() {
    // Sort players by score in descending order
    final sortedPlayers = List<Map<String, dynamic>>.from([
      {'name': player1Name, 'score': player1Score},
      {'name': player2Name, 'score': player2Score},
    ]).toList();
    sortedPlayers.sort((a, b) => b['score'].compareTo(a['score']));

    return Container(
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
          ...List.generate(sortedPlayers.length, (index) {
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.1)
                            : FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        trailing: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${sortedPlayers[index]['score']} نقطة',
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
                  ),
                );
              },
            );
          }),
          SizedBox(height: 20),
          // Animated buttons
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionsgamePageWidget(),
                              ),
                            );
                          },
                          icon: Icon(Icons.refresh_rounded),
                          label: Text('لعبة جديدة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuestionsGameSessionPage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.home_rounded),
                          label: Text('العودة للرئيسية'),
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
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildChoiceButton(
      String option, String? selectedAnswer, String correctAnswer) {
    bool isSelected = option == selectedAnswer;
    bool isCorrect = option == correctAnswer;
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
        onPressed: selectedAnswer == null ? () => checkAnswer(option) : null,
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
}
