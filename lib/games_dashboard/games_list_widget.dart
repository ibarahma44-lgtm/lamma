import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'games_list_model.dart';
import '/game/stranger_game_model.dart';
import '/game/stranger_game_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_navbar.dart';
import '../questionsgame_page/questionsgame_page_widget.dart';
import '../questionsgame_page/questions_game_session_page.dart';
export 'games_list_model.dart';

class GamesListWidget extends StatefulWidget {
  const GamesListWidget({
    super.key,
    this.familyRef,
  });

  static String routeName = 'GamesList';
  static String routePath = '/games-list';

  final DocumentReference? familyRef;

  @override
  State<GamesListWidget> createState() => _GamesListWidgetState();
}

class _GamesListWidgetState extends State<GamesListWidget> {
  late GamesListModel _model;
  final strangerGameModel = StrangerGameModel();
  int _selectedIndex =
      1; // Changed from 5 to 1 to match navbar games icon index

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    if (index == _selectedIndex)
      return; // Don't navigate if already on this page

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.pushNamed('Home');
        break;
      case 1:
        // Already on Games page
        break;
      case 2:
        context.pushNamed('WheelOfChores');
        break;
      case 3:
        context.pushNamed('Events');
        break;
      case 4:
        context.pushNamed('FamilyChat');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GamesListModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _navigateToStrangerGame(BuildContext context) async {
    // Get the user's family
    final userFamilies = await queryFamiliesRecordOnce(
      queryBuilder: (q) => q.where('members', arrayContains: currentUserUid),
      limit: 1,
    );

    if (userFamilies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب الانضمام إلى عائلة أولاً')),
      );
      return;
    }

    final familyId = userFamilies.first.reference.id;

    // Navigate to the game page without creating a game
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrangerGameWidget(
          familyId: familyId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'الالعاب',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).info,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                    children: [
                      // لعبة الاسئلة
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'اختر وضع اللعب',
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuestionsGameSessionPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 12),
                                        margin: EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'اللعب عبر الانترنت',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    fontFamily: 'Inter Tight',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'تحتاج إلى لاعبين أو أكثر',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    fontFamily: 'Inter Tight',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuestionsgamePageWidget(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondary
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              width: 1.5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'اللعب بدون إنترنت',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    fontFamily: 'Inter Tight',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'تحتاج الى لاعبين بالضبط',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    fontFamily: 'Inter Tight',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8.0,
                                color: Color(0x1A000000),
                                offset: Offset(0.0, 4.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.quiz,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 32.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Text(
                                  'لعبة الاسئلة',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // لعبة جوالك على راسك
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          // TODO: Navigate to phone game
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8.0,
                                color: Color(0x1A000000),
                                offset: Offset(0.0, 4.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone_android,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 32.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Text(
                                  'لعبة جوالك على راسك',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // لعبة الغريب
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _navigateToStrangerGame(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8.0,
                                color: Color(0x1A000000),
                                offset: Offset(0.0, 4.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_off,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 32.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Text(
                                  'لعبة الغريب',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ModernNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          onFABPressed: () {
            context.pushNamed('FamilyCreation');
          },
        ),
      ),
    );
  }
}
