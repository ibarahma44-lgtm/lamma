import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/join_family_widget.dart';

import 'family_not_found_model.dart';
export 'family_not_found_model.dart';

/// make a family not found with a message that you don't belong to a family
/// yet and it has a create family button or join family make it as a pop up
/// message and add a error icon
class FamilyNotFoundWidget extends StatefulWidget {
  const FamilyNotFoundWidget({super.key});

  @override
  State<FamilyNotFoundWidget> createState() => _FamilyNotFoundWidgetState();
}

class _FamilyNotFoundWidgetState extends State<FamilyNotFoundWidget> {
  late FamilyNotFoundModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyNotFoundModel());

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
        padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
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
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.family_restroom,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 64,
                ),
                Text(
                  'Family Not Found',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  'You don\'t belong to a family yet. Create a new family or join an existing one.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FFButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                        context.pushNamed('FamilyCreation');
                      },
                      text: 'Create Family',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48,
                        padding: EdgeInsets.all(8),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).secondary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              elevation: 0,
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: AlignmentDirectional(0.0, 0.0)
                                  .resolve(Directionality.of(context)),
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(dialogContext).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: JoinFamilyWidget(),
                              ),
                            );
                          },
                        );
                      },
                      text: 'Join Family',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48,
                        padding: EdgeInsets.all(8),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ].divide(SizedBox(height: 12)),
                ),
              ].divide(SizedBox(height: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
