import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'code_copied_model.dart';
export 'code_copied_model.dart';

/// do me a code copied message with transpert background
class CodeCopiedWidget extends StatefulWidget {
  const CodeCopiedWidget({super.key});

  @override
  State<CodeCopiedWidget> createState() => _CodeCopiedWidgetState();
}

class _CodeCopiedWidgetState extends State<CodeCopiedWidget> {
  late CodeCopiedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CodeCopiedModel());

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
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(
                  0.0,
                  2.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code Copied!',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'The code has been copied to your clipboard and is ready to use in your project.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primary,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ),
                Icon(
                  Icons.check_circle_rounded,
                  color: FlutterFlowTheme.of(context).secondary,
                  size: 32.0,
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ),
        ),
      ),
    );
  }
}
