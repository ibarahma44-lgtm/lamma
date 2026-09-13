import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/components/join_family_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'family_dashboard_model.dart';
import '/family_information/family_information_widget.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_navbar.dart';
export 'family_dashboard_model.dart';

class FamilyDashboardWidget extends StatefulWidget {
  const FamilyDashboardWidget({
    super.key,
    this.familyRef,
  });

  static String routeName = 'FamilyDashboard';
  static String routePath = '/family-dashboard';

  final DocumentReference? familyRef;

  @override
  State<FamilyDashboardWidget> createState() => _FamilyDashboardWidgetState();
}

class _FamilyDashboardWidgetState extends State<FamilyDashboardWidget> {
  late FamilyDashboardModel _model;
  int _selectedIndex = 5; // Changed from 1 to 5 so no icon is highlighted

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).secondary,
                size: 32.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Inter Tight',
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
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
            'Family Dashboard',
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
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        title: 'Family Info',
                        icon: Icons.info_outline,
                        onTap: () async {
                          final userFamilies = await queryFamiliesRecordOnce(
                            queryBuilder: (q) => q.where('members',
                                arrayContains: currentUserUid),
                            limit: 1,
                          );

                          if (userFamilies.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please join or create a family first!',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                      ),
                                ),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            );
                            return;
                          }

                          context.pushNamed(
                            FamilyInformationWidget.routeName,
                            queryParameters: {
                              'familyRef': serializeParam(
                                userFamilies.first,
                                ParamType.Document,
                              ),
                            }.withoutNulls,
                            extra: <String, dynamic>{
                              'familyRef': userFamilies.first,
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildCard(
                        title: 'Create Family',
                        icon: Icons.add_home,
                        onTap: () async {
                          context.pushNamed('FamilyCreation');
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        title: 'Join Family',
                        icon: Icons.group_add,
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                child: JoinFamilyWidget(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Container(), // Empty container for grid symmetry
                    ),
                  ],
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
