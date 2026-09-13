import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'family_creation_model.dart';
import 'dart:convert';
import '/services/storage_service.dart';
export 'family_creation_model.dart';

/// Returns the first family where this user is an admin, or null.
Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserFamily(
    String uid) async {
  final q = await FirebaseFirestore.instance
      .collection('families')
      .where('admin_roles', arrayContains: uid)
      .limit(1)
      .get();
  return q.docs.isEmpty ? null : q.docs.first;
}

/// make a modern and stylish page for creating a family based on my firebase
/// and my project idea is a family with admin of the family so make a button
/// to add admins to the family when you create it based on username of the
/// user or uid and make it full working page with working functions and cool
/// icons, be creative
class FamilyCreationWidget extends StatefulWidget {
  const FamilyCreationWidget({super.key});

  static String routeName = 'FamilyCreation';
  static String routePath = '/familyCreation';

  @override
  State<FamilyCreationWidget> createState() => _FamilyCreationWidgetState();
}

class _FamilyCreationWidgetState extends State<FamilyCreationWidget> {
  late FamilyCreationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyCreationModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: AppBar(
          backgroundColor: Color(0xFF092B2B),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 24.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Create Family',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x10000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Information',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Family Name *',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            prefixIcon: Icon(
                              Icons.family_restroom,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          cursorColor: FlutterFlowTheme.of(context).primary,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Family name is required';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          autofocus: false,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Family Description (Optional)',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            prefixIcon: Icon(
                              Icons.description,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                          cursorColor: FlutterFlowTheme.of(context).primary,
                          maxLines: 3,
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x10000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Avatar',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 120.0,
                                  height: 120.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: _model.uploadedFileUrl.isNotEmpty
                                          ? Image.network(
                                              _model.uploadedFileUrl,
                                              width: 120.0,
                                              height: 120.0,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.family_restroom,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 60.0,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: FlutterFlowIconButton(
                                      borderRadius: 20.0,
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 20.0,
                                      ),
                                      onPressed: () async {
                                        try {
                                          final selectedMedia =
                                              await selectMediaWithSourceBottomSheet(
                                            context: context,
                                            allowPhoto: true,
                                            allowVideo: false,
                                            maxWidth: 1000,
                                            maxHeight: 1000,
                                            imageQuality: 80,
                                          );

                                          if (selectedMedia != null &&
                                              selectedMedia.isNotEmpty) {
                                            setState(() {
                                              _model.isDataUploading = true;
                                            });

                                            try {
                                              final bytes = await selectedMedia
                                                  .first.bytes;
                                              if (bytes != null) {
                                                // Upload to Firebase Storage
                                                final downloadUrl =
                                                    await StorageService
                                                        .uploadFamilyAvatar(
                                                  'temp_${DateTime.now().millisecondsSinceEpoch}',
                                                  bytes,
                                                );

                                                if (downloadUrl != null) {
                                                  setState(() {
                                                    _model.uploadedFileUrl =
                                                        downloadUrl;
                                                    _model.isDataUploading =
                                                        false;
                                                  });
                                                } else {
                                                  throw Exception(
                                                      'Failed to upload image to Firebase Storage');
                                                }
                                              }
                                            } catch (e) {
                                              print(
                                                  'Error processing image: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error processing image. Please try again.'),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .error,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          print('Error selecting image: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error selecting image. Please try again.'),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x10000000),
                        offset: Offset(
                          0.0,
                          2.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Privacy',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(
                                'Private Family',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            Switch.adaptive(
                              value: _model.isPrivateFamily,
                              onChanged: (newValue) {
                                setState(() {
                                  _model.isPrivateFamily = newValue;
                                });
                              },
                              activeColor:
                                  FlutterFlowTheme.of(context).secondary,
                            ),
                          ],
                        ),
                        Text(
                          'If activated, the family will be private and members cannot join by code until the admin accepts them.',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    if (_model.textController1.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a family name'),
                          backgroundColor: FlutterFlowTheme.of(context).error,
                        ),
                      );
                      return;
                    }

                    final uid = currentUserUid;

                    // 1️⃣  Check if the user is already a member of any family
                    final existingFamilyQuery = await queryFamiliesRecordOnce(
                      queryBuilder: (familiesRecord) => familiesRecord.where(
                        'members',
                        arrayContains: uid,
                      ),
                      limit: 1,
                    );

                    if (existingFamilyQuery != null &&
                        existingFamilyQuery.isNotEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You are already a member of a family. Please leave your current family before creating a new one.',
                          ),
                        ),
                      );
                      return; // stop here—do NOT create a new family
                    }

                    // 2️⃣  No family yet → create one
                    final familyCode = functions.generateFamilyCode();
                    final familyData = createFamiliesRecordData(
                      name: _model.textController1.text,
                      description: _model.textController2.text,
                      photoUrl: _model.uploadedFileUrl,
                      createdBy: uid,
                      createdTime: getCurrentTimestamp,
                      familyCode: familyCode,
                      isActive: true,
                      isPrivate: _model.isPrivateFamily,
                      owner: uid,
                    );

                    // Add the creator as the first member and admin
                    familyData['members'] = [uid];
                    familyData['admin_roles'] = [uid];

                    // Create the family
                    final familyRef =
                        await FamiliesRecord.collection.add(familyData);

                    context.pushNamed('FamilyDashboard');
                  },
                  text: 'Create Family',
                  icon: Icon(
                    Icons.check_circle,
                    color: FlutterFlowTheme.of(context).info,
                    size: 20.0,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 55.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).secondary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).info,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                    elevation: 2.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
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
