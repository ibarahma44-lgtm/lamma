import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'family_chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '/backend/backend.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart' as ui;
import 'package:go_router/go_router.dart';
import '/components/profile_dialog.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
export 'family_chat_model.dart';

class FamilyChatWidget extends StatefulWidget {
  const FamilyChatWidget({
    Key? key,
    this.familyRef,
  }) : super(key: key);

  final FamiliesRecord? familyRef;

  static String routeName = 'FamilyChat';
  static String routePath = '/family-chat';

  @override
  _FamilyChatWidgetState createState() => _FamilyChatWidgetState();
}

class _FamilyChatWidgetState extends State<FamilyChatWidget>
    with TickerProviderStateMixin {
  late FamilyChatModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _editingMessageId;
  bool _isEditing = false;
  List<String> _familyMembers = [];
  bool _isFamilyLoaded = false;
  StreamSubscription? _chatSubscription;
  List<QueryDocumentSnapshot>? _messages;
  bool _isSending = false;
  FocusNode _messageFocusNode = FocusNode();
  String? _currentFamilyId;
  List<String> _familyQuestions = [];
  bool _isLoadingQuestions = false;
  int _selectedIndex = 4; // Set to 4 since this is the Family Chat page
  static const int _pageSize = 20; // Number of messages to load per page
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  Map<String, String> _userProfilePictures = {}; // Cache for profile pictures
  Map<String, Map<String, dynamic>> _userDetails = {}; // Cache for user details
  Map<String, dynamic>? _replyToMessage;
  String? _replyToMessageId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyChatModel());
    _loadFamilyMembers();
    _setupChatListener();
    _loadFamilyQuestions();

    // Auto focus the input field
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _messageFocusNode.requestFocus();
      }
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _messageFocusNode.dispose();
    _model.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <= 100 &&
        !_isLoadingMore &&
        _hasMoreMessages) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _currentFamilyId == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .collection('chat')
          .orderBy('timestamp', descending: false)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMoreMessages = false;
          _isLoadingMore = false;
        });
        return;
      }

      _lastDocument = snapshot.docs.last;

      if (mounted) {
        setState(() {
          _messages = [...?(_messages ?? []), ...snapshot.docs];
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more messages: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _setupChatListener() {
    if (_currentFamilyId == null) return;

    _chatSubscription?.cancel();
    _chatSubscription = FirebaseFirestore.instance
        .collection('families')
        .doc(_currentFamilyId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .limit(_pageSize)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      setState(() {
        _messages = snapshot.docs;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMoreMessages = snapshot.docs.length >= _pageSize;
      });
    });
  }

  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    // Check cache first
    if (_userDetails.containsKey(userId)) {
      return _userDetails[userId];
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data();
      if (userData != null) {
        _userDetails[userId] = userData;
      }
      return userData;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  Future<String?> _getUserProfilePicture(String userId) async {
    // Check cache first
    if (_userProfilePictures.containsKey(userId)) {
      return _userProfilePictures[userId];
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final photoUrl = userDoc.data()?['photo_url'] as String?;

      if (photoUrl != null && photoUrl.isNotEmpty) {
        String processedUrl = photoUrl;
        // Return as is if it's a base64 image
        if (!photoUrl.startsWith('data:image')) {
          // Ensure the URL is properly formatted for mobile
          if (photoUrl.startsWith('http://')) {
            processedUrl = photoUrl.replaceFirst('http://', 'https://');
          }
        }
        _userProfilePictures[userId] = processedUrl;
        return processedUrl;
      }
      return null;
    } catch (e) {
      print('Error getting user profile picture: $e');
      return null;
    }
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final userFamilies = await FirebaseFirestore.instance
          .collection('families')
          .where('members',
              arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .limit(1)
          .get();

      if (userFamilies.docs.isNotEmpty) {
        final familyDoc = userFamilies.docs.first;
        setState(() {
          _familyMembers =
              List<String>.from(familyDoc.data()['members'] as List);
          _currentFamilyId = familyDoc.id;
          _isFamilyLoaded = true;
        });
        // Set up chat listener after getting family ID
        _setupChatListener();
      } else {
        // No family found, show message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are not a member of any family'),
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      print('Error loading family members: $e');
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    if (_currentFamilyId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messageRef = FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .collection('chat')
          .doc(messageId);
      await messageRef.update({
        'readBy': FieldValue.arrayUnion([user.uid])
      });
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _isSending ||
        _currentFamilyId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userDetails = await _getUserDetails(user.uid);
      final displayName = userDetails?['display_name'] ?? 'Anonymous';
      final messageData = {
        'message': _messageController.text.trim(),
        'senderId': user.uid,
        'senderName': displayName,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [user.uid],
        'isEdited': false,
      };
      if (_replyToMessageId != null && _replyToMessage != null) {
        messageData['replyToMessageId'] = _replyToMessageId;
        messageData['replyToSnippet'] = _replyToMessage!['message'];
        messageData['replyToSenderName'] = _replyToMessage!['senderName'];
      }
      await FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .collection('chat')
          .add(messageData);
      _messageController.clear();
      _cancelReply();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageMenu(BuildContext context, Map<String, dynamic> message,
      String messageId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final isMe = message['senderId'] == currentUser.uid;

    // Get the latest family data to check roles
    final familyDoc = await FirebaseFirestore.instance
        .collection('families')
        .doc(_currentFamilyId)
        .get();

    if (!familyDoc.exists) return;

    final familyData = familyDoc.data()!;
    final isAdmin =
        (familyData['admin_roles'] as List?)?.contains(currentUser.uid) ??
            false;
    final isOwner = familyData['owner'] == currentUser.uid;
    final canDelete = isMe || isAdmin || isOwner;

    // Get reactions
    final reactionsMap = (message['reactions'] as Map?) ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_emotions_outlined,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reactions',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Inter Tight',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: FlutterFlowTheme.of(context).secondaryBackground),
                // Reactions Section
                if (reactionsMap.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...reactionsMap.entries.map((entry) {
                          return FutureBuilder<List<String>>(
                            future: Future.wait(
                              (entry.value as List).map((userId) async {
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .get();
                                return userDoc.data()?['display_name'] ??
                                    'Unknown';
                              }),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: snapshot.data!
                                            .map((name) => Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300),
                                                  ),
                                                  child: Text(
                                                    name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                // Divider before actions
                Divider(
                    height: 1,
                    thickness: 1,
                    color: FlutterFlowTheme.of(context).secondaryBackground),
                // Actions Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isMe)
                        _ModernActionButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          color: FlutterFlowTheme.of(context).primary,
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _isEditing = true;
                              _editingMessageId = messageId;
                              _messageController.text = message['message'];
                            });
                          },
                        ),
                      if (canDelete)
                        _ModernActionButton(
                          icon: Icons.delete,
                          label: 'Delete',
                          color: FlutterFlowTheme.of(context).error,
                          onTap: () async {
                            Navigator.pop(context);
                            if (_currentFamilyId != null) {
                              await FirebaseFirestore.instance
                                  .collection('families')
                                  .doc(_currentFamilyId)
                                  .collection('chat')
                                  .doc(messageId)
                                  .delete();
                            }
                          },
                        ),
                      _ModernActionButton(
                        icon: Icons.copy,
                        label: 'Copy',
                        color: FlutterFlowTheme.of(context).primary,
                        onTap: () {
                          Navigator.pop(context);
                          Clipboard.setData(
                              ClipboardData(text: message['message']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Message copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateMessage(String messageId, String newText) async {
    if (_currentFamilyId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .collection('chat')
          .doc(messageId)
          .update({
        'message': newText,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isEditing = false;
        _editingMessageId = null;
        _messageController.clear();
      });
    } catch (e) {
      print('Error updating message: $e');
    }
  }

  bool _isMessageReadByAll(Map<String, dynamic> message) {
    if (!_isFamilyLoaded) return false;
    final readBy = List<String>.from(message['readBy'] ?? []);
    return _familyMembers.every((memberId) => readBy.contains(memberId));
  }

  Future<void> _loadFamilyQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      // First try the numbered file
      String content;
      try {
        content = await rootBundle
            .loadString('assets/family_questions_ar_numbered.txt');
      } catch (e) {
        print('Error loading numbered questions file: $e');
        // Fallback to the regular file if numbered file not found
        content = await rootBundle.loadString('assets/family_questions_ar.txt');
      }

      // Split by newlines and filter out empty lines
      final lines =
          content.split('\n').where((line) => line.trim().isNotEmpty).toList();

      // Process each line to extract the question text
      _familyQuestions = lines.map((line) {
        // Remove any leading/trailing whitespace
        line = line.trim();

        // Handle different number formats (e.g., "1.", "1-", "1)", etc.)
        final numberPattern = RegExp(r'^\d+[\.\-\)\s]+');
        final match = numberPattern.firstMatch(line);

        if (match != null) {
          // Extract the question text (everything after the number and its separator)
          return line.substring(match.end).trim();
        }

        // If no number found, return the whole line
        return line;
      }).toList();

      // Debug print to verify questions are loaded
      print('Loaded ${_familyQuestions.length} questions');
      if (_familyQuestions.isNotEmpty) {
        print('Sample question: ${_familyQuestions.first}');
      }
    } catch (e) {
      print('Error loading family questions: $e');
      // Set a default question if loading fails
      _familyQuestions = ['حدث خطأ في تحميل الأسئلة. يرجى المحاولة مرة أخرى.'];
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  String _getRandomQuestion() {
    if (_familyQuestions.isEmpty) {
      print('No questions available in the list');
      return 'حدث خطأ في تحميل الأسئلة. يرجى المحاولة مرة أخرى.';
    }
    final random = Random();
    final question = _familyQuestions[random.nextInt(_familyQuestions.length)];
    print('Selected random question: $question');
    return question;
  }

  void _rollQuestion() {
    if (_familyQuestions.isEmpty) return;
    setState(() {
      _questionController.text = _getRandomQuestion();
    });
  }

  void _showQuestionDialog() {
    String currentQuestion = _getRandomQuestion();
    _questionController.text = currentQuestion;
    final TextEditingController _customQuestionController =
        TextEditingController();
    int _currentTabIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Family Question',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/RandomLogo.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 8),
                              Text('Random'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_rounded),
                              SizedBox(width: 8),
                              Text('Custom'),
                            ],
                          ),
                        ),
                      ],
                      labelColor: FlutterFlowTheme.of(context).secondary,
                      unselectedLabelColor:
                          FlutterFlowTheme.of(context).secondaryText,
                      indicatorColor: FlutterFlowTheme.of(context).secondary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: EdgeInsets.all(4),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: TabBarView(
                      children: [
                        // Random Questions Tab
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _questionController.text,
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: ui.TextDirection.rtl,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _rollQuestion();
                                        });
                                      },
                                      tooltip: 'New Question',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Custom Question Tab
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _customQuestionController,
                                decoration: InputDecoration(
                                  hintText: 'Type your question...',
                                  hintStyle: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                style: TextStyle(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                maxLines: null,
                                minLines: 3,
                                textAlign: TextAlign.right,
                                textDirection: ui.TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).primary,
                              FlutterFlowTheme.of(context).secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            String questionToSend = '';
                            if (_currentTabIndex == 0) {
                              // Random question tab
                              questionToSend = _questionController.text.trim();
                            } else {
                              // Custom question tab
                              questionToSend =
                                  _customQuestionController.text.trim();
                            }

                            if (questionToSend.isNotEmpty) {
                              _sendQuestionMessage(questionToSend);
                              Navigator.pop(context);
                            } else {
                              // Show error message if question is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _currentTabIndex == 0
                                        ? 'Please roll a random question first'
                                        : 'Please enter your question',
                                  ),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Send Question',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).info,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  void _showQuestionChatDialog(String question, String questionId) {
    final TextEditingController replyController = TextEditingController();
    final ScrollController replyScrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Icons.help_outline_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Question Chat',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    question,
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('families')
                        .doc(_currentFamilyId)
                        .collection('chat')
                        .doc(questionId)
                        .collection('replies')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final replies = snapshot.data!.docs;
                      return ListView.builder(
                        controller: replyScrollController,
                        padding: EdgeInsets.zero,
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply =
                              replies[index].data() as Map<String, dynamic>;
                          final isMe = reply['senderId'] ==
                              FirebaseAuth.instance.currentUser?.uid;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  FutureBuilder<String?>(
                                    future: _getUserProfilePicture(
                                        reply['senderId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        final photoUrl = snapshot.data!;
                                        if (photoUrl.startsWith('data:image')) {
                                          return GestureDetector(
                                            onTap: () => _showProfileDialog(
                                                reply['senderId']),
                                            child: ClipOval(
                                              child: Image.memory(
                                                base64Decode(
                                                    photoUrl.split(',').last),
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        }
                                        return GestureDetector(
                                          onTap: () => _showProfileDialog(
                                              reply['senderId']),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: photoUrl,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  _buildAvatarPlaceholder(
                                                      context),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      _buildAvatarPlaceholder(
                                                          context),
                                            ),
                                          ),
                                        );
                                      }
                                      return GestureDetector(
                                        onTap: () => _showProfileDialog(
                                            reply['senderId']),
                                        child: _buildAvatarPlaceholder(context),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply['message'],
                                        style: TextStyle(
                                          color: isMe
                                              ? FlutterFlowTheme.of(context).info
                                              : FlutterFlowTheme.of(context).primaryText,
                                        ),
                                      ),
                                      if (reply['isEdited'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            children: [
                                              AnimatedSwitcher(
                                                duration: Duration(milliseconds: 400),
                                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                                child: Icon(
                                                  Icons.edit_rounded,
                                                  key: ValueKey('edited-icon'),
                                                  size: 16,
                                                  color: (isMe && _isMessageReadByAll(reply))
                                                      ? FlutterFlowTheme.of(context).primary
                                                      : FlutterFlowTheme.of(context).secondary,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Tooltip(
                                                message: reply['editedAt'] != null
                                                    ? 'Edited at ' + (reply['editedAt'] is Timestamp
                                                        ? (reply['editedAt'] as Timestamp).toDate().toLocal().toString()
                                                        : reply['editedAt'].toString())
                                                    : 'Edited',
                                                child: Text(
                                                  'Edited',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontStyle: FontStyle.italic,
                                                    color: (isMe && _isMessageReadByAll(reply))
                                                        ? FlutterFlowTheme.of(context).primary
                                                        : FlutterFlowTheme.of(context).secondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 8),
                                  FutureBuilder<String?>(
                                    future: _getUserProfilePicture(
                                        reply['senderId']),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        final photoUrl = snapshot.data!;
                                        if (photoUrl.startsWith('data:image')) {
                                          return GestureDetector(
                                            onTap: () =>
                                                _showProfileDialog(reply['senderId']),
                                            child: ClipOval(
                                              child: Image.memory(
                                                base64Decode(photoUrl.split(',').last),
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        }
                                        return GestureDetector(
                                          onTap: () =>
                                              _showProfileDialog(reply['senderId']),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: photoUrl,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  _buildAvatarPlaceholder(
                                                      context),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      _buildAvatarPlaceholder(
                                                          context),
                                            ),
                                          ),
                                        );
                                      }
                                      return GestureDetector(
                                        onTap: () =>
                                            _showProfileDialog(reply['senderId']),
                                        child: _buildAvatarPlaceholder(context),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            hintText: 'Type your reply...',
                            hintStyle: TextStyle(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).primary,
                              FlutterFlowTheme.of(context).secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: FlutterFlowTheme.of(context).info,
                          ),
                          onPressed: () async {
                            final reply = replyController.text.trim();
                            if (reply.isNotEmpty) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                final userDetails =
                                    await _getUserDetails(user.uid);
                                final displayName =
                                    userDetails?['display_name'] ?? 'Anonymous';

                                await FirebaseFirestore.instance
                                    .collection('families')
                                    .doc(_currentFamilyId)
                                    .collection('chat')
                                    .doc(questionId)
                                    .collection('replies')
                                    .add({
                                  'message': reply,
                                  'senderId': user.uid,
                                  'senderName': displayName,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                                replyController.clear();
                                replyScrollController.animateTo(
                                  replyScrollController
                                      .position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendQuestionMessage(String question) async {
    if (_currentFamilyId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDetails = await _getUserDetails(user.uid);
      final displayName = userDetails?['display_name'] ?? 'Anonymous';

      final questionDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .collection('chat')
          .add({
        'message': question,
        'senderId': user.uid,
        'senderName': displayName,
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [user.uid],
        'isEdited': false,
        'isQuestion': true,
      });

      _scrollToBottom();

      // Show the question chat dialog
      if (context.mounted) {
        _showQuestionChatDialog(question, questionDoc.id);
      }
    } catch (e) {
      print('Error sending question: $e');
    }
  }

  void _showQuestionMenu(
      BuildContext context, Map<String, dynamic> message, String messageId) {
    final isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: FlutterFlowTheme.of(context).error,
                  ),
                  title: Text(
                    'Delete Question',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).error,
                        ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    if (_currentFamilyId != null) {
                      // Delete the question and its replies
                      final batch = FirebaseFirestore.instance.batch();

                      // Delete all replies first
                      final repliesSnapshot = await FirebaseFirestore.instance
                          .collection('families')
                          .doc(_currentFamilyId)
                          .collection('chat')
                          .doc(messageId)
                          .collection('replies')
                          .get();

                      for (var reply in repliesSnapshot.docs) {
                        batch.delete(reply.reference);
                      }

                      // Delete the question
                      batch.delete(
                        FirebaseFirestore.instance
                            .collection('families')
                            .doc(_currentFamilyId)
                            .collection('chat')
                            .doc(messageId),
                      );

                      await batch.commit();
                    }
                  },
                ),
              ],
              ListTile(
                leading: Icon(
                  Icons.copy,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                title: Text(
                  'Copy Question',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message['message']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Question copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showProfileDialog(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final user = UsersRecord.fromSnapshot(userDoc);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ProfileDialog(user: user),
          );
        }
      }
    } catch (e) {
      print('Error showing profile dialog: $e');
    }
  }

  void _onReplyToMessage(Map<String, dynamic> message, String messageId) {
    setState(() {
      _replyToMessage = message;
      _replyToMessageId = messageId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
      _replyToMessageId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              AppBar(
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
                title: Row(
                  children: [
                    FutureBuilder<String?>(
                      future: _getFamilyPhotoUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final photoUrl = snapshot.data!;
                          if (photoUrl.startsWith('data:image')) {
                            return ClipOval(
                              child: Image.memory(
                                base64Decode(photoUrl.split(',').last),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildFamilyAvatarPlaceholder(context),
                              errorWidget: (context, url, error) =>
                                  _buildFamilyAvatarPlaceholder(context),
                            ),
                          );
                        }
                        return _buildFamilyAvatarPlaceholder(context);
                      },
                    ),
                    SizedBox(width: 12),
                    FutureBuilder<String?>(
                      future: _getFamilyName(),
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data ?? 'Family Chat',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).info,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${_familyMembers.length} members',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context)
                                        .info
                                        .withOpacity(0.7),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          color: FlutterFlowTheme.of(context).info,
                          size: 24.0,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).info,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _showQuestionDialog,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: FlutterFlowTheme.of(context).info,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      if (_currentFamilyId == null) return;

                      final familyDoc = await FirebaseFirestore.instance
                          .collection('families')
                          .doc(_currentFamilyId)
                          .get();

                      if (!familyDoc.exists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Family not found'),
                            backgroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        );
                        return;
                      }

                      if (!context.mounted) return;

                      final familyRecord = FamiliesRecord.getDocumentFromData(
                        familyDoc.data()!,
                        familyDoc.reference,
                      );

                      context.pushNamed(
                        'FamilyInformation',
                        queryParameters: {
                          'familyRef': serializeParam(
                            familyRecord,
                            ParamType.Document,
                          ),
                        }.withoutNulls,
                        extra: <String, dynamic>{
                          'familyRef': familyRecord,
                        },
                      );
                    },
                  ),
                ],
                centerTitle: false,
                elevation: 0,
              ),
              Expanded(
                child: _buildMessageList(),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x1A000000),
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_replyToMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.reply, size: 18, color: FlutterFlowTheme.of(context).primary),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _replyToMessage!['senderName'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            _replyToMessage!['message'] ?? '',
                                            style: TextStyle(
                                              color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _cancelReply,
                                        child: Icon(Icons.close, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isEditing)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Editing message',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _editingMessageId = null;
                                  _messageController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            onTap: () {
                              _messageFocusNode.requestFocus();
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isEditing ? Icons.check : Icons.send_rounded,
                              color: FlutterFlowTheme.of(context).info,
                            ),
                            onPressed: _isSending
                                ? null
                                : () {
                                    if (_isEditing &&
                                        _editingMessageId != null) {
                                      _updateMessage(_editingMessageId!,
                                          _messageController.text.trim());
                                    } else {
                                      _sendMessage();
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages!.length,
      itemBuilder: (context, index) {
        final message = _messages![index].data() as Map<String, dynamic>;
        final messageId = _messages![index].id;
        final isMe =
            message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
        final isReadByAll = _isMessageReadByAll(message);
        final isQuestion = message['isQuestion'] == true;

        if (!isMe && _isFamilyLoaded) {
          _markMessageAsRead(messageId);
        }

        if (isQuestion) {
          return GestureDetector(
            onLongPress: () => _showQuestionMenu(context, message, messageId),
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
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
                              Icons.help_outline_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['senderName'],
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message['message'],
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('families')
                                .doc(_currentFamilyId)
                                .collection('chat')
                                .doc(messageId)
                                .collection('replies')
                                .snapshots(),
                            builder: (context, snapshot) {
                              final replyCount =
                                  snapshot.data?.docs.length ?? 0;
                              return Text(
                                '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  FlutterFlowTheme.of(context).secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              onPressed: () => _showQuestionChatDialog(
                                  message['message'], messageId),
                              icon: Icon(
                                Icons.reply_rounded,
                                color: FlutterFlowTheme.of(context).info,
                                size: 20,
                              ),
                              label: Text(
                                'Reply',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context).info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
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
        }

        return MessageBubble(
          message: message,
          messageId: messageId,
          isMe: isMe,
          isReadByAll: isReadByAll,
          onLongPress: () => _showMessageMenu(context, message, messageId),
          familyId: _currentFamilyId!,
          onProfileTap: _showProfileDialog,
          onReplyToMessage: _onReplyToMessage,
        );
      },
    );
  }

  Widget _buildFamilyAvatarPlaceholder(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: FlutterFlowTheme.of(context).info.withOpacity(0.1),
      child: Icon(
        Icons.family_restroom_rounded,
        color: FlutterFlowTheme.of(context).info,
        size: 24,
      ),
    );
  }

  Future<String?> _getFamilyPhotoUrl() async {
    if (_currentFamilyId == null) return null;

    try {
      final familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .get();

      final photoUrl = familyDoc.data()?['photo_url'] as String?;

      if (photoUrl != null && photoUrl.isNotEmpty) {
        // Return as is if it's a base64 image
        if (photoUrl.startsWith('data:image')) {
          return photoUrl;
        }
        // Ensure the URL is properly formatted for mobile
        if (photoUrl.startsWith('http://')) {
          return photoUrl.replaceFirst('http://', 'https://');
        }
        return photoUrl;
      }
      return null;
    } catch (e) {
      print('Error getting family photo: $e');
      return null;
    }
  }

  Future<String?> _getFamilyName() async {
    if (_currentFamilyId == null) return null;

    try {
      final familyDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(_currentFamilyId)
          .get();

      return familyDoc.data()?['name'] as String?;
    } catch (e) {
      print('Error getting family name: $e');
      return null;
    }
  }

  Widget _buildAvatarPlaceholder(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
      child: Icon(
        Icons.person_rounded,
        color: FlutterFlowTheme.of(context).primary,
        size: 20,
      ),
    );
  }
}

class ReactionsDialog extends StatefulWidget {
  final String messageId;
  final String familyId;
  final Function(String) onReactionSelected;
  final VoidCallback? onPlusPressed;
  final Function(String)? onFirstEmojiChanged;

  const ReactionsDialog({
    Key? key,
    required this.messageId,
    required this.familyId,
    required this.onReactionSelected,
    this.onPlusPressed,
    this.onFirstEmojiChanged,
  }) : super(key: key);

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  final List<String> _defaultEmojis = ['❤️', '😂', '😢', '👍'];
  late List<String> _currentEmojis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentEmojis = List.from(_defaultEmojis);
    _loadUserEmojiOrder();
  }

  Future<void> _loadUserEmojiOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      widget.onFirstEmojiChanged?.call(_defaultEmojis.first);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final savedEmojis = userDoc.data()?['reactionEmojis'] as List?;
        if (savedEmojis != null && savedEmojis.isNotEmpty) {
          final validEmojis = savedEmojis.whereType<String>().toList();
          if (validEmojis.isNotEmpty) {
            setState(() {
              _currentEmojis = validEmojis;
              _isLoading = false;
            });
            widget.onFirstEmojiChanged?.call(_currentEmojis.first);
            return;
          }
        }
      }
    } catch (e) {
      print('Error loading user emoji order: $e');
    }

    setState(() {
      _isLoading = false;
    });
    widget.onFirstEmojiChanged?.call(_defaultEmojis.first);
  }

  Future<void> _saveUserEmojiOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'reactionEmojis': _currentEmojis,
      });
      if (_currentEmojis.isNotEmpty) {
        widget.onFirstEmojiChanged?.call(_currentEmojis.first);
      }
    } catch (e) {
      print('Error saving user emoji order: $e');
    }
  }

  void _showEmojiPicker(BuildContext context) async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        height: 350,
        child: emoji_picker.EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context, emoji.emoji);
          },
          config: emoji_picker.Config(
            columns: 7,
            emojiSizeMax: 36,
            verticalSpacing: 8,
            horizontalSpacing: 8,
            gridPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            initCategory: emoji_picker.Category.SMILEYS,
            bgColor: FlutterFlowTheme.of(context).primary,
            indicatorColor: FlutterFlowTheme.of(context).secondary,
            iconColor: Colors.white,
            iconColorSelected: FlutterFlowTheme.of(context).secondary,
            backspaceColor: FlutterFlowTheme.of(context).secondary,
            skinToneDialogBgColor: FlutterFlowTheme.of(context).primary,
            skinToneIndicatorColor: FlutterFlowTheme.of(context).secondary,
            enableSkinTones: true,
            recentTabBehavior: emoji_picker.RecentTabBehavior.RECENT,
            recentsLimit: 28,
            noRecents: Text(
              'No Recents',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: emoji_picker.CategoryIcons(),
            buttonMode: emoji_picker.ButtonMode.MATERIAL,
          ),
        ),
      ),
    );
    if (emoji != null && emoji.isNotEmpty) {
      widget.onReactionSelected(emoji);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).info,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._currentEmojis.map((emoji) => GestureDetector(
                key: ValueKey(emoji),
                onLongPress: () {
                  // Enable reordering on long press
                  setState(() {
                    final index = _currentEmojis.indexOf(emoji);
                    if (index > 0) {
                      final temp = _currentEmojis[index - 1];
                      _currentEmojis[index - 1] = emoji;
                      _currentEmojis[index] = temp;
                      _saveUserEmojiOrder(); // Save the new order
                    }
                  });
                },
                child: _buildReactionButton(emoji, context),
              )),
          Container(
            key: ValueKey('add_button'),
            margin: EdgeInsets.only(left: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (widget.onPlusPressed != null) widget.onPlusPressed!();
                  _showEmojiPicker(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji, BuildContext context) {
    return Material(
      key: ValueKey(emoji),
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onReactionSelected(emoji),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            emoji,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final String messageId;
  final bool isMe;
  final bool isReadByAll;
  final VoidCallback onLongPress;
  final String familyId;
  final Function(String) onProfileTap;
  final Function(Map<String, dynamic>, String) onReplyToMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.messageId,
    required this.isMe,
    required this.isReadByAll,
    required this.onLongPress,
    required this.familyId,
    required this.onProfileTap,
    required this.onReplyToMessage,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _reactionsController;
  late Animation<double> _reactionsAnimation;
  OverlayEntry? _reactionsOverlay;
  final LayerLink _layerLink = LayerLink();
  Map<String, List<String>> _lastReactions = {};
  String _firstEmoji = '❤️'; // Default emoji
  StreamSubscription? _emojiOrderSub;
  Offset _dragOffset = Offset.zero;
  bool _isSwiping = false;
  static const double _swipeThreshold = 60.0;
  Map<String, dynamic>? _replyToData;

  @override
  void initState() {
    super.initState();
    _reactionsController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _reactionsAnimation =
        CurvedAnimation(parent: _reactionsController, curve: Curves.elasticOut);
    _listenToEmojiOrder();
  }

  void _listenToEmojiOrder() {
    _emojiOrderSub?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _firstEmoji = '❤️';
      });
      return;
    }
    _emojiOrderSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      final savedEmojis = doc.data()?['reactionEmojis'] as List?;
      if (savedEmojis != null && savedEmojis.isNotEmpty) {
        final validEmojis = savedEmojis.whereType<String>().toList();
        if (validEmojis.isNotEmpty) {
          setState(() {
            _firstEmoji = validEmojis.first;
          });
          return;
        }
      }
      setState(() {
        _firstEmoji = '❤️';
      });
    });
  }

  @override
  void dispose() {
    _reactionsController.dispose();
    _removeReactionsOverlay();
    _emojiOrderSub?.cancel();
    super.dispose();
  }

  void _removeReactionsOverlay() {
    _reactionsOverlay?.remove();
    _reactionsOverlay = null;
    _reactionsController.reverse();
  }

  Future<void> _handleReactionSelected(String emoji) async {
    if (emoji.isEmpty) return;
    _removeReactionsOverlay();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final messageRef = FirebaseFirestore.instance
          .collection('families')
          .doc(widget.familyId)
          .collection('chat')
          .doc(widget.messageId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final messageDoc = await transaction.get(messageRef);
        if (!messageDoc.exists) return;
        final data = messageDoc.data();
        final reactionsRaw = (data?['reactions'] is Map)
            ? Map<String, dynamic>.from(data?['reactions'])
            : <String, dynamic>{};
        final reactions = <String, List<String>>{};
        final reactionTimes =
            Map<String, dynamic>.from(data?['reactionTimes'] ?? {});

        reactionsRaw.forEach((key, value) {
          if (value is List) {
            reactions[key] = value.cast<String>();
          } else {
            reactions[key] = [];
          }
        });

        if (reactions.containsKey(emoji) &&
            reactions[emoji]!.contains(user.uid)) {
          reactions[emoji]!.remove(user.uid);
          if (reactions[emoji]!.isEmpty) {
            reactions.remove(emoji);
            reactionTimes.remove(emoji);
          }
        } else {
          if (!reactions.containsKey(emoji)) {
            reactions[emoji] = [];
            reactionTimes[emoji] = FieldValue.serverTimestamp();
          }
          reactions[emoji]!.add(user.uid);
        }
        transaction.update(messageRef, {
          'reactions': reactions,
          'reactionTimes': reactionTimes,
        });
      });
    } catch (e) {
      print('Error updating reaction: $e');
    }
  }

  void _showReactionsDialog(BuildContext context, [TapDownDetails? details]) {
    _removeReactionsOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _reactionsOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeReactionsOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          Positioned(
            top: position.dy - 50,
            left: widget.isMe ? position.dx - 200 : position.dx,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, -50),
              child: ScaleTransition(
                scale: _reactionsAnimation,
                child: ReactionsDialog(
                  messageId: widget.messageId,
                  familyId: widget.familyId,
                  onReactionSelected: _handleReactionSelected,
                  onPlusPressed: _removeReactionsOverlay,
                  onFirstEmojiChanged: (emoji) {
                    if (emoji.isNotEmpty) {
                      setState(() {
                        _firstEmoji = emoji;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_reactionsOverlay!);
    _reactionsController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If this message is a reply, try to get the replied-to message from ancestor list
    if (widget.message['replyToMessageId'] != null && _replyToData == null) {
      final replyId = widget.message['replyToMessageId'];
      // Try to get from parent _messages (if available in context)
      // For now, use snippet and senderName from message fields
      _replyToData = {
        'senderName': widget.message['replyToSenderName'] ?? '',
        'message': widget.message['replyToSnippet'] ?? '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final reactionsMap = (widget.message['reactions'] as Map?) ?? {};
    final userDoubleTapEmoji = _firstEmoji;
    final reactionKeys = reactionsMap.keys
        .where((k) => (reactionsMap[k] as List).isNotEmpty)
        .toList();
    // Remove the double-tap emoji from the list if it exists
    reactionKeys.remove(userDoubleTapEmoji);
    // Sort the rest by count and time as before
    reactionKeys.sort((a, b) {
      final countA = (reactionsMap[a] as List).length;
      final countB = (reactionsMap[b] as List).length;
      if (countA != countB) {
        return countB.compareTo(countA);
      }
      final timeA = widget.message['reactionTimes']?[a];
      final timeB = widget.message['reactionTimes']?[b];
      int millisA = 0;
      int millisB = 0;
      if (timeA != null) {
        if (timeA is Timestamp) {
          millisA = timeA.millisecondsSinceEpoch;
        } else if (timeA is int) {
          millisA = timeA;
        }
      }
      if (timeB != null) {
        if (timeB is Timestamp) {
          millisB = timeB.millisecondsSinceEpoch;
        } else if (timeB is int) {
          millisB = timeB;
        }
      }
      return millisA.compareTo(millisB);
    });
    // Insert the double-tap emoji at the start if it exists in the reactions
    if ((reactionsMap[userDoubleTapEmoji] as List?)?.isNotEmpty ?? false) {
      reactionKeys.insert(0, userDoubleTapEmoji);
    }
    final user = FirebaseAuth.instance.currentUser;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: !widget.isMe ? () => _showReactionsDialog(context, null) : null,
        onDoubleTap:
            !widget.isMe ? () => _handleReactionSelected(_firstEmoji) : null,
        onHorizontalDragStart: (details) {
          _isSwiping = true;
        },
        onHorizontalDragUpdate: (details) {
          if (!_isSwiping) return;
          setState(() {
            _dragOffset += details.delta;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_isSwiping && _dragOffset.dx > _swipeThreshold) {
            widget.onReplyToMessage(widget.message, widget.messageId);
          }
          setState(() {
            _dragOffset = Offset.zero;
            _isSwiping = false;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          transform: Matrix4.translationValues(_dragOffset.dx > 0 ? _dragOffset.dx : 0, 0, 0),
          curve: Curves.easeOut,
          child: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isMe) ...[
                  FutureBuilder<String?>(
                    future: _getUserProfilePicture(widget.message['senderId']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final photoUrl = snapshot.data!;
                        if (photoUrl.startsWith('data:image')) {
                          return GestureDetector(
                            onTap: () =>
                                widget.onProfileTap(widget.message['senderId']),
                            child: ClipOval(
                              child: Image.memory(
                                base64Decode(photoUrl.split(',').last),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () =>
                              widget.onProfileTap(widget.message['senderId']),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildAvatarPlaceholder(context),
                              errorWidget: (context, url, error) =>
                                  _buildAvatarPlaceholder(context),
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () =>
                            widget.onProfileTap(widget.message['senderId']),
                        child: _buildAvatarPlaceholder(context),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (_replyToData != null)
                        Container(
                          alignment: widget.isMe ? Alignment.topRight : Alignment.topLeft,
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          margin: EdgeInsets.only(bottom: 4),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: widget.isMe
                                  ? BorderSide.none
                                  : BorderSide(color: FlutterFlowTheme.of(context).primary, width: 4),
                              right: widget.isMe
                                  ? BorderSide(color: FlutterFlowTheme.of(context).primary, width: 4)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.isMe)
                                Icon(Icons.reply, size: 18, color: FlutterFlowTheme.of(context).primary),
                              if (!widget.isMe) SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _replyToData!['senderName'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _replyToData!['message'] ?? '',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context).primaryText.withOpacity(0.85),
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isMe) SizedBox(width: 8),
                              if (widget.isMe)
                                Icon(Icons.reply, size: 18, color: FlutterFlowTheme.of(context).primary),
                            ],
                          ),
                        ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.isMe
                              ? (widget.isReadByAll
                                  ? FlutterFlowTheme.of(context).secondary
                                  : FlutterFlowTheme.of(context).primary)
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x1A000000),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!widget.isMe)
                              Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  widget.message['senderName'],
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Text(
                              widget.message['message'],
                              style: TextStyle(
                                color: widget.isMe
                                    ? FlutterFlowTheme.of(context).info
                                    : FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            if (widget.message['isEdited'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 400),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        key: ValueKey('edited-icon'),
                                        size: 16,
                                        color: (widget.isMe && widget.isReadByAll)
                                            ? FlutterFlowTheme.of(context).primary
                                            : FlutterFlowTheme.of(context).secondary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Tooltip(
                                      message: widget.message['editedAt'] != null
                                          ? 'Edited at ' + (widget.message['editedAt'] is Timestamp
                                              ? (widget.message['editedAt'] as Timestamp).toDate().toLocal().toString()
                                              : widget.message['editedAt'].toString())
                                          : 'Edited',
                                      child: Text(
                                        'Edited',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: (widget.isMe && widget.isReadByAll)
                                              ? FlutterFlowTheme.of(context).primary
                                              : FlutterFlowTheme.of(context).secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (reactionsMap.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4, left: 8),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              for (final emoji in reactionKeys)
                                GestureDetector(
                                  onTap: user != null &&
                                          (reactionsMap[emoji] as List)
                                              .contains(user.uid)
                                      ? () => _handleReactionSelected(emoji)
                                      : null,
                                  child: _PopInReactionBubble(
                                    key: ValueKey(
                                        emoji + reactionsMap[emoji].toString()),
                                    emoji: emoji,
                                    count: (reactionsMap[emoji] as List).length,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.isMe) ...[
                  SizedBox(width: 8),
                  FutureBuilder<String?>(
                    future: _getUserProfilePicture(widget.message['senderId']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final photoUrl = snapshot.data!;
                        if (photoUrl.startsWith('data:image')) {
                          return GestureDetector(
                            onTap: () =>
                                widget.onProfileTap(widget.message['senderId']),
                            child: ClipOval(
                              child: Image.memory(
                                base64Decode(photoUrl.split(',').last),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () =>
                              widget.onProfileTap(widget.message['senderId']),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  _buildAvatarPlaceholder(context),
                              errorWidget: (context, url, error) =>
                                  _buildAvatarPlaceholder(context),
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () =>
                            widget.onProfileTap(widget.message['senderId']),
                        child: _buildAvatarPlaceholder(context),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
      child: Text(
        widget.message['senderName'][0].toUpperCase(),
        style: TextStyle(
          color: FlutterFlowTheme.of(context).primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<String?> _getUserProfilePicture(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final photoUrl = userDoc.data()?['photo_url'] as String?;

      if (photoUrl != null && photoUrl.isNotEmpty) {
        // Return as is if it's a base64 image
        if (photoUrl.startsWith('data:image')) {
          return photoUrl;
        }
        // Ensure the URL is properly formatted for mobile
        if (photoUrl.startsWith('http://')) {
          return photoUrl.replaceFirst('http://', 'https://');
        }
        return photoUrl;
      }
      return null;
    } catch (e) {
      print('Error getting user profile picture: $e');
      return null;
    }
  }
}

class _PopInReactionBubble extends StatefulWidget {
  final String emoji;
  final int count;
  final bool isBeingRemoved;
  final VoidCallback? onRemoveCompleted;
  const _PopInReactionBubble({
    Key? key,
    required this.emoji,
    required this.count,
    this.isBeingRemoved = false,
    this.onRemoveCompleted,
  }) : super(key: key);

  @override
  State<_PopInReactionBubble> createState() => _PopInReactionBubbleState();
}

class _PopInReactionBubbleState extends State<_PopInReactionBubble>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late AnimationController _removeController;
  late Animation<double> _removeScaleAnim;
  late Animation<double> _removeFadeAnim;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    _removeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 220),
    );
    _removeScaleAnim = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _removeController, curve: Curves.easeIn),
    );
    _removeFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _removeController, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant _PopInReactionBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBeingRemoved && !_removing) {
      _removing = true;
      _removeController.forward().then((_) {
        if (widget.onRemoveCompleted != null) widget.onRemoveCompleted!();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _removing ? _removeScaleAnim : _scaleAnim;
    return FadeTransition(
      opacity: _removing ? _removeFadeAnim : AlwaysStoppedAnimation(1.0),
      child: ScaleTransition(
        scale: animation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.07),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(width: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern action button widget for dialog actions
class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(width: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Inter Tight',
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
