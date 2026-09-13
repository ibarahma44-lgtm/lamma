import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isCircular;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.isCircular = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(4),
          border: Border.all(
            color: value
                ? FlutterFlowTheme.of(context).secondary
                : FlutterFlowTheme.of(context).primary,
            width: 2,
          ),
          color: value
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondary,
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({
    Key? key,
    required this.familyRef,
  }) : super(key: key);

  final DocumentReference familyRef;

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _selectedMembers = [];
  List<Map<String, dynamic>> _availableMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      // First get the family document to get the member IDs
      final familyDoc = await widget.familyRef.get();
      final familyData = familyDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(familyData['members'] ?? []);

      // Then fetch each user's details from the users collection
      final List<Map<String, dynamic>> members = [];
      for (final memberId in memberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          members.add({
            'id': memberId,
            'name': userData['display_name'] ?? 'Unknown',
            'role': userData['role'] ?? 'member',
          });
        }
      }

      setState(() {
        _availableMembers = members;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading members: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedMembers.length == _availableMembers.length) {
        _selectedMembers = [];
      } else {
        _selectedMembers =
            _availableMembers.map((m) => m['id'] as String).toList();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Event',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: FlutterFlowTheme.of(context).secondary,
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: FlutterFlowTheme.of(context).secondary,
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle:
                        FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: FlutterFlowTheme.of(context).secondary,
                    ),
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                SizedBox(height: 16),
                // Date Selection
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Select date',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Time Selection
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                    ),
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'Select time',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Assign Members',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Members',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    TextButton(
                      onPressed: _toggleSelectAll,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomCheckbox(
                            value: _selectedMembers.length ==
                                _availableMembers.length,
                            onChanged: (value) => _toggleSelectAll(),
                            isCircular: true,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _selectedMembers.length == _availableMembers.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _availableMembers.length,
                    itemBuilder: (context, index) {
                      final member = _availableMembers[index];
                      return ListTile(
                        title: Text(
                          member['name'],
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        subtitle: Text(
                          member['role'],
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                        leading: CustomCheckbox(
                          value: _selectedMembers.contains(member['id']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedMembers.add(member['id']);
                              } else {
                                _selectedMembers.remove(member['id']);
                              }
                            });
                          },
                          isCircular: true,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    FFButtonWidget(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedDate == null || _selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please select both date and time'),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).error,
                              ),
                            );
                            return;
                          }

                          // If no members are selected, assign all available members by default
                          if (_selectedMembers.isEmpty) {
                            _selectedMembers = _availableMembers
                                .map((m) => m['id'] as String)
                                .toList();
                          }

                          // Combine date and time
                          final DateTime combinedDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );

                          try {
                            await FirebaseFirestore.instance
                                .collection('events')
                                .add({
                              'title': _titleController.text,
                              'description': _descriptionController.text,
                              'location': _locationController.text,
                              'date': Timestamp.fromDate(combinedDateTime),
                              'status': 'upcoming',
                              'familyRef': widget.familyRef,
                              'assignedMembers': _selectedMembers,
                              'createdBy':
                                  FirebaseAuth.instance.currentUser?.uid,
                              'createdAt': FieldValue.serverTimestamp(),
                              'memberResponses': Map.fromEntries(
                                _selectedMembers.map(
                                  (memberId) => MapEntry(memberId, null),
                                ),
                              ),
                              'completionVotes': Map.fromEntries(
                                _selectedMembers.map(
                                  (memberId) => MapEntry(memberId, false),
                                ),
                              ),
                            });
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding event: $e'),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).error,
                              ),
                            );
                          }
                        }
                      },
                      text: 'Add Event',
                      options: FFButtonOptions(
                        width: 130,
                        height: 40,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).secondary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                ),
                        elevation: 2,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
