import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamilyNote {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isImportant;
  final String color;

  FamilyNote({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isImportant = false,
    this.color = '#0D4D4D',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'authorName': authorName,
        'authorId': authorId,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isImportant': isImportant,
        'color': color,
      };

  factory FamilyNote.fromJson(Map<String, dynamic> json) => FamilyNote(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        authorName: json['authorName'],
        authorId: json['authorId'],
        tags: List<String>.from(json['tags'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        isImportant: json['isImportant'] ?? false,
        color: json['color'] ?? '#0D4D4D',
      );
}

class FamilyNotesScreen extends StatefulWidget {
  const FamilyNotesScreen({
    Key? key,
    this.familyRef,
  }) : super(key: key);

  final DocumentReference? familyRef;

  @override
  State<FamilyNotesScreen> createState() => _FamilyNotesScreenState();
}

class _FamilyNotesScreenState extends State<FamilyNotesScreen> {
  List<FamilyNote> _notes = [];
  List<FamilyNote> _filteredNotes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> _familyMembers = [];
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Important', 'My Notes'];
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    print("FamilyNotesScreen: initState - Loading family members and notes.");
    _loadFamilyMembers();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    print("FamilyNotesScreen: _loadFamilyMembers started.");
    DocumentReference? currentFamilyRef = widget.familyRef;

    if (currentFamilyRef == null) {
      print("FamilyNotesScreen: widget.familyRef is null. Querying for user's family.");
      try {
        final userFamilies = await FirebaseFirestore.instance
            .collection('families')
            .where('members', arrayContains: FirebaseAuth.instance.currentUser?.uid)
            .limit(1)
            .get();

        if (userFamilies.docs.isNotEmpty) {
          currentFamilyRef = userFamilies.docs.first.reference;
          print("FamilyNotesScreen: Found user's family via query: ${currentFamilyRef.path}");
        } else {
          print("FamilyNotesScreen: No family found for current user via query.");
          if (mounted) {
             _showErrorSnackBar('You don\'t belong to any family. Please create or join one.');
          }
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        print("FamilyNotesScreen: Error finding user's family: $e");
        if (mounted) {
          _showErrorSnackBar('Error finding your family: $e');
        }
        setState(() => _isLoading = false);
        return;
      }
    } else {
       print("FamilyNotesScreen: Using familyRef from widget: ${currentFamilyRef.path}");
    }

    if (currentFamilyRef == null) {
       print("FamilyNotesScreen: Family reference is still null after attempts.");
       if (mounted) {
         _showErrorSnackBar('Could not load family information.');
       }
       setState(() => _isLoading = false);
       return;
    }

    try {
      print("FamilyNotesScreen: Attempting to get family document from reference: ${currentFamilyRef.path}");
      final familyDoc = await currentFamilyRef.get();

      if (familyDoc.exists) {
        print("FamilyNotesScreen: Family document exists.");
        final familyData = familyDoc.data() as Map<String, dynamic>;
        final members = familyData['members'] as List<dynamic>? ?? [];
        print("FamilyNotesScreen: Found ${members.length} members in family document.");

        List<String> memberNames = [];
        if (members.isNotEmpty) {
          print("FamilyNotesScreen: Attempting to fetch member display names.");
          try {
             final users = await FirebaseFirestore.instance
                 .collection('users')
                 .where('uid', whereIn: members.map((m) => m.toString()).toList())
                 .get();
             print("FamilyNotesScreen: Fetched ${users.docs.length} user documents.");

             memberNames = users.docs.map((doc) {
               final data = doc.data() as Map<String, dynamic>?;
               final displayName = data?['display_name'] as String?;
               final id = doc.id;
                print("FamilyNotesScreen: Processing user '$id' - Display Name: $displayName");
               return (displayName != null && displayName.isNotEmpty)
                   ? displayName
                   : id; // Use doc.id (UID) as fallback
             }).toList();

             print("FamilyNotesScreen: Generated memberNames list with ${memberNames.length} names.");

             if (memberNames.length != members.length) {
                 print("FamilyNotesScreen: Warning: Mismatch between member UIDs and fetched display names. Falling back to UIDs.");
                 memberNames = members.map((uid) => uid.toString()).toList();
             }

          } catch (e) {
            print("FamilyNotesScreen: Error fetching member display names: $e. Falling back to UIDs.");
            memberNames = members.map((uid) => uid.toString()).toList();
          }
        } else {
           print("FamilyNotesScreen: Family document exists but has no members listed.");
        }

        if (mounted) {
           setState(() {
             _familyMembers = memberNames;
             print("FamilyNotesScreen: _familyMembers updated: ${_familyMembers.length} members.");
           });
        }

      } else {
         print("FamilyNotesScreen: Family document does not exist for the provided reference.");
         if (mounted) {
            _showErrorSnackBar('Family data not found.');
         }
      }
    } catch (e) {
      print("FamilyNotesScreen: Error loading family members from reference: $e");
      if (mounted) {
        _showErrorSnackBar('Error loading family members data: $e');
      }
    } finally {
       if (mounted) {
         setState(() => _isLoading = false);
         print("FamilyNotesScreen: _loadFamilyMembers finished. _isLoading set to false.");
       }
    }
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('family_notes') ?? [];
      setState(() {
        _notes = notesJson
            .map((json) {
              try {
                return FamilyNote.fromJson(jsonDecode(json));
              } catch (e) {
                print('Error decoding note JSON: $e');
                return null; // Return null for invalid notes
              }
            })
            .whereType<FamilyNote>() // Filter out any null notes
            .toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading notes: $e');
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = _notes.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList('family_notes', notesJson);
    } catch (e) {
      _showErrorSnackBar('Error saving notes: $e');
    }
  }

  void _applyFilters() {
    print("FamilyNotesScreen: _applyFilters started. Current filter: $_selectedFilter, Search query: ${_searchController.text}");
    setState(() {
      _filteredNotes = _notes.where((note) {
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = note.title.toLowerCase().contains(searchQuery) ||
            note.content.toLowerCase().contains(searchQuery) ||
            note.authorName.toLowerCase().contains(searchQuery) ||
            note.tags.any((tag) => tag.toLowerCase().contains(searchQuery));

        if (!matchesSearch) return false;

        switch (_selectedFilter) {
          case 'Important':
            return note.isImportant;
          case 'My Notes':
            return note.authorId == FirebaseAuth.instance.currentUser?.uid;
          default:
            return true;
        }
      }).toList();
      print("FamilyNotesScreen: _applyFilters finished. _filteredNotes count: ${_filteredNotes.length}");
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF0D4D4D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showNoteDialog({FamilyNote? note, int? editIndex}) {
    print("FamilyNotesScreen: _showNoteDialog called. Edit index: $editIndex, Note provided: ${note != null}");
    if (_familyMembers.isEmpty) {
      print("FamilyNotesScreen: _showNoteDialog - _familyMembers is empty. Showing error.");
      _showErrorSnackBar('No family members found. Please add family members first.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    String title = note?.title ?? '';
    String content = note?.content ?? '';
    // Determine the initially selected author
    String selectedAuthor;
    if (note != null && _familyMembers.contains(note.authorName)) {
      selectedAuthor = note.authorName;
      print("FamilyNotesScreen: _showNoteDialog - Initial author set from existing note: $selectedAuthor");
    } else if (_familyMembers.isNotEmpty) {
      selectedAuthor = _familyMembers.first;
       print("FamilyNotesScreen: _showNoteDialog - Initial author set to first family member: $selectedAuthor");
    } else {
      selectedAuthor = 'Unknown';
       print("FamilyNotesScreen: _showNoteDialog - Initial author set to Unknown (fallback).");
    }

    List<String> tags = note?.tags ?? [];
    bool isImportant = note?.isImportant ?? false;
    String selectedColor = note?.color ?? '#0D4D4D';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print("FamilyNotesScreen: _showNoteDialog - Building AlertDialog.");
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF0D4D4D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note == null ? 'Add New Family Note' : 'Edit Family Note',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        color: Color(0xFF0D4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedAuthor,
                        decoration: InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: _familyMembers.map((person) {
                           print("FamilyNotesScreen: _showNoteDialog - Adding '$person' to author dropdown.");
                          return DropdownMenuItem<String>(
                            value: person,
                            child: Text(person),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                             print("FamilyNotesScreen: _showNoteDialog - Author dropdown changed to: $value");
                            setStateDialog(() => selectedAuthor = value);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                             print("FamilyNotesScreen: _showNoteDialog - Author validator failed.");
                            return 'Please select an author';
                          }
                           print("FamilyNotesScreen: _showNoteDialog - Author validator passed.");
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: title,
                        decoration: InputDecoration(
                          labelText: 'Title (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.title),
                        ),
                        onChanged: (v) => title = v.trim(),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: content,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.note),
                        ),
                        onChanged: (v) => content = v,
                        validator: (v) => v == null || v.isEmpty ? 'Please enter note content' : null,
                        minLines: 3,
                        maxLines: 6,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: tags.join(', '),
                        decoration: InputDecoration(
                          labelText: 'Tags (comma-separated)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        onChanged: (v) => tags = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Mark as Important'),
                              value: isImportant,
                              onChanged: (value) {
                                setStateDialog(() => isImportant = value!);
                              },
                              activeColor: Color(0xFF0D4D4D),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.color_lens),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Choose Note Color'),
                                  content: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      '#0D4D4D',
                                      '#2196F3',
                                      '#4CAF50',
                                      '#FFC107',
                                      '#F44336',
                                    ].map((color) {
                                       print("FamilyNotesScreen: _showNoteDialog - Adding color '$color' to color picker.");
                                      return InkWell(
                                        onTap: () {
                                          setStateDialog(() => selectedColor = color);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selectedColor == color
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print("FamilyNotesScreen: _showNoteDialog - Cancel button pressed.");
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          print("FamilyNotesScreen: _showNoteDialog - Save/Add button pressed. Validating form.");
                          if (!formKey.currentState!.validate()) {
                             print("FamilyNotesScreen: _showNoteDialog - Form validation failed.");
                            return;
                          }
                          print("FamilyNotesScreen: _showNoteDialog - Form validation passed. Setting isLoading to true.");
                          setStateDialog(() => isLoading = true);
                          try {
                            final now = DateTime.now();
                             print("FamilyNotesScreen: Creating new FamilyNote object.");
                            final newNote = FamilyNote(
                              id: note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              content: content,
                              authorName: selectedAuthor,
                              authorId: FirebaseAuth.instance.currentUser?.uid ?? '',
                              tags: tags,
                              createdAt: note?.createdAt ?? now,
                              updatedAt: now,
                              isImportant: isImportant,
                              color: selectedColor,
                            );
                             print("FamilyNotesScreen: New/Updated note created: ${newNote.id}");

                            setState(() {
                              if (editIndex != null) {
                                print("FamilyNotesScreen: Updating note at index: $editIndex");
                                _notes[editIndex] = newNote;
                              } else {
                                print("FamilyNotesScreen: Adding new note.");
                                _notes.add(newNote);
                              }
                              print("FamilyNotesScreen: Notes list size after update: ${_notes.length}. Applying filters.");
                              _applyFilters();
                            });

                            print("FamilyNotesScreen: Attempting to save notes to SharedPreferences.");
                            await _saveNotes();
                            print("FamilyNotesScreen: Notes saved. Closing dialog.");
                            Navigator.pop(context);
                            _showSuccessSnackBar(
                              note == null ? 'Note added successfully!' : 'Note updated successfully!',
                            );
                             print("FamilyNotesScreen: Success snackbar shown.");
                          } catch (e) {
                             print("FamilyNotesScreen: Error during save/add note: $e");
                            _showErrorSnackBar('Error: $e');
                          } finally {
                             print("FamilyNotesScreen: Setting isLoading to false.");
                            setStateDialog(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D4D4D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          note == null ? 'Add Note' : 'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNote(int index) async {
    final note = _filteredNotes[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Note',
          style: TextStyle(color: Color(0xFF0D4D4D)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to delete this note?',
              textAlign: TextAlign.center,
            ),
            if (note.isImportant) ...[
              SizedBox(height: 8),
              Text(
                'This note is marked as important!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
        _filteredNotes.removeAt(index);
      });
      await _saveNotes();
      _showSuccessSnackBar('Note deleted successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF0D4D4D),
        title: Text(
          'Family Notes',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.archive : Icons.unarchive,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
                _applyFilters();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0D4D4D).withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              _applyFilters();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Color(0xFF0D4D4D).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Color(0xFF0D4D4D) : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 64,
                              color: Color(0xFF0D4D4D).withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notes yet',
                              style: FlutterFlowTheme.of(context).titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start by adding your first family note!',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          // Explicitly handle potential null note object
                           print("FamilyNotesScreen: ListView.builder - Building item $index. Note is null: ${note == null}");
                          if (note == null) {
                            return SizedBox.shrink(); // Skip rendering if note is null
                          }

                          final String noteTitle = note.title ?? '';
                          final String noteContent = note.content ?? '';
                          final String noteAuthorName = note.authorName ?? 'Unknown Author';
                          final List<String> noteTags = note.tags ?? [];
                          final bool noteIsImportant = note.isImportant ?? false;
                          final String noteColor = note.color ?? '#0D4D4D';
                          final DateTime noteUpdatedAt = note.updatedAt ?? DateTime.now();

                           print("FamilyNotesScreen: ListView.builder - Item $index details - Title: '$noteTitle' Author: '$noteAuthorName'");

                          return Dismissible(
                            key: Key(note.id ?? DateTime.now().millisecondsSinceEpoch.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                               print("FamilyNotesScreen: Dismissible dismissed item $index. Deleting note.");
                               _deleteNote(index);
                            },
                            child: Card(
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Color(int.parse(noteColor.replaceAll('#', '0xFF'))),
                                  width: noteIsImportant ? 2 : 1,
                                ),
                              ),
                              elevation: noteIsImportant ? 4 : 2,
                              child: InkWell(
                                onTap: () {
                                  print("FamilyNotesScreen: Note card tapped for item $index. Showing edit dialog.");
                                  _showNoteDialog(
                                    note: note,
                                    editIndex: _notes.indexWhere((n) => n.id == note.id),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (noteTitle.isNotEmpty)
                                                  Text(
                                                    noteTitle,
                                                    style: FlutterFlowTheme.of(context).titleMedium,
                                                  ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 16,
                                                      color: Color(0xFF0D4D4D),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      noteAuthorName,
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            color: Color(0xFF0D4D4D),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                    ),
                                                    if (noteIsImportant) ...[
                                                      SizedBox(width: 8),
                                                      Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.amber,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed: () {
                                               print("FamilyNotesScreen: Edit icon tapped for item $index. Showing edit dialog.");
                                              _showNoteDialog(
                                                note: note,
                                                editIndex: _notes.indexWhere((n) => n.id == note.id),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      if (noteTags.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: noteTags.map((tag) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF0D4D4D).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '#$tag',
                                                style: TextStyle(
                                                  color: Color(0xFF0D4D4D),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                      SizedBox(height: 8),
                                      Text(
                                        noteContent,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Last updated: ${noteUpdatedAt.toString().split('.')[0]}',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                ),
                                          ),
                                          if (noteIsImportant)
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _familyMembers.isEmpty ? null : () => _showNoteDialog(),
        backgroundColor: Color(0xFF0D4D4D),
        icon: Icon(Icons.add),
        label: Text('Add Note'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 