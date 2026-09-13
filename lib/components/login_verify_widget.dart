import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'login_verify_model.dart';
export 'login_verify_model.dart';

/// make a pop up message for login page that when i try to login without
/// verify it says that your account is not verified and give it a nice
/// message to make user verify and add for it a resend verification button
/// and cancel button
class LoginVerifyWidget extends StatefulWidget {
  const LoginVerifyWidget({super.key});

  @override
  State<LoginVerifyWidget> createState() => _LoginVerifyWidgetState();
}

class _LoginVerifyWidgetState extends State<LoginVerifyWidget> {
  late LoginVerifyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginVerifyModel());

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
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(
                0,
                2,
              ),
              spreadRadius: 0,
            )
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: FlutterFlowTheme.of(context).error,
                size: 48,
              ),
              Text(
                'Account Not Verified',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primary,
                      letterSpacing: 0.0,
                    ),
              ),
              Text(
                'Your account requires email verification before you can log in. Please check your inbox for the verification link we sent you.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).primary,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: FFButtonWidget(
                  onPressed: () async {
                    await authManager.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Verification email has been resent!',
                          style:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).info,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        duration: Duration(milliseconds: 4000),
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                    );
                  },
                  text: 'Resend Verification Email',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: FFButtonWidget(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancel',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 44,
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0,
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ].divide(SizedBox(height: 16)),
          ),
        ),
      ),
    );
  }
}
