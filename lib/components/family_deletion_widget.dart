import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamma/services/storage_service.dart';

import 'family_deletion_model.dart';
export 'family_deletion_model.dart';

class FamilyDeletionWidget extends StatefulWidget {
  const FamilyDeletionWidget({
    super.key,
    required this.familyRef,
  });

  final FamiliesRecord? familyRef;

  @override
  State<FamilyDeletionWidget> createState() => _FamilyDeletionWidgetState();
}

class _FamilyDeletionWidgetState extends State<FamilyDeletionWidget> {
  late FamilyDeletionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyDeletionModel());

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
                  Icons.warning_rounded,
                  color: FlutterFlowTheme.of(context).error,
                  size: 64,
                ),
                Text(
                  'Delete Family',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).error,
                        letterSpacing: 0.0,
                      ),
                ),
                Text(
                  'Are you sure you want to delete this family? This action cannot be undone.',
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
                      onPressed: () async {
                        // Delete the family's chat history
                        final chatCollection = FirebaseFirestore.instance
                            .collection('families')
                            .doc(widget.familyRef?.reference.id)
                            .collection('chat');

                        // Get all chat messages
                        final chatMessages = await chatCollection.get();

                        // Delete each message
                        for (var doc in chatMessages.docs) {
                          await doc.reference.delete();
                        }

                        // Delete typing status collection
                        final typingCollection = FirebaseFirestore.instance
                            .collection('families')
                            .doc(widget.familyRef?.reference.id)
                            .collection('typing_status');

                        final typingStatus = await typingCollection.get();
                        for (var doc in typingStatus.docs) {
                          await doc.reference.delete();
                        }

                        // Delete the family avatar if it exists
                        if (widget.familyRef?.photoUrl.isNotEmpty ?? false) {
                          await StorageService.deleteFamilyAvatar(
                              widget.familyRef!.reference.id);
                        }

                        // Delete the family
                        await widget.familyRef?.reference.delete();

                        // Close the dialog
                        Navigator.pop(context);

                        // Show success snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Family and chat history deleted successfully'),
                            backgroundColor:
                                FlutterFlowTheme.of(context).success,
                          ),
                        );

                        // Navigate to home page
                        context.pushNamed('home');
                      },
                      text: 'Delete Family',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48,
                        padding: EdgeInsets.all(8),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).error,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
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
                      },
                      text: 'Cancel',
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
