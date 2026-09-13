import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/account_profile_creation/auth_2_login/auth2_login_widget.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'email_verify_model.dart';
export 'email_verify_model.dart';

/// make a pop up message for email verification
class EmailVerifyWidget extends StatefulWidget {
  const EmailVerifyWidget({super.key});

  @override
  State<EmailVerifyWidget> createState() => _EmailVerifyWidgetState();
}

class _EmailVerifyWidgetState extends State<EmailVerifyWidget> {
  late EmailVerifyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailVerifyModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              color: FlutterFlowTheme.of(context).secondary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Verify Your Email',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Inter Tight',
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'ve sent a verification link to your email address. Please check your inbox and click the link to complete your registration.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: Colors.black54,
                    fontSize: 14,
                  ),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: FFButtonWidget(
                onPressed: () async {
                  await authManager.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Verification email has been resent!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                      duration: Duration(seconds: 4),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                  elevation: 0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: FFButtonWidget(
                onPressed: () async {
                  // Navigate to login page when cancel is pressed
                  Navigator.pop(context);
                  context.pushNamed(Auth2LoginWidget.routeName);
                },
                text: 'Cancel',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 44,
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: Colors.white,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                  elevation: 0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
