import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'auth_error_dialog_model.dart';
export 'auth_error_dialog_model.dart';

class AuthErrorDialog extends StatefulWidget {
  const AuthErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.iconColor,
    this.iconBackgroundColor,
    this.titleColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? titleColor;

  @override
  State<AuthErrorDialog> createState() => _AuthErrorDialogState();
}

class _AuthErrorDialogState extends State<AuthErrorDialog> {
  late AuthErrorDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthErrorDialogModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor ?? Color(0xFFFFE6E6),
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: AlignmentDirectional(0, 0),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? FlutterFlowTheme.of(context).error,
                  size: 50,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        color: widget.titleColor ??
                            FlutterFlowTheme.of(context).error,
                        letterSpacing: 0,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 24),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0,
                      ),
                ),
              ),
              FFButtonWidget(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'OK',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 44,
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: FlutterFlowTheme.of(context).secondary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                  elevation: 3,
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
