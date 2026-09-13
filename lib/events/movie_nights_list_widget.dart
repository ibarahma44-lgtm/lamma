import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '/widgets/modern_navbar.dart';

class MovieNightsListWidget extends StatefulWidget {
  const MovieNightsListWidget({
    super.key,
    this.familyRef,
  });

  final DocumentReference? familyRef;

  @override
  State<MovieNightsListWidget> createState() => _MovieNightsListWidgetState();
}

class _MovieNightsListWidgetState extends State<MovieNightsListWidget> {
  // Use a map of ValueNotifier for real-time updates per movie night
  final Map<String, ValueNotifier<int?>> selectedMovieIndexNotifiers = {};

  bool isMovieNightExpired(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  String getMovieNightStatus(DateTime date, String currentStatus) {
    if (isMovieNightExpired(date)) {
      return 'expired';
    }
    return currentStatus;
  }

  Future<void> _deleteMovieNight(String nightId) async {
    await FirebaseFirestore.instance
        .collection('movie_nights')
        .doc(nightId)
        .delete();
  }

  @override
  void dispose() {
    for (final notifier in selectedMovieIndexNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('familyRef value: \\${widget.familyRef}');
    print('familyRef type: \\${widget.familyRef?.runtimeType}');
    if (widget.familyRef == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Movie Nights',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Plan, vote, and enjoy movies together!',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Inter Tight',
                          color: Colors.white.withOpacity(0.85),
                        ),
                  ),
                ],
              ),
            ],
          ),
          toolbarHeight: 72,
        ),
        body: Center(child: Text('No family selected.')),
      );
    }

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Icon(
              Icons.nightlight_round,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Movie Nights',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Plan, vote, and enjoy movies together!',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('movie_nights')
            .where('familyRef', isEqualTo: widget.familyRef)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading movie nights',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            );
          }

          final movieNights = snapshot.data?.docs ?? [];

          if (movieNights.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: 64,
                    color: FlutterFlowTheme.of(context).secondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No movie nights planned yet',
                    style: FlutterFlowTheme.of(context).titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Plan your first family movie night!',
                    style: FlutterFlowTheme.of(context).bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: movieNights.length,
            itemBuilder: (context, index) {
              final movieNight =
                  movieNights[index].data() as Map<String, dynamic>;
              final date = (movieNight['date'] as Timestamp).toDate();
              final movieRefs = (movieNight['movieRefs'] as List)
                  .where((ref) => ref is DocumentReference)
                  .cast<DocumentReference>()
                  .toList();
              final location = movieNight['location'] as String;
              final status =
                  getMovieNightStatus(date, movieNight['status'] as String);
              final nightId = movieNights[index].id;

              // Ensure a ValueNotifier exists for this movie night
              selectedMovieIndexNotifiers.putIfAbsent(
                  nightId, () => ValueNotifier<int?>(null));
              final selectedNotifier = selectedMovieIndexNotifiers[nightId]!;

              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: Future.wait(
                    movieRefs.map((ref) => ref.get()),
                  ),
                  builder: (context, movieSnapshot) {
                    if (!movieSnapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final movies = movieSnapshot.data!;
                    final firstMovie =
                        movies.first.data() as Map<String, dynamic>;

                    // Calculate average rating and total votes
                    final double avgRating = movies.isNotEmpty
                        ? movies
                                .map((m) =>
                                    (m.data() as Map<String, dynamic>)[
                                        'vote_average'] ??
                                    0.0)
                                .fold(
                                    0.0,
                                    (a, b) =>
                                        a + (b is num ? b.toDouble() : 0.0)) /
                            movies.length
                        : 0.0;
                    final int totalVotes = movies.isNotEmpty
                        ? movies
                            .map((m) =>
                                (m.data()
                                    as Map<String, dynamic>)['vote_count'] ??
                                0)
                            .fold(0, (a, b) => a + (b is int ? b : 0))
                        : 0;

                    return ValueListenableBuilder<int?>(
                      valueListenable: selectedNotifier,
                      builder: (context, selectedIdx, _) {
                        Map<String, dynamic> bannerMovie = firstMovie;
                        double displayRating =
                            (firstMovie['vote_average'] ?? 0.0).toDouble();
                        int displayVotes = firstMovie['vote_count'] ?? 0;
                        if (selectedIdx != null &&
                            selectedIdx >= 0 &&
                            selectedIdx < movies.length) {
                          final movie = movies[selectedIdx].data()
                              as Map<String, dynamic>;
                          displayRating =
                              (movie['vote_average'] ?? 0.0).toDouble();
                          displayVotes = movie['vote_count'] ?? 0;
                          bannerMovie = movie;
                        }

                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
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
                                      Icon(Icons.delete_forever_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          size: 48),
                                      SizedBox(height: 12),
                                      Text(
                                        'Delete Movie Night',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Are you sure you want to delete this movie night? This action cannot be undone.',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Cancel',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              'Inter Tight',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                Navigator.of(context).pop();
                                                await _deleteMovieNight(
                                                    nightId);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Delete',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              'Inter Tight',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
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
                          },
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: bannerMovie['backdrop_path'] != null
                                        ? ClipRRect(
                                            key: ValueKey<String>(
                                                bannerMovie['backdrop_path'] ??
                                                    ''),
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                            child: Image.network(
                                              'https://image.tmdb.org/t/p/w500${bannerMovie['backdrop_path']}',
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : bannerMovie['poster_path'] != null
                                            ? ClipRRect(
                                                key: ValueKey<String>(
                                                    bannerMovie[
                                                            'poster_path'] ??
                                                        ''),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16)),
                                                child: Image.network(
                                                  'https://image.tmdb.org/t/p/w500${bannerMovie['poster_path']}',
                                                  height: 160,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(
                                                key: ValueKey<String>(
                                                    'no_image'),
                                                height: 160,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              16)),
                                                ),
                                                child: Icon(
                                                  Icons.movie,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 64,
                                                ),
                                              ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: status == 'upcoming'
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                        .withOpacity(0.1)
                                                    : status == 'completed'
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : status == 'expired'
                                                            ? Colors.grey
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.red
                                                                .withOpacity(
                                                                    0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                status == 'upcoming'
                                                    ? 'Upcoming'
                                                    : status == 'completed'
                                                        ? 'Completed'
                                                        : status == 'expired'
                                                            ? 'Expired'
                                                            : 'Cancelled',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .copyWith(
                                                      color: status ==
                                                              'upcoming'
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : status ==
                                                                  'completed'
                                                              ? Colors.green
                                                              : status ==
                                                                      'expired'
                                                                  ? Colors.grey
                                                                  : Colors.red,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                            Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  DateFormat('MMM d, y')
                                                      .format(date),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star,
                                                        color: Colors.amber,
                                                        size: 16),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      displayRating
                                                          .toStringAsFixed(1),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(Icons.how_to_vote,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 16),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      displayVotes.toString(),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 6),
                                                AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin:
                                                              Offset(0.1, 0.0),
                                                          end: Offset.zero,
                                                        ).animate(animation),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    key: ValueKey<String>(
                                                        bannerMovie['title'] ??
                                                            ''),
                                                    width: 200,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                        bannerMovie['title'] ??
                                                            '',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: widget.familyRef?.snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Text(
                                                'Movie Night',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium,
                                              );
                                            }
                                            final familyData = snapshot.data!
                                                .data() as Map<String, dynamic>;
                                            final familyName =
                                                familyData['name'] as String? ??
                                                    'Family';
                                            return Text(
                                              '$familyName Movie Night',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium,
                                            );
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  location,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 36,
                                              width: 36,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary
                                                        .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.restaurant_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        elevation: 0,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 10,
                                                                spreadRadius: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .restaurant_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 28,
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          12),
                                                                  Text(
                                                                    'Movie Night Snacks',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter Tight',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              if ((movieNight['snacks']
                                                                          as List?)
                                                                      ?.isEmpty ??
                                                                  true)
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              20),
                                                                  child: Column(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .no_food_rounded,
                                                                        size:
                                                                            48,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              12),
                                                                      Text(
                                                                        'No snacks planned yet',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              else
                                                                Wrap(
                                                                  spacing: 8,
                                                                  runSpacing: 8,
                                                                  children: (movieNight[
                                                                              'snacks']
                                                                          as List)
                                                                      .map<Widget>(
                                                                          (snack) {
                                                                    return Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              6),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        snack
                                                                            .toString(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium,
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              SizedBox(
                                                                  height: 20),
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              12),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Close',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Inter Tight',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
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
                                        SizedBox(height: 12),
                                        Text(
                                          'Movies',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: movies.length,
                                            itemBuilder: (context, mIndex) {
                                              final movie =
                                                  movies[mIndex].data()
                                                      as Map<String, dynamic>;
                                              return Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (selectedNotifier
                                                            .value !=
                                                        mIndex) {
                                                      selectedNotifier.value =
                                                          mIndex;
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 60,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child:
                                                        movie['poster_path'] !=
                                                                null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                child: Image
                                                                    .network(
                                                                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                                                  height: 80,
                                                                  width: 60,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              )
                                                            : Icon(
                                                                Icons.movie,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                  ),
                                                ),
                                              );
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
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
