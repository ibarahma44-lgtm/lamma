import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wheel_of_chores_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/sound_service.dart';
export 'wheel_of_chores_model.dart';

class WheelOfChoresWidget extends StatefulWidget {
  const WheelOfChoresWidget({
    super.key,
    this.familyRef,
  });

  static String routeName = 'WheelOfChores';
  static String routePath = '/wheel-of-chores';

  final DocumentReference? familyRef;

  @override
  State<WheelOfChoresWidget> createState() => _WheelOfChoresWidgetState();
}

class _WheelOfChoresWidgetState extends State<WheelOfChoresWidget>
    with TickerProviderStateMixin {
  late WheelOfChoresModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _spinAnimation;
  String? _choreName;
  DateTime? _completionDate;
  String? _selectedMember;
  String? _selectedMemberId;
  Map<String, String> _memberIdToName = {};
  Map<String, String> _memberNameToId = {};
  List<String> _familyMembers = [];
  bool _isSpinning = false;
  double _startRotation = 0.0;
  double _endRotation = 0.0;
  DocumentReference? _familyRef;
  List<Map<String, dynamic>> _choreHistory = [];
  int _selectedIndex = 2; // Set to 2 since this is the Wheel of Chores
  final SoundService _soundService = SoundService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WheelOfChoresModel());
    _spinAnimation = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFamilyRef();
  }

  void _initializeFamilyRef() {
    // First try widget property
    _familyRef = widget.familyRef;

    // If not found in widget property, try route parameters
    if (_familyRef == null) {
      final state = GoRouterState.of(context);
      final params = FFParameters(state);
      _familyRef = params.getParam<DocumentReference>(
        'familyRef',
        ParamType.DocumentReference,
      );
    }

    // If we have a valid family ref, load members and chores
    if (_familyRef != null) {
      _loadFamilyMembers();
      _loadChoreHistory();
    }
  }

  Future<void> _loadFamilyMembers() async {
    if (_familyRef == null) return;

    try {
      final familyDoc = await _familyRef!.get();
      if (!familyDoc.exists) return;

      final data = familyDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(data['members'] ?? []);

      // Fetch user names for each member ID
      final memberNames = <String>[];
      final idToName = <String, String>{};
      final nameToId = <String, String>{};

      for (final memberId in memberIds) {
        if (memberId.isEmpty) continue;

        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final displayName = userData['display_name'] as String?;
            if (displayName != null && displayName.isNotEmpty) {
              memberNames.add(displayName);
              idToName[memberId] = displayName;
              nameToId[displayName] = memberId;
            }
          }
        } catch (e) {
          print('Error fetching user $memberId: $e');
        }
      }

      if (memberNames.isEmpty) {
        // If no display names found, use member IDs as fallback
        memberNames.addAll(memberIds.where((id) => id.isNotEmpty));
        for (final id in memberIds) {
          if (id.isNotEmpty) {
            idToName[id] = id;
            nameToId[id] = id;
          }
        }
      }

      if (mounted) {
        setState(() {
          _familyMembers = memberNames;
          _memberIdToName = idToName;
          _memberNameToId = nameToId;
        });
      }
    } catch (e) {
      print('Error loading family members: $e');
    }
  }

  Future<void> _loadChoreHistory() async {
    if (_familyRef == null) return;

    try {
      final familyDoc = await _familyRef!.get();
      if (!familyDoc.exists) return;

      final data = familyDoc.data() as Map<String, dynamic>;
      final chores = List<Map<String, dynamic>>.from(data['chores'] ?? []);

      setState(() {
        _choreHistory = chores;
      });
    } catch (e) {
      print('Error loading chore history: $e');
    }
  }

  Future<void> _deleteChore(int index) async {
    if (_familyRef == null) return;

    // Store the chore before deleting
    final deletedChore = _choreHistory[index];

    try {
      // Remove from local state
      setState(() {
        _choreHistory.removeAt(index);
      });

      // Update in Firestore
      await _familyRef!.update({
        'chores': _choreHistory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chore deleted successfully'),
          backgroundColor: FlutterFlowTheme.of(context).success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Revert local state if update fails
      setState(() {
        _choreHistory.insert(index, deletedChore);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete chore'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _spinWheel() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSpinning = true);

      // Calculate random end rotation (between 5 and 10 full spins plus the member position)
      final random = math.Random();
      final spins = 5 + random.nextInt(6); // 5-10 spins
      final memberIndex = random.nextInt(_familyMembers.length);
      final memberAngle = (memberIndex * 360.0 / _familyMembers.length);

      final selectedName = _familyMembers[memberIndex];
      final selectedId = _memberNameToId[selectedName];

      setState(() {
        _startRotation = _endRotation % 360;
        _endRotation = (360.0 * spins) + memberAngle;
        _selectedMember = selectedName;
        _selectedMemberId = selectedId;
      });

      // Create a curved animation for smooth deceleration
      final curvedAnimation = CurvedAnimation(
        parent: _spinAnimation,
        curve: Curves.easeOutCubic,
      );

      _spinAnimation.reset();
      await _spinAnimation.forward();

      setState(() => _isSpinning = false);
      
      // Play winning sound when wheel stops
      await _soundService.playWinSound();

      // Save to database
      if (_choreName != null &&
          _completionDate != null &&
          _selectedMember != null &&
          _selectedMemberId != null) {
        final newChore = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'choreName': _choreName,
          'completionDate': _completionDate!.millisecondsSinceEpoch,
          'assignedTo': _selectedMember,
          'assignedToId': _selectedMemberId,
          'spinDate': DateTime.now().millisecondsSinceEpoch,
        };

        try {
          // Update local state
          setState(() {
            _choreHistory.insert(0, newChore);
          });

          // Update in Firestore
          await _familyRef!.update({
            'chores': _choreHistory,
          });

          // Clear form
          _formKey.currentState!.reset();
          setState(() {
            _choreName = null;
            _completionDate = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chore assigned successfully'),
              backgroundColor: FlutterFlowTheme.of(context).success,
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Revert local state if update fails
          setState(() {
            _choreHistory.removeAt(0);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign chore'),
              backgroundColor: FlutterFlowTheme.of(context).error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Widget _buildRouletteWheel() {
    if (_familyMembers.isEmpty) {
      return Center(
        child: Text(
          'No family members found',
          style: FlutterFlowTheme.of(context).headlineMedium,
        ),
      );
    }

    final wheelSize = 300.0;
    final anglePerMember = 360.0 / _familyMembers.length;

    return Container(
      height: wheelSize + 40, // Extra space for the pointer
      width: wheelSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating wheel
          AnimatedBuilder(
            animation: _spinAnimation,
            builder: (context, child) {
              // Calculate the current rotation with easing
              final curvedValue =
                  Curves.easeOutCubic.transform(_spinAnimation.value);
              final currentRotation = (_startRotation +
                      (_endRotation - _startRotation) * curvedValue) *
                  math.pi /
                  180;

              return Transform.rotate(
                angle: currentRotation,
                child: Container(
                  height: wheelSize,
                  width: wheelSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        FlutterFlowTheme.of(context).secondary.withOpacity(0.7),
                        FlutterFlowTheme.of(context).secondary,
                      ],
                      stops: [0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: List.generate(_familyMembers.length, (index) {
                      final angle = anglePerMember * index;
                      return Transform.rotate(
                        angle: angle * math.pi / 180,
                        child: Transform.translate(
                          offset: Offset(0, -wheelSize / 3),
                          child: Container(
                            width: wheelSize,
                            alignment: Alignment.center,
                            child: RotatedBox(
                              quarterTurns: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _familyMembers[index],
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
          // Center point
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: FlutterFlowTheme.of(context).info,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // Pointer
          Positioned(
            top: 0,
            child: Container(
              width: 40,
              height: 50,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_drop_down,
                color: FlutterFlowTheme.of(context).info,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoreHistory() {
    if (_choreHistory.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cleaning_services_outlined,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No chores assigned yet',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Spin the wheel to assign your first chore!',
              style: FlutterFlowTheme.of(context).bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _choreHistory.length,
      itemBuilder: (context, index) {
        final chore = _choreHistory[index];
        final dueDate =
            DateTime.fromMillisecondsSinceEpoch(chore['completionDate'] as int);
        final assignedDate =
            DateTime.fromMillisecondsSinceEpoch(chore['spinDate'] as int);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cleaning_services_outlined,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chore['choreName'] as String,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: FlutterFlowTheme.of(context).error,
                      ),
                      onPressed: () => _deleteChore(index),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Assigned to: ${chore['assignedTo']}',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Due: ${dueDate.toString().split(' ')[0]}',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Assigned: ${assignedDate.toString().split(' ')[0]}',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _model.dispose();
    _spinAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Wheel of Chores',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).info,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _soundService.isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _soundService.toggleMute();
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        FlutterFlowTheme.of(context).primaryBackground,
                        FlutterFlowTheme.of(context).secondaryBackground,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Chore Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon:
                                            Icon(Icons.cleaning_services),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a chore name';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _choreName = value,
                                    ),
                                    SizedBox(height: 16),
                                    InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) {
                                          setState(
                                              () => _completionDate = date);
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Completion Date',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          prefixIcon:
                                              Icon(Icons.calendar_today),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                        ),
                                        child: Text(
                                          _completionDate
                                                  ?.toString()
                                                  .split(' ')[0] ??
                                              'Select Completion Date',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          _buildRouletteWheel(),
                          SizedBox(height: 16),
                          if (_selectedMember != null && !_isSpinning)
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).secondary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: FlutterFlowTheme.of(context)
                                        .secondary
                                        .withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Selected: $_selectedMember',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: FlutterFlowTheme.of(context)
                                              .secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 16),
                          FFButtonWidget(
                            onPressed: _isSpinning ? null : _spinWheel,
                            text: _isSpinning ? 'Spinning...' : 'Spin Wheel',
                            icon: Icon(
                              Icons.casino,
                              size: 20,
                            ),
                            options: FFButtonOptions(
                              height: 50,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                              color: FlutterFlowTheme.of(context).secondary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              elevation: 3,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              disabledColor: FlutterFlowTheme.of(context)
                                  .secondary
                                  .withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: 32),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Chore History',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildChoreHistory(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height: 32), // Add extra padding at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
