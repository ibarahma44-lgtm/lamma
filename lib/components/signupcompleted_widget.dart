import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'signupcompleted_model.dart';
export 'signupcompleted_model.dart';

/// make a sign up completed message with a cool design and nice icons
class SignupcompletedWidget extends StatefulWidget {
  const SignupcompletedWidget({super.key});

  @override
  State<SignupcompletedWidget> createState() => _SignupcompletedWidgetState();
}

class _SignupcompletedWidgetState extends State<SignupcompletedWidget> {
  late SignupcompletedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignupcompletedModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Color(0x1A000000),
                offset: Offset(
                  0.0,
                  2.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFE6F5FF),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: FlutterFlowTheme.of(context).secondary,
                    size: 50.0,
                  ),
                ),
                Text(
                  'Sign Up Complete!',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  'Your account has been successfully created. Welcome to our community!',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.person_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                    ),
                    Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                    ),
                  ].divide(SizedBox(width: 16.0)),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    context.pushNamed(Auth2CreateProfileWidget.routeName);
                  },
                  text: 'Create Profile',
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: FlutterFlowTheme.of(context).info,
                    size: 15.0,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ),
      ),
    );
  }
}
