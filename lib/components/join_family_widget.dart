import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'join_family_model.dart';
import 'package:flutter/gestures.dart';
export 'join_family_model.dart';

/// create for me a join family by CODE design with smooth and creative modern
/// stylish design and make a field to enter a 5 DIGITS code
class JoinFamilyWidget extends StatefulWidget {
  const JoinFamilyWidget({super.key});

  @override
  State<JoinFamilyWidget> createState() => _JoinFamilyWidgetState();
}

class _JoinFamilyWidgetState extends State<JoinFamilyWidget> {
  late JoinFamilyModel _model;
  bool _isLoading = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JoinFamilyModel());

    _model.joinCodeTextTextController ??= TextEditingController();
    _model.joinCodeTextFocusNode ??= FocusNode();

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
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(0.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside the text field
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.asset(
                          'assets/images/Screenshot_1-removebg-preview.png',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      'Join Your Family',
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                              ),
                    ),
                    Text(
                      'Enter the 6-digit code shared by your family to connect and share moments together.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          controller: _model.joinCodeTextTextController,
                          focusNode: _model.joinCodeTextFocusNode,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                fontFamily: 'Inter Tight',
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 8.0,
                              ),
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            // Convert to uppercase
                            if (value != value.toUpperCase()) {
                              final controller =
                                  _model.joinCodeTextTextController;
                              if (controller != null) {
                                controller.value = TextEditingValue(
                                  text: value.toUpperCase(),
                                  selection: controller.selection,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    FFButtonWidget(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // Dismiss keyboard before proceeding
                              FocusScope.of(context).unfocus();

                              final code =
                                  _model.joinCodeTextTextController.text.trim();
                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please enter a family code'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                return;
                              }

                              if (code.length != 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Family code must be 6 characters'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                print('Searching for family with code: $code');

                                _model.familyQuery =
                                    await queryFamiliesRecordOnce(
                                  queryBuilder: (familiesRecord) =>
                                      familiesRecord.where(
                                    'family_code',
                                    isEqualTo: code,
                                  ),
                                  singleRecord: false,
                                );

                                print(
                                    'Family query result: ${_model.familyQuery?.length ?? 0} families found');

                                if (_model.familyQuery == null ||
                                    _model.familyQuery!.isEmpty) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invalid family code'),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).error,
                                    ),
                                  );
                                  return;
                                }

                                final family = _model.familyQuery!.first;
                                final uid = currentUserUid;
                                print(
                                    'Found family: ${family.name}, Current user UID: $uid');

                                // Check if user is already a member of any family
                                print(
                                    'Checking for existing family membership...');
                                final existingFamilyQuery =
                                    await queryFamiliesRecordOnce(
                                  queryBuilder: (familiesRecord) =>
                                      familiesRecord.where(
                                    'members',
                                    arrayContains: uid,
                                  ),
                                  singleRecord: false,
                                );

                                print(
                                    'Existing family query result: ${existingFamilyQuery?.length ?? 0} families found');

                                if (existingFamilyQuery != null &&
                                    existingFamilyQuery.isNotEmpty) {
                                  final existingFamily =
                                      existingFamilyQuery.first;
                                  print(
                                      'User is in existing family: ${existingFamily.name}');

                                  // Show confirmation dialog
                                  final shouldLeave = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 4.0,
                                                color: Color(0x33000000),
                                                offset: Offset(0.0, 2.0),
                                              )
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.family_restroom,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 48.0,
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 16.0, 0.0, 8.0),
                                                  child: Text(
                                                    'Leave Current Family?',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineSmall
                                                        .override(
                                                          fontFamily:
                                                              'Inter Tight',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                                Text(
                                                  'You are already a member of ${existingFamily.name}. Would you like to leave this family and join the new one?',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 24.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      FFButtonWidget(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                dialogContext,
                                                                false),
                                                        text: 'Cancel',
                                                        options:
                                                            FFButtonOptions(
                                                          width: 120.0,
                                                          height: 40.0,
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12.0),
                                                      FFButtonWidget(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                dialogContext,
                                                                true),
                                                        text: 'Leave & Join',
                                                        options:
                                                            FFButtonOptions(
                                                          width: 120.0,
                                                          height: 40.0,
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter Tight',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (shouldLeave != true) {
                                    setState(() => _isLoading = false);
                                    print(
                                        'User cancelled leaving existing family');
                                    return;
                                  }

                                  print('Removing user from old family...');
                                  await existingFamily.reference.update({
                                    'members': FieldValue.arrayRemove([uid]),
                                    'admin_roles':
                                        FieldValue.arrayRemove([uid]),
                                  });
                                  print('Successfully removed from old family');
                                }

                                print('Adding user to new family...');
                                if (family.isPrivate) {
                                  // For private families, add the request to the user's pending requests
                                  final userRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid);
                                  await userRef.update({
                                    'pending_family_requests':
                                        FieldValue.arrayUnion(
                                            [family.reference]),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Join request sent to family admin',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  );

                                  // For private families, navigate back to home after sending request
                                  if (!context.mounted) return;
                                  Navigator.pop(
                                      context); // Close the join dialog
                                  context.goNamed('home'); // Go to home page
                                  return;
                                } else {
                                  // For public families, add the user directly
                                  await family.reference.update({
                                    'members': FieldValue.arrayUnion([uid]),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Successfully joined the family',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  );
                                }

                                // Navigate to family dashboard
                                if (!context.mounted) return;
                                print('Navigating to family dashboard...');
                                context.pushNamed('FamilyDashboard');
                              } catch (e) {
                                print('Error joining family: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error joining family: ${e.toString()}'),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                      text: _isLoading ? 'Joining...' : 'Join Family',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        padding: EdgeInsets.all(8.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).secondary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 2.0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                        disabledColor:
                            FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Don\'t have a code? ',
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                          TextSpan(
                            text: 'Create a Family',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                                context.pushNamed('FamilyCreation');
                              },
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ].divide(SizedBox(height: 24.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
