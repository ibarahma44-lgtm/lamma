import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_list_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
export 'event_list_model.dart';

/// do a modern and stylish do list for my family events.
///
/// and make it clear if the event is done or no
class EventListWidget extends StatefulWidget {
  const EventListWidget({
    super.key,
    this.familyRef,
    this.status = 'upcoming',
    this.currentUserRole,
  });

  final DocumentReference? familyRef;
  final String status;
  final String? currentUserRole;

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  late EventListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EventListModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: FlutterFlowTheme.of(context).error,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).error,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading events...',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.status == 'upcoming'
                ? Icons.event_available
                : Icons.event_busy,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          SizedBox(height: 16),
          Text(
            widget.status == 'upcoming'
                ? 'No upcoming events'
                : 'No completed events',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          if (widget.status == 'upcoming') ...[
            SizedBox(height: 8),
            Text(
              'Tap + to add a new event',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndexBuildingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Preparing Events View',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).primary,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a minute...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.7),
                ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Setting up database indexes for better performance',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canDeleteEvent(Map<String, dynamic> event) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    // Check if user is admin or owner
    if (widget.currentUserRole == 'admin' ||
        widget.currentUserRole == 'owner') {
      return true;
    }

    // Check if user is the creator
    return event['createdBy'] == currentUser.uid;
  }

  bool _canCompleteEvent() {
    return widget.currentUserRole == 'admin' ||
        widget.currentUserRole == 'owner' ||
        widget.currentUserRole == 'creator';
  }

  bool _isAssignedMember(Map<String, dynamic> event) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final assignedMembers = event['assignedMembers'] as List<dynamic>? ?? [];
    return assignedMembers.contains(currentUser.uid);
  }

  bool _hasRespondedToEvent(Map<String, dynamic> event) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final memberResponses =
        event['memberResponses'] as Map<String, dynamic>? ?? {};
    return memberResponses[currentUser.uid] != null;
  }

  bool _hasAcceptedEvent(Map<String, dynamic> event) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final memberResponses =
        event['memberResponses'] as Map<String, dynamic>? ?? {};
    return memberResponses[currentUser.uid] == true;
  }

  Future<void> _handleEventResponse(String eventId, bool accepted) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
        'memberResponses.${currentUser.uid}': accepted,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accepted ? 'Event accepted' : 'Event rejected'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating event response: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _handleCompletionVote(
      String eventId, Map<String, dynamic> event) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final completionVotes =
        Map<String, dynamic>.from(event['completionVotes'] ?? {});
    completionVotes[currentUser.uid] = true;

    // Check if all assigned members have voted true
    final assignedMembers = event['assignedMembers'] as List<dynamic>? ?? [];
    final allVoted =
        assignedMembers.every((memberId) => completionVotes[memberId] == true);

    final Map<String, dynamic> updates = {
      'completionVotes': completionVotes,
    };
    if (allVoted) {
      updates['status'] = 'completed';
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update(updates);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allVoted
            ? 'Event completed!'
            : 'Your completion vote has been recorded.'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
  }

  Widget _buildEventActions(Map<String, dynamic> event, String eventId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return SizedBox.shrink();

    // If user hasn't responded to the event yet, show accept/reject buttons
    if (_isAssignedMember(event) && !_hasRespondedToEvent(event)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20,
            buttonSize: 40,
            icon: Icon(
              Icons.check_circle_outline,
              color: FlutterFlowTheme.of(context).success,
              size: 24,
            ),
            onPressed: () => _handleEventResponse(eventId, true),
          ),
          SizedBox(width: 8),
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20,
            buttonSize: 40,
            icon: Icon(
              Icons.cancel_outlined,
              color: FlutterFlowTheme.of(context).error,
              size: 24,
            ),
            onPressed: () => _handleEventResponse(eventId, false),
          ),
        ],
      );
    }

    // If user has rejected the event, show rejected status
    if (_isAssignedMember(event) &&
        _hasRespondedToEvent(event) &&
        !_hasAcceptedEvent(event)) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Rejected',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'Inter',
                color: FlutterFlowTheme.of(context).error,
              ),
        ),
      );
    }

    // If user has accepted or is the creator, show normal actions
    if (_hasAcceptedEvent(event) || event['createdBy'] == currentUser.uid) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == 'upcoming') ...[
            Tooltip(
              message: 'Vote to Complete',
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20,
                buttonSize: 40,
                icon: Icon(
                  Icons.check_circle_outline,
                  color: FlutterFlowTheme.of(context).secondary,
                  size: 24,
                ),
                onPressed: () async {
                  await _handleCompletionVote(eventId, event);
                },
              ),
            ),
            if (event['createdBy'] == currentUser.uid)
              Tooltip(
                message: 'Force Complete (Creator Only)',
                child: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20,
                  buttonSize: 40,
                  icon: Icon(
                    Icons.flash_on,
                    color: FlutterFlowTheme.of(context).error,
                    size: 24,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventId)
                        .update({
                      'status': 'completed',
                      'completedAt': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Event force completed by creator!'),
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                    );
                  },
                ),
              ),
          ],
          if (_canDeleteEvent(event))
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 20,
              buttonSize: 40,
              icon: Icon(
                Icons.delete_outline,
                color: FlutterFlowTheme.of(context).error,
                size: 24,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: FlutterFlowTheme.of(context).error,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Delete Event?',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Are you sure you want to delete this event? This action cannot be undone.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Delete',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                        ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (confirm == true) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventId)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Event deleted successfully'),
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting event: $e'),
                        backgroundColor: FlutterFlowTheme.of(context).error,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.familyRef == null) {
      return _buildErrorWidget(
          'No family selected.\nPlease select a family first.');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('familyRef', isEqualTo: widget.familyRef)
          .where('status', isEqualTo: widget.status)
          .orderBy('date', descending: widget.status == 'completed')
          .limit(100)
          .snapshots()
          .handleError((error) {
        if (error is FirebaseException) {
          if (error.code == 'failed-precondition' &&
              error.message?.contains('requires an index') == true) {
            print(
                'Index error. Please create the required index in Firebase Console.');
            print('Error details: ${error.message}');
            return Stream.error('index-building');
          }
        }
        print('Firestore error: $error');
        return Stream.error(error);
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error == 'index-building') {
            return _buildIndexBuildingWidget();
          }
          return _buildErrorWidget(
              'Error loading events.\nPlease try again later.');
        }

        if (!snapshot.hasData) {
          return _buildLoadingWidget();
        }

        final events = snapshot.data!.docs;
        print('Number of events: ${events.length}');

        if (events.isEmpty && widget.status == 'upcoming') {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                SizedBox(height: 16),
                Text(
                  'No upcoming events',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add a new event',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index].data() as Map<String, dynamic>;
                  return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event['title'] ?? 'Untitled Event',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 20,
                                    buttonSize: 40,
                                    icon: Icon(
                                      Icons.info_outline_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(24, 24, 24, 24),
                                              child: Container(
                                                width: double.infinity,
                                                constraints: BoxConstraints(
                                                    maxWidth: 530),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 8,
                                                      color: Color(0x33000000),
                                                      offset: Offset(0, 4),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .secondary
                                                                  .withOpacity(
                                                                      0.1),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .event_note_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondary,
                                                              size: 28,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: widget
                                                                          .status ==
                                                                      'completed'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .success
                                                                      .withOpacity(
                                                                          0.1)
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Text(
                                                              widget.status ==
                                                                      'completed'
                                                                  ? 'Completed'
                                                                  : 'Upcoming',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color: widget.status ==
                                                                            'completed'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .success
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                        event['title'] ??
                                                            'Untitled Event',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter Tight',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary
                                                              .withOpacity(
                                                                  0.05),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  size: 20,
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  _formatDate(
                                                                      event[
                                                                          'date']),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            if (event['location'] !=
                                                                    null &&
                                                                event['location']
                                                                    .toString()
                                                                    .isNotEmpty) ...[
                                                              SizedBox(
                                                                  height: 8),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Expanded(
                                                                    child: Text(
                                                                      event[
                                                                          'location'],
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Inter',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      if (event['description'] !=
                                                              null &&
                                                          event['description']
                                                              .toString()
                                                              .isNotEmpty) ...[
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Description',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          event['description'],
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                              ),
                                                        ),
                                                      ],
                                                      SizedBox(height: 16),
                                                      Text(
                                                        'Assigned Members',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary
                                                              .withOpacity(
                                                                  0.05),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary
                                                                .withOpacity(
                                                                    0.2),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: FutureBuilder<
                                                            List<
                                                                Map<String,
                                                                    String>>>(
                                                          future: Future.wait(
                                                            (event['assignedMembers']
                                                                        as List<
                                                                            dynamic>? ??
                                                                    [])
                                                                .where((memberId) =>
                                                                    (event['memberResponses'] as Map<
                                                                            String,
                                                                            dynamic>? ??
                                                                        {})[memberId] ==
                                                                    true)
                                                                .map((memberId) async {
                                                              try {
                                                                final userDoc = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(memberId
                                                                        .toString())
                                                                    .get();
                                                                if (userDoc
                                                                    .exists) {
                                                                  final userData = userDoc
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>;
                                                                  return {
                                                                    'displayName':
                                                                        userData['display_name'] ??
                                                                            'Unknown User',
                                                                    'photoUrl':
                                                                        userData['photo_url'] ??
                                                                            '',
                                                                  };
                                                                }
                                                                return {
                                                                  'displayName':
                                                                      'Unknown User',
                                                                  'photoUrl':
                                                                      '',
                                                                };
                                                              } catch (e) {
                                                                print(
                                                                    'Error fetching user data: $e');
                                                                return {
                                                                  'displayName':
                                                                      'Unknown User',
                                                                  'photoUrl':
                                                                      '',
                                                                };
                                                              }
                                                            }),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Center(
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                            Color>(
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            final memberNames =
                                                                snapshot.data ??
                                                                    [];
                                                            if (memberNames
                                                                .isEmpty) {
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Text(
                                                                  'No members assigned',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Inter',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                      ),
                                                                ),
                                                              );
                                                            }

                                                            return Column(
                                                              children:
                                                                  memberNames.map(
                                                                      (member) {
                                                                return Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              4),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            32,
                                                                        height:
                                                                            32,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: member['photoUrl'] != null &&
                                                                                (member['photoUrl'] as String).isNotEmpty
                                                                            ? ClipOval(
                                                                                child: Image.network(
                                                                                  member['photoUrl'] ?? '',
                                                                                  width: 32,
                                                                                  height: 32,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                                                                    radius: 16,
                                                                                    child: Text(
                                                                                      (member['displayName'] as String?)?.isNotEmpty == true ? (member['displayName'] as String)[0].toUpperCase() : '?',
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : CircleAvatar(
                                                                                radius: 16,
                                                                                child: Text(
                                                                                  (member['displayName'] as String?)?.isNotEmpty == true ? (member['displayName'] as String)[0].toUpperCase() : '?',
                                                                                ),
                                                                              ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                        (member['displayName']
                                                                                as String?) ??
                                                                            'Unknown User',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Inter',
                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.people,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            '${(event['assignedMembers'] as List<dynamic>? ?? []).where((memberId) => (event['memberResponses'] as Map<String, dynamic>? ?? {})[memberId] == true).length} members',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      // Progress bar for completion votes
                                                      Builder(
                                                        builder: (context) {
                                                          final completionVotes =
                                                              event['completionVotes']
                                                                      as Map<
                                                                          String,
                                                                          dynamic>? ??
                                                                  {};
                                                          final assignedMembers =
                                                              event['assignedMembers']
                                                                      as List<
                                                                          dynamic>? ??
                                                                  [];
                                                          final votedCount = assignedMembers
                                                              .where((memberId) =>
                                                                  completionVotes[
                                                                      memberId] ==
                                                                  true)
                                                              .length;
                                                          final totalCount =
                                                              assignedMembers
                                                                  .length;
                                                          if (totalCount == 0)
                                                            return SizedBox
                                                                .shrink();
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4.0),
                                                            child:
                                                                TweenAnimationBuilder<
                                                                    double>(
                                                              tween:
                                                                  Tween<double>(
                                                                begin: 0,
                                                                end: votedCount /
                                                                    totalCount,
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      600),
                                                              builder: (context,
                                                                      value,
                                                                      child) =>
                                                                  Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  LinearProgressIndicator(
                                                                    value:
                                                                        value,
                                                                    minHeight:
                                                                        8,
                                                                    backgroundColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary
                                                                        .withOpacity(
                                                                            0.15),
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                            Color>(
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .success,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          4),
                                                                  Text(
                                                                    '$votedCount/$totalCount completed',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(height: 24),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          FFButtonWidget(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            text: 'Close',
                                                            options:
                                                                FFButtonOptions(
                                                              height: 40,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20,
                                                                          0,
                                                                          20,
                                                                          0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                      ),
                                                              elevation: 0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildEventActions(event, events[index].id),
                                ],
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: FlutterFlowTheme.of(context).secondary,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _formatDate(event['date']),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                              ),
                            ],
                          ),
                          if (event['location'] != null &&
                              event['location'].toString().isNotEmpty) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: FlutterFlowTheme.of(context).secondary,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event['location'],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (event['description'] != null &&
                              event['description'].toString().isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              event['description'],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
