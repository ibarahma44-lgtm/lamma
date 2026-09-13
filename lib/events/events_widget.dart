import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/event_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'events_model.dart';
import 'add_event_dialog.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_navbar.dart';
export 'events_model.dart';

class EventsWidget extends StatefulWidget {
  const EventsWidget({
    super.key,
    this.familyRef,
  });

  static String routeName = 'Events';
  static String routePath = '/events';

  final DocumentReference? familyRef;

  @override
  State<EventsWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  late EventsModel _model;
  int _selectedIndex =
      4; // Changed from 3 to 4 so profile border only on profile page
  bool _isLoading = true;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EventsModel());
    _model.selectedTab = 'upcoming';
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(EventsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.familyRef != widget.familyRef) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void dispose() {
    _model.maybeDispose();
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
          automaticallyImplyLeading: true,
          title: Text(
            'Family Events',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              transform: _model.selectedTab == 'upcoming'
                                  ? Matrix4.translationValues(0, -6, 0)
                                  : Matrix4.identity(),
                              child: FFButtonWidget(
                                onPressed: () {
                                  setState(
                                      () => _model.selectedTab = 'upcoming');
                                },
                                text: 'Upcoming',
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: _model.selectedTab == 'upcoming'
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              transform: _model.selectedTab == 'completed'
                                  ? Matrix4.translationValues(0, -6, 0)
                                  : Matrix4.identity(),
                              child: FFButtonWidget(
                                onPressed: () {
                                  setState(
                                      () => _model.selectedTab = 'completed');
                                },
                                text: 'Completed',
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: _model.selectedTab == 'completed'
                                      ? FlutterFlowTheme.of(context).secondary
                                      : FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: EventListWidget(
                          familyRef: widget.familyRef,
                          status: _model.selectedTab,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: widget.familyRef != null
            ? FloatingActionButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AddEventDialog(
                      familyRef: widget.familyRef!,
                    ),
                  );
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
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
