import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/services/storage_service.dart';

import 'familydeletion_model.dart';
export 'familydeletion_model.dart';

/// make a confirmation pop up message for family deletion
class FamilydeletionWidget extends StatefulWidget {
  const FamilydeletionWidget({
    super.key,
    required this.familyRef,
    required this.photoUrl,
  });

  final DocumentReference familyRef;
  final String photoUrl;

  @override
  State<FamilydeletionWidget> createState() => _FamilydeletionWidgetState();
}

class _FamilydeletionWidgetState extends State<FamilydeletionWidget> {
  late FamilydeletionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilydeletionModel());

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
          width: double.infinity,
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
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: FlutterFlowTheme.of(context).error,
                  size: 60,
                ),
                Text(
                  'Delete Family?',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  'Are you sure you want to delete this family? ',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'Cancel',
                      options: FFButtonOptions(
                        width: 120,
                        height: 50,
                        padding: EdgeInsets.all(8),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                        elevation: 0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () async {
                        // Delete the family avatar if it exists
                        if (widget.photoUrl.isNotEmpty) {
                          await StorageService.deleteFamilyAvatar(
                              widget.familyRef.id);
                        }
                        // Delete the family document
                        await widget.familyRef.delete();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Family deleted successfully'),
                            backgroundColor:
                                FlutterFlowTheme.of(context).success,
                          ),
                        );
                      },
                      text: 'Delete',
                      options: FFButtonOptions(
                        width: 120,
                        height: 50,
                        padding: EdgeInsets.all(8),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).error,
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
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ].divide(SizedBox(width: 16)),
                ),
              ].divide(SizedBox(height: 24)),
            ),
          ),
        ),
      ),
    );
  }
}
