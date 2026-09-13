import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_night_model.dart';
export 'movie_night_model.dart';

class MovieNightWidget extends StatefulWidget {
  const MovieNightWidget({
    super.key,
    this.familyRef,
  });

  final DocumentReference? familyRef;

  @override
  State<MovieNightWidget> createState() => _MovieNightWidgetState();
}

class _MovieNightWidgetState extends State<MovieNightWidget> {
  late MovieNightModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> selectedMovies = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedLocation;
  List<String> selectedSnacks = [];
  List<String> selectedFamilyMembers = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  String? searchError;

  // TMDB API configuration
  static const String apiKey = '8bb6a45b21a1e8602600cd70f4722fbe';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MovieNightModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        searchError = null;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchError = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(data['results']);
        results.sort((a, b) => ((b['vote_average'] ?? 0.0) as num)
            .compareTo((a['vote_average'] ?? 0.0) as num));
        setState(() {
          searchResults = results;
          isSearching = false;
        });
      } else {
        setState(() {
          searchError = 'Failed to search movies';
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        searchError = 'Error searching movies: $e';
        isSearching = false;
      });
    }
  }

  void addMovie(Map<String, dynamic> movie) {
    if (!selectedMovies.any((m) => m['id'] == movie['id'])) {
      setState(() {
        selectedMovies.add(movie);
        _model.movieController.clear();
        searchResults = [];
      });
    }
  }

  void removeMovie(Map<String, dynamic> movie) {
    setState(() {
      selectedMovies.removeWhere((m) => m['id'] == movie['id']);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _createMovieNight() async {
    if (selectedDate == null ||
        selectedTime == null ||
        selectedMovies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    // Validate location
    final location =
        (selectedLocation != null && selectedLocation!.trim().isNotEmpty)
            ? selectedLocation!.trim()
            : 'Home';

    // Validate movieRefs
    List<DocumentReference> movieRefs = [];
    try {
      for (var movie in selectedMovies) {
        final movieDoc =
            await FirebaseFirestore.instance.collection('movies').add({
          'tmdb_id': movie['id'],
          'title': movie['title'],
          'poster_path': movie['poster_path'],
          'overview': movie['overview'],
          'release_date': movie['release_date'],
          'vote_average': movie['vote_average'],
          'backdrop_path': movie['backdrop_path'],
          'genre_ids': movie['genre_ids'],
          'popularity': movie['popularity'],
          'vote_count': movie['vote_count'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        movieRefs.add(movieDoc);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving movies: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    // Validate snacks and participants
    final validSnacks = selectedSnacks.whereType<String>().toList();
    final validParticipants =
        selectedFamilyMembers.whereType<String>().toList();

    // Validate familyRef
    final familyRef = widget.familyRef;
    if (familyRef != null && familyRef is! DocumentReference) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid family reference.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    // Log the data being sent to Firestore
    print('Creating movie night with:');
    print('title: Family Movie Night');
    print(
        'date: "+Timestamp.fromDate(DateTime(${selectedDate!.year}, ${selectedDate!.month}, ${selectedDate!.day}, ${selectedTime!.hour}, ${selectedTime!.minute}))"');
    print('location: $location');
    print('movieRefs: $movieRefs');
    print('snacks: $validSnacks');
    print('participants: $validParticipants');
    print('familyRef: $familyRef');

    try {
      final DateTime eventDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('movie_nights').add({
        'title': 'Family Movie Night',
        'date': Timestamp.fromDate(eventDateTime),
        'location': location,
        'movieRefs': movieRefs,
        'snacks': validSnacks,
        'participants': validParticipants,
        'familyRef': familyRef,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'upcoming',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movie Night created successfully!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Movie Night: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
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
          automaticallyImplyLeading: true,
          title: Text(
            'Plan Movie Night',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Time Selection
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'When',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            selectedDate != null
                                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                                : 'Select Date',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            selectedTime != null
                                                ? selectedTime!.format(context)
                                                : 'Select Time',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0),

                      // Movie Selection
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Movies',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for movies...',
                                prefixIcon: Icon(Icons.search,
                                    color:
                                        FlutterFlowTheme.of(context).secondary),
                                suffixIcon: isSearching
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                          ),
                                        ),
                                      )
                                    : null,
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                              controller: _model.movieController,
                              onChanged: (value) {
                                searchMovies(value);
                              },
                            ),
                            if (searchError != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  searchError!,
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context).error,
                                  ),
                                ),
                              ),
                            if (searchResults.isNotEmpty)
                              Container(
                                height: 250,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final movie = searchResults[index];
                                    return Padding(
                                      padding: EdgeInsets.only(right: 12.0),
                                      child: InkWell(
                                        onTap: () => addMovie(movie),
                                        child: Container(
                                          width: 140,
                                          child: Column(
                                            children: [
                                              if (movie['poster_path'] != null)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  child: Image.network(
                                                    '$imageBaseUrl${movie['poster_path']}',
                                                    height: 160,
                                                    width: 120,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              else
                                                Container(
                                                  height: 160,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Icon(
                                                    Icons.movie,
                                                    size: 40,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                ),
                                              SizedBox(height: 8.0),
                                              Flexible(
                                                child: Container(
                                                  width: 100,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      movie['title'],
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 4.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.star,
                                                      color: Colors.amber,
                                                      size: 16),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    (movie['vote_average'] ??
                                                            0.0)
                                                        .toStringAsFixed(1),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 16.0),
                            if (selectedMovies.isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: selectedMovies.map((movie) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (movie['poster_path'] != null)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            child: Image.network(
                                              '$imageBaseUrl${movie['poster_path']}',
                                              height: 40,
                                              width: 30,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        SizedBox(width: 8.0),
                                        Container(
                                          width: 100,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              movie['title'],
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber, size: 14),
                                            SizedBox(width: 2),
                                            Text(
                                              (movie['vote_average'] ?? 0.0)
                                                  .toStringAsFixed(1),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 4.0),
                                        IconButton(
                                          icon: Icon(Icons.close, size: 16),
                                          onPressed: () => removeMovie(movie),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0),

                      // Snacks Selection
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Snacks',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Add a snack',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.add,
                                      color: FlutterFlowTheme.of(context)
                                          .secondary),
                                  onPressed: () {
                                    if (_model
                                        .snackController.text.isNotEmpty) {
                                      setState(() {
                                        selectedSnacks
                                            .add(_model.snackController.text);
                                        _model.snackController.clear();
                                      });
                                    }
                                  },
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                              controller: _model.snackController,
                            ),
                            SizedBox(height: 16.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: selectedSnacks.map((snack) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        snack,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                      SizedBox(width: 4.0),
                                      IconButton(
                                        icon: Icon(Icons.close, size: 16),
                                        onPressed: () {
                                          setState(() {
                                            selectedSnacks.remove(snack);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0),

                      // Location Selection
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context)
                                  .primary
                                  .withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter location (e.g., Living Room)',
                                prefixIcon: Icon(Icons.location_on,
                                    color:
                                        FlutterFlowTheme.of(context).secondary),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context)
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedLocation = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.0),

                      // Create Button
                      FFButtonWidget(
                        onPressed: _createMovieNight,
                        text: 'Create Movie Night',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).secondary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter Tight',
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                          elevation: 3.0,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
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
}
