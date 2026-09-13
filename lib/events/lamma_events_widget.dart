import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lamma_events_model.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_navbar.dart';
import '../screens/meal_planner_screen.dart';
import '../screens/library_screen.dart';
import '../screens/family_notes_screen.dart';
import 'live_stream_screen.dart';
export 'lamma_events_model.dart';

class LammaEventsWidget extends StatefulWidget {
  const LammaEventsWidget({
    super.key,
    this.familyRef,
  });

  static String routeName = 'LammaEvents';
  static String routePath = '/lamma-events';

  final DocumentReference? familyRef;

  @override
  State<LammaEventsWidget> createState() => _LammaEventsWidgetState();
}

class _LammaEventsWidgetState extends State<LammaEventsWidget> {
  late LammaEventsModel _model;
  int _selectedIndex =
      4; // Changed from 3 to 4 so profile border only on profile page

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LammaEventsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
            'Lamma Events',
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      'EventsList',
                      queryParameters: {
                        'familyRef': serializeParam(
                          widget.familyRef,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                      extra: <String, dynamic>{
                        'familyRef': widget.familyRef,
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.event_note_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 28.0,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Event Scheduler',
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Manage your family events, set reminders, and keep track of important dates',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 400;
                              return Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                direction:
                                    isNarrow ? Axis.vertical : Axis.horizontal,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Schedule Events',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Assign Members',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Movie Night Feature
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.movie_creation_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 44),
                              SizedBox(height: 12),
                              Text(
                                'Family Movie Night',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'What would you like to do?',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context.pushNamed(
                                          'MovieNight',
                                          extra: <String, dynamic>{
                                            'familyRef': widget.familyRef,
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Plan a Movie Night',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context.pushNamed(
                                          'MovieNightsList',
                                          extra: <String, dynamic>{
                                            'familyRef': widget.familyRef,
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Show Planned Movie Nights',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
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
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.movie_creation_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 28.0,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Family Movie Night',
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Plan movie nights with your family, select movies, and organize snacks',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 400;
                              return Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                direction:
                                    isNarrow ? Axis.vertical : Axis.horizontal,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.movie,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Select Movies',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_dining,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Plan Snacks',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // More features can be added here in the future
              // Such as Games section, Event Templates, etc.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LiveStreamScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.live_tv,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 28.0,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Live Stream 📺',
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Watch live news channels',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 16.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Watch Now',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealPlannerScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28.0,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🍽️ Plan a Meal',
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Plan your family meals and track nutrition',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LibraryScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '📚',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Library',
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Browse and read books or novels with your family.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FamilyNotesScreen(
                          familyRef: widget.familyRef,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.note_alt_outlined,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28.0,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Family Notes',
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Share and collaborate on notes with your family members',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
