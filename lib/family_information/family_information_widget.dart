import '/backend/backend.dart';
import '/components/code_copied_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'family_information_model.dart';
import '/components/family_deletion_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/components/family_leave_widget.dart';
import '/components/event_list_widget.dart';
import '/events/add_event_dialog.dart';
import '/backend/schema/events_record.dart';
import '/components/default_profile_avatar.dart';
import '/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/components/profile_dialog.dart';
export 'family_information_model.dart';

class FamilyInformationWidget extends StatefulWidget {
  const FamilyInformationWidget({
    super.key,
    required this.familyRef,
  });

  final FamiliesRecord? familyRef;

  static String routeName = 'FamilyInformation';
  static String routePath = '/familyInformation';

  @override
  State<FamilyInformationWidget> createState() =>
      _FamilyInformationWidgetState();
}

class _FamilyInformationWidgetState extends State<FamilyInformationWidget> {
  late FamilyInformationModel _model;
  Map<String, bool> _roleChangeAttempts = {};
  Map<String, String> _memberNames = {}; // Cache member names

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _loadMemberNames(List<String> memberUids) async {
    try {
      final users = await queryUsersRecord(
        queryBuilder: (usersRecord) =>
            usersRecord.where('uid', whereIn: memberUids),
      ).first;

      setState(() {
        for (var user in users) {
          _memberNames[user.uid] = user.displayName;
        }
      });
    } catch (e) {
      print('Error loading member names: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyInformationModel());

    if (widget.familyRef != null) {
      _loadMemberNames(widget.familyRef!.members);
    } else {
      queryFamiliesRecordOnce(
        queryBuilder: (q) => q.where('members', arrayContains: currentUserUid),
        limit: 1,
      ).then((userFamilies) {
        if (userFamilies.isNotEmpty) {
          _loadMemberNames(userFamilies.first.members);
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.familyRef == null) {
        final userFamilies = await queryFamiliesRecordOnce(
          queryBuilder: (q) =>
              q.where('members', arrayContains: currentUserUid),
          limit: 1,
        );

        if (userFamilies.isEmpty) {
          if (!mounted) return;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text('No Family Found'),
                content: Text(
                    'You don\'t belong to any family yet. Would you like to create a new family or join an existing one?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.goNamed('FamilyCreation');
                    },
                    child: Text('Create Family'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.goNamed('JoinFamily');
                    },
                    child: Text('Join Family'),
                  ),
                ],
              );
            },
          );
        }
      }

      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  Future<void> _handleRoleChange(String memberUid, bool promote) async {
    if (_roleChangeAttempts.containsKey(memberUid)) return;

    setState(() {
      _roleChangeAttempts[memberUid] = promote;
    });

    try {
      final familyRef = widget.familyRef?.reference;
      if (familyRef == null) return;

      // Get the latest family data
      final familyDoc = await familyRef.get();
      final currentFamily = FamiliesRecord.fromSnapshot(familyDoc);

      // Verify the current state matches our attempt
      final isCurrentlyAdmin = currentFamily.adminRoles.contains(memberUid);
      if (promote == isCurrentlyAdmin) {
        // State already matches what we want, no need to update
        return;
      }

      // Perform the update
      await familyRef.update({
        'admin_roles': promote
            ? FieldValue.arrayUnion([memberUid])
            : FieldValue.arrayRemove([memberUid]),
      });

      // Verify the update was successful
      final updatedDoc = await familyRef.get();
      final updatedFamily = FamiliesRecord.fromSnapshot(updatedDoc);
      final isNowAdmin = updatedFamily.adminRoles.contains(memberUid);

      if (promote == isNowAdmin) {
        final memberName = _memberNames[memberUid] ?? 'Member';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              memberUid == currentUserUid
                  ? 'You have been ${promote ? 'promoted' : 'demoted'} ${promote ? 'to' : 'from'} admin'
                  : '$memberName has been ${promote ? 'promoted' : 'demoted'} ${promote ? 'to' : 'from'} admin',
            ),
            backgroundColor: promote
                ? FlutterFlowTheme.of(context).success
                : FlutterFlowTheme.of(context).warning,
          ),
        );
      } else {
        throw Exception('Role change verification failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${promote ? 'promote' : 'demote'} member. Please try again.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      // Force a refresh of the family data
      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _roleChangeAttempts.remove(memberUid);
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Family Information',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Inter Tight',
                    color: FlutterFlowTheme.of(context).info,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          actions: [
            Builder(
              builder: (context) => StreamBuilder<List<FamiliesRecord>>(
                stream: queryFamiliesRecord(
                  queryBuilder: (familiesRecord) => familiesRecord.where(
                    '__name__',
                    isEqualTo: widget.familyRef?.reference.id,
                  ),
                  singleRecord: true,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox.shrink();
                  }
                  final familyRecord = snapshot.data!.first;
                  final uid = currentUserUid;
                  final isAdmin = familyRecord.adminRoles.contains(uid);

                  return FlutterFlowIconButton(
                    borderRadius: 20.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      isAdmin ? Icons.delete_forever : Icons.logout,
                      color: FlutterFlowTheme.of(context).error,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      if (isAdmin) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: FamilyDeletionWidget(
                                familyRef: familyRecord,
                              ),
                            );
                          },
                        );
                      } else {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return Dialog(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  child: FamilyLeaveWidget(
                                    familyRef: familyRecord,
                                  ),
                                );
                              },
                            ) ??
                            false;

                        if (confirmed) {
                          await familyRecord.reference.update({
                            'members': FieldValue.arrayRemove([uid]),
                            'admin_roles': FieldValue.arrayRemove([uid]),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You have left the family'),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).success,
                            ),
                          );
                          context.pushNamed('home');
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: StreamBuilder<List<FamiliesRecord>>(
                    stream: queryFamiliesRecord(
                      queryBuilder: (familiesRecord) => familiesRecord.where(
                        '__name__',
                        isEqualTo: widget.familyRef?.reference.id,
                      ),
                      singleRecord: true,
                    ),
                    builder: (context, familySnapshot) {
                      if (!familySnapshot.hasData ||
                          familySnapshot.data!.isEmpty) {
                        return Container();
                      }
                      final currentFamily = familySnapshot.data!.first;

                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Family Information Section
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Family Information',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Privacy: ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Text(
                                        currentFamily.isPrivate
                                            ? 'Private'
                                            : 'Public',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: currentFamily.isPrivate
                                                  ? FlutterFlowTheme.of(context)
                                                      .error
                                                  : FlutterFlowTheme.of(context)
                                                      .success,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Family Name',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                currentFamily.name,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleMedium
                                                    .override(
                                                      fontFamily: 'Inter Tight',
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              if (currentFamily.adminRoles
                                                  .contains(currentUserUid))
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 0.0, 0.0),
                                                  child: FlutterFlowIconButton(
                                                    borderRadius: 20.0,
                                                    buttonSize: 24.0,
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      size: 16.0,
                                                    ),
                                                    onPressed: () async {
                                                      final TextEditingController
                                                          nameController =
                                                          TextEditingController(
                                                              text:
                                                                  currentFamily
                                                                      .name);
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        4.0,
                                                                    color: Color(
                                                                        0x19000000),
                                                                    offset:
                                                                        Offset(
                                                                            0.0,
                                                                            2.0),
                                                                  )
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            24.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Edit Family Name',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .titleLarge
                                                                              .override(
                                                                                fontFamily: 'Inter Tight',
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                              ),
                                                                        ),
                                                                        FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              20.0,
                                                                          buttonSize:
                                                                              40.0,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.close,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            size:
                                                                                20.0,
                                                                          ),
                                                                          onPressed: () =>
                                                                              Navigator.pop(dialogContext),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          24.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                12.0,
                                                                                0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.family_restroom,
                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                TextField(
                                                                              controller: nameController,
                                                                              autofocus: true,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Family Name',
                                                                                labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'Inter',
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'Inter',
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).alternate,
                                                                                    width: 2.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                    width: 2.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 2.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 2.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        FFButtonWidget(
                                                                          onPressed: () =>
                                                                              Navigator.pop(dialogContext),
                                                                          text:
                                                                              'Cancel',
                                                                          options:
                                                                              FFButtonOptions(
                                                                            height:
                                                                                40.0,
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                0.0,
                                                                                24.0,
                                                                                0.0),
                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: 'Inter Tight',
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                              width: 2.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                12.0),
                                                                        FFButtonWidget(
                                                                          onPressed:
                                                                              () async {
                                                                            if (nameController.text.isNotEmpty) {
                                                                              await currentFamily.reference.update({
                                                                                'name': nameController.text,
                                                                              });
                                                                              Navigator.pop(dialogContext);
                                                                            }
                                                                          },
                                                                          text:
                                                                              'Save',
                                                                          options:
                                                                              FFButtonOptions(
                                                                            height:
                                                                                40.0,
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                0.0,
                                                                                24.0,
                                                                                0.0),
                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondary,
                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: 'Inter Tight',
                                                                                  color: FlutterFlowTheme.of(context).info,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Colors.transparent,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap:
                                                currentFamily.adminRoles
                                                        .contains(
                                                            currentUserUid)
                                                    ? () async {
                                                        try {
                                                          final selectedMedia =
                                                              await selectMediaWithSourceBottomSheet(
                                                            context: context,
                                                            allowPhoto: true,
                                                            maxWidth: 1000,
                                                            maxHeight: 1000,
                                                            imageQuality: 90,
                                                          );

                                                          if (selectedMedia !=
                                                                  null &&
                                                              selectedMedia
                                                                  .isNotEmpty) {
                                                            setState(() {
                                                              _model.isDataUploading =
                                                                  true;
                                                            });

                                                            try {
                                                              final bytes =
                                                                  selectedMedia
                                                                      .first
                                                                      .bytes;

                                                              // Show upload progress
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Uploading family avatar...',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                  backgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                ),
                                                              );

                                                              // Upload to Firebase Storage
                                                              final downloadUrl =
                                                                  await StorageService
                                                                      .uploadFamilyAvatar(
                                                                currentFamily
                                                                    .reference
                                                                    .id,
                                                                bytes,
                                                              );

                                                              if (downloadUrl !=
                                                                  null) {
                                                                // Delete the old avatar if it exists
                                                                if (currentFamily
                                                                    .photoUrl
                                                                    .isNotEmpty) {
                                                                  await StorageService.deleteFamilyAvatar(
                                                                      currentFamily
                                                                          .reference
                                                                          .id);
                                                                }

                                                                // Update family info with new image URL
                                                                await currentFamily
                                                                    .reference
                                                                    .update({
                                                                  'photo_url':
                                                                      downloadUrl,
                                                                });

                                                                if (mounted) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Family avatar updated successfully!',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              fontFamily: 'Inter Tight',
                                                                              color: FlutterFlowTheme.of(context).info,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .success,
                                                                    ),
                                                                  );
                                                                }
                                                              } else {
                                                                throw Exception(
                                                                    'Failed to upload image to Firebase Storage');
                                                              }
                                                            } catch (e) {
                                                              print(
                                                                  'Error uploading image: $e');
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Error uploading image. Please try again.',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Inter Tight',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).info,
                                                                            letterSpacing:
                                                                                0.0,
                                                                          ),
                                                                    ),
                                                                    backgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .error,
                                                                  ),
                                                                );
                                                              }
                                                            } finally {
                                                              if (mounted) {
                                                                setState(() {
                                                                  _model.isDataUploading =
                                                                      false;
                                                                });
                                                              }
                                                            }
                                                          }
                                                        } catch (e) {
                                                          print(
                                                              'Error selecting image: $e');
                                                          if (mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Error selecting image. Please try again.',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter Tight',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .info,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                                backgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    : null,
                                            child: Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Builder(
                                                  builder: (context) {
                                                    if (!currentFamily
                                                        .photoUrl.isNotEmpty) {
                                                      return _buildFallbackAvatar(
                                                          context);
                                                    }

                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: currentFamily
                                                            .photoUrl,
                                                        width: 100.0,
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          print(
                                                              'Error loading image: $error');
                                                          return _buildFallbackAvatar(
                                                              context);
                                                        },
                                                        fadeInDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    300),
                                                        memCacheWidth: 200,
                                                        memCacheHeight: 200,
                                                        maxHeightDiskCache: 200,
                                                        maxWidthDiskCache: 200,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Created On',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            dateTimeFormat('MMM d, y',
                                                currentFamily.createdTime),
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  fontFamily: 'Inter Tight',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Family Code',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                currentFamily.familyCode,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleMedium
                                                    .override(
                                                      fontFamily: 'Inter Tight',
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              SizedBox(width: 8),
                                              Builder(
                                                builder: (context) =>
                                                    FlutterFlowIconButton(
                                                  borderRadius: 20.0,
                                                  buttonSize: 40.0,
                                                  icon: Icon(
                                                    Icons.content_copy,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 20.0,
                                                  ),
                                                  onPressed: () async {
                                                    await Clipboard.setData(
                                                        ClipboardData(
                                                            text: currentFamily
                                                                .familyCode));
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      dialogContext)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child:
                                                                CodeCopiedWidget(),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          // Join Requests Section (only for private families and admins)
                          if (currentFamily.isPrivate &&
                              currentFamily.adminRoles.contains(currentUserUid))
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Join Requests',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily: 'Inter Tight',
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        StreamBuilder<List<UsersRecord>>(
                                          stream: queryUsersRecord(
                                            queryBuilder: (usersRecord) =>
                                                usersRecord.where(
                                              'pending_family_requests',
                                              arrayContains:
                                                  currentFamily.reference,
                                            ),
                                          ),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Container();
                                            }
                                            final pendingRequests =
                                                snapshot.data!;

                                            return Text(
                                              '${pendingRequests.length} pending',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.0),
                                    StreamBuilder<List<UsersRecord>>(
                                      stream: queryUsersRecord(
                                        queryBuilder: (usersRecord) =>
                                            usersRecord.where(
                                          'pending_family_requests',
                                          arrayContains:
                                              currentFamily.reference,
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                            child: Text(
                                              'No pending join requests',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          );
                                        }

                                        final pendingRequests = snapshot.data!;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: pendingRequests.length,
                                          itemBuilder: (context, index) {
                                            final user = pendingRequests[index];
                                            return ListTile(
                                              leading: _buildMemberAvatar(
                                                  context, user),
                                              title: Text(user.displayName),
                                              subtitle: Text(user.email),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .success),
                                                    onPressed: () async {
                                                      // Accept request
                                                      await currentFamily
                                                          .reference
                                                          .update({
                                                        'members': FieldValue
                                                            .arrayUnion(
                                                                [user.uid]),
                                                      });
                                                      await user.reference
                                                          .update({
                                                        'pending_family_requests':
                                                            FieldValue
                                                                .arrayRemove([
                                                          currentFamily
                                                              .reference
                                                        ]),
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.cancel,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error),
                                                    onPressed: () async {
                                                      // Reject request
                                                      await user.reference
                                                          .update({
                                                        'pending_family_requests':
                                                            FieldValue
                                                                .arrayRemove([
                                                          currentFamily
                                                              .reference
                                                        ]),
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: StreamBuilder<List<FamiliesRecord>>(
                    stream: queryFamiliesRecord(
                      queryBuilder: (familiesRecord) => familiesRecord.where(
                        '__name__',
                        isEqualTo: widget.familyRef?.reference.id,
                      ),
                      singleRecord: true,
                    ),
                    builder: (context, familySnapshot) {
                      if (!familySnapshot.hasData ||
                          familySnapshot.data!.isEmpty) {
                        return Container();
                      }
                      final currentFamily = familySnapshot.data!.first;

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x19000000),
                              offset: Offset(0.0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Family Members',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily: 'Inter Tight',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 20.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      Icons.person_add,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24.0,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement add member functionality
                                    },
                                  ),
                                ],
                              ),
                              StreamBuilder<List<UsersRecord>>(
                                stream: queryUsersRecord(
                                  queryBuilder: (usersRecord) =>
                                      usersRecord.where(
                                    'uid',
                                    whereIn: currentFamily.members,
                                  ),
                                  singleRecord: false,
                                ),
                                builder: (context, membersSnapshot) {
                                  if (!membersSnapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final members = membersSnapshot.data!;
                                  if (members.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No members in this family yet',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    );
                                  }

                                  members.sort((a, b) {
                                    final isAOwner =
                                        currentFamily.owner == a.uid;
                                    final isBOwner =
                                        currentFamily.owner == b.uid;
                                    final isAAdmin = currentFamily.adminRoles
                                        .contains(a.uid);
                                    final isBAdmin = currentFamily.adminRoles
                                        .contains(b.uid);

                                    // Owner always comes first
                                    if (isAOwner && !isBOwner) return -1;
                                    if (!isAOwner && isBOwner) return 1;

                                    // Then admins
                                    if (isAAdmin && !isBAdmin) return -1;
                                    if (!isAAdmin && isBAdmin) return 1;

                                    return a.displayName
                                        .compareTo(b.displayName);
                                  });

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: members.length,
                                    itemBuilder: (context, index) {
                                      final member = members[index];
                                      final isOwner =
                                          currentFamily.owner == member.uid;
                                      final isAdmin = currentFamily.adminRoles
                                          .contains(member.uid);
                                      final isCurrentUserOwner =
                                          currentFamily.owner == currentUserUid;
                                      final isCurrentUserAdmin = currentFamily
                                          .adminRoles
                                          .contains(currentUserUid);

                                      return ListTile(
                                        leading:
                                            _buildMemberAvatar(context, member),
                                        title: Row(
                                          children: [
                                            Text(member.displayName),
                                            if (isOwner)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Icon(
                                                  Icons.workspace_premium,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          isOwner
                                              ? 'Owner'
                                              : isAdmin
                                                  ? 'Admin'
                                                  : 'Member',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily: 'Inter',
                                                color: isOwner
                                                    ? Colors.amber
                                                    : isAdmin
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                              ),
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            side: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.0,
                                            ),
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          itemBuilder: (context) {
                                            final menuItems =
                                                <PopupMenuEntry<String>>[];
                                            final isOwner =
                                                currentFamily.owner ==
                                                    member.uid;
                                            final isAdmin = currentFamily
                                                .adminRoles
                                                .contains(member.uid);
                                            final isCurrentUserOwner =
                                                currentFamily.owner ==
                                                    currentUserUid;
                                            final isCurrentUserAdmin =
                                                currentFamily.adminRoles
                                                    .contains(currentUserUid);

                                            // Only owner can promote/demote admins
                                            if (isCurrentUserOwner &&
                                                !isOwner) {
                                              menuItems.add(
                                                PopupMenuItem<String>(
                                                  value: isAdmin
                                                      ? 'demote'
                                                      : 'promote',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isAdmin
                                                            ? Icons.star_border
                                                            : Icons.star,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        isAdmin
                                                            ? 'Demote from Admin'
                                                            : 'Promote to Admin',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            // Owner can kick anyone except themselves
                                            // Admins can kick members but not owner or other admins
                                            if ((isCurrentUserOwner &&
                                                    !isOwner) ||
                                                (isCurrentUserAdmin &&
                                                    !isAdmin &&
                                                    !isOwner)) {
                                              menuItems.add(
                                                PopupMenuItem<String>(
                                                  value: 'kick',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.directions_run,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Kick from Family',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            // Members can leave (except owner)
                                            if (member.uid == currentUserUid &&
                                                !isOwner) {
                                              menuItems.add(
                                                PopupMenuItem<String>(
                                                  value: 'leave',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.logout,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Leave Family',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            return menuItems;
                                          },
                                          onSelected: (value) async {
                                            if (value == 'kick') {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            24.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .directions_run,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  size: 24.0,
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Text(
                                                                  'Kick Member',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleLarge
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter Tight',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .error,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          24.0),
                                                              child: Text(
                                                                'Are you sure you want to kick ${member.displayName} from the family?',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                FFButtonWidget(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          false),
                                                                  text:
                                                                      'Cancel',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width:
                                                                          2.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.0),
                                                                FFButtonWidget(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          true),
                                                                  text: 'Kick',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );

                                              if (confirmed == true) {
                                                await currentFamily.reference
                                                    .update({
                                                  'members':
                                                      FieldValue.arrayRemove(
                                                          [member.uid]),
                                                  'admin_roles':
                                                      FieldValue.arrayRemove(
                                                          [member.uid]),
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '${member.displayName} has been kicked from the family'),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .error,
                                                  ),
                                                );
                                              }
                                            } else if (value == 'promote') {
                                              await _handleRoleChange(
                                                  member.uid, true);
                                            } else if (value == 'demote') {
                                              await _handleRoleChange(
                                                  member.uid, false);
                                            } else if (value == 'leave') {
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            24.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.logout,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  size: 24.0,
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.0),
                                                                Text(
                                                                  'Leave Family',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleLarge
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter Tight',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .error,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          16.0,
                                                                          0.0,
                                                                          24.0),
                                                              child: Text(
                                                                'Are you sure you want to leave the family?',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                FFButtonWidget(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          false),
                                                                  text:
                                                                      'Cancel',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width:
                                                                          2.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.0),
                                                                FFButtonWidget(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          true),
                                                                  text: 'Leave',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        40.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .transparent,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );

                                              if (confirmed == true) {
                                                await currentFamily.reference
                                                    .update({
                                                  'members':
                                                      FieldValue.arrayRemove(
                                                          [currentUserUid]),
                                                  'admin_roles':
                                                      FieldValue.arrayRemove(
                                                          [currentUserUid]),
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'You have left the family'),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .success,
                                                  ),
                                                );
                                                context.pushNamed('home');
                                              }
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(BuildContext context, UsersRecord member) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ProfileDialog(user: member),
        );
      },
      child: CircleAvatar(
        radius: 24,
        backgroundImage: member.photoUrl.isNotEmpty
            ? NetworkImage(member.photoUrl) as ImageProvider
            : null,
        child: member.photoUrl.isEmpty
            ? DefaultProfileAvatar(
                displayName: member.displayName,
                size: 48.0,
              )
            : null,
      ),
    );
  }

  Widget _buildFamilyAvatar(BuildContext context, String photoUrl) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondary,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: photoUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      _buildFallbackAvatar(context),
                ),
              )
            : _buildFallbackAvatar(context),
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.family_restroom,
          color: FlutterFlowTheme.of(context).primary,
          size: 50.0,
        ),
      ),
    );
  }

  Future<void> _clearImageCache() async {
    try {
      await CachedNetworkImage.evictFromCache(widget.familyRef?.photoUrl ?? '');
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image cache cleared'),
          backgroundColor: FlutterFlowTheme.of(context).success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error clearing cache: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing cache'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
