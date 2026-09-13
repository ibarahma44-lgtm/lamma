import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'home_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/components/family_not_found_widget.dart';
import '/components/default_profile_avatar.dart';
import '/components/cached_profile_image.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_navbar.dart';
export 'home_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Text('Page $_selectedIndex',
                  style: const TextStyle(fontSize: 24)),
            ),

            // Top rating section
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Left rating
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        const Text(
                          "4.6",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Right rating
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        const Text(
                          "4.5",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ModernNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onFABPressed: () {
          // Add your FAB action here
        },
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;
  int _selectedIndex = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final lastUpdate =
        '${today.day.toString().padLeft(2, '0')} ${_monthName(today.month)} ${today.year}';
    final headerHeight = 160.0;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        extendBody: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header with diagonal gradient
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Hamburger menu icon
                          Icon(Icons.menu, color: Colors.white, size: 28),
                          // Logo bubble in the center
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/Screenshot_1-removebg-preview.png',
                                height: 76,
                                width: 76,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Profile picture button
                          StreamBuilder<UsersRecord>(
                            stream:
                                UsersRecord.getDocument(currentUserReference!),
                            builder: (context, snapshot) {
                              final user = snapshot.data;
                              return GestureDetector(
                                onTap: () =>
                                    context.pushNamed('auth_2_Profile'),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: (user != null &&
                                            user.photoUrl.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: user.photoUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              child: Center(
                                                child: Text(
                                                  user.displayName.isNotEmpty
                                                      ? user.displayName[0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              child: Center(
                                                child: Text(
                                                  user.displayName.isNotEmpty
                                                      ? user.displayName[0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            child: Center(
                                              child: Text(
                                                user?.displayName.isNotEmpty ==
                                                        true
                                                    ? user!.displayName[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              // Grid container, overlapping header
              Transform.translate(
                offset: Offset(0, -40),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 32, bottom: 8),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.95,
                    children: _buildFeatureCards(context),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        bottomNavigationBar: ModernNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          onFABPressed: () {
            context.pushNamed('FamilyCreation');
          },
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.4; // 40% of screen width

    return [
      // Custom Family Button
      StatefulBuilder(
        builder: (context, setState) {
          bool isPressed = false;
          return Listener(
            onPointerDown: (_) => setState(() => isPressed = true),
            onPointerUp: (_) => setState(() => isPressed = false),
            onPointerCancel: (_) => setState(() => isPressed = false),
            child: GestureDetector(
              onTap: () async {
                final userFamilies = await queryFamiliesRecordOnce(
                  queryBuilder: (q) =>
                      q.where('members', arrayContains: currentUserUid),
                  limit: 1,
                );
                if (userFamilies.isEmpty) {
                  await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(dialogContext).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: FamilyNotFoundWidget(),
                        ),
                      );
                    },
                  );
                } else {
                  context.pushNamed('FamilyDashboard');
                }
              },
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: isPressed
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: isPressed ? 8.0 : 18.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, isPressed ? 4.0 : 10.0),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Transform.translate(
                        offset: Offset(0, isPressed ? 4 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/images/family_motion.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Family',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.037,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Events Button
      StatefulBuilder(
        builder: (context, setState) {
          bool isPressed = false;
          return Listener(
            onPointerDown: (_) => setState(() => isPressed = true),
            onPointerUp: (_) => setState(() => isPressed = false),
            onPointerCancel: (_) => setState(() => isPressed = false),
            child: GestureDetector(
              onTap: () async {
                final userFamilies = await queryFamiliesRecordOnce(
                  queryBuilder: (q) =>
                      q.where('members', arrayContains: currentUserUid),
                  limit: 1,
                );
                if (userFamilies.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please join or create a family first!')),
                  );
                } else {
                  context.pushNamed(
                    'LammaEvents',
                    queryParameters: {
                      'familyRef': serializeParam(
                        userFamilies.first.reference,
                        ParamType.DocumentReference,
                      ),
                    }.withoutNulls,
                    extra: <String, dynamic>{
                      'familyRef': userFamilies.first.reference,
                    },
                  );
                }
              },
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: isPressed
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: isPressed ? 8.0 : 18.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, isPressed ? 4.0 : 10.0),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Transform.translate(
                        offset: Offset(0, isPressed ? 4 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/images/events_motion.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Events',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.037,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Family Chat Button
      StatefulBuilder(
        builder: (context, setState) {
          bool isPressed = false;
          return Listener(
            onPointerDown: (_) => setState(() => isPressed = true),
            onPointerUp: (_) => setState(() => isPressed = false),
            onPointerCancel: (_) => setState(() => isPressed = false),
            child: GestureDetector(
              onTap: () async {
                final userFamilies = await queryFamiliesRecordOnce(
                  queryBuilder: (q) =>
                      q.where('members', arrayContains: currentUserUid),
                  limit: 1,
                );
                if (userFamilies.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please join or create a family first!')),
                  );
                } else {
                  context.pushNamed('FamilyChat');
                }
              },
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: isPressed
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: isPressed ? 8.0 : 18.0,
                            color: Color(0x1A000000),
                            offset: Offset(0.0, isPressed ? 4.0 : 10.0),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Transform.translate(
                        offset: Offset(0, isPressed ? 4 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'assets/images/chat_motion.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .secondary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Family Chat',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth * 0.037,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Wheel of Chores Button
      GestureDetector(
        onTap: () async {
          final userFamilies = await queryFamiliesRecordOnce(
            queryBuilder: (q) =>
                q.where('members', arrayContains: currentUserUid),
            limit: 1,
          );
          if (userFamilies.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please join or create a family first!'),
                duration: Duration(milliseconds: 4000),
                backgroundColor: FlutterFlowTheme.of(context).primary,
              ),
            );
            return;
          }
          context.pushNamed(
            'WheelOfChores',
            queryParameters: {
              'familyRef': serializeParam(
                userFamilies.first.reference,
                ParamType.DocumentReference,
              ),
            }.withoutNulls,
            extra: <String, dynamic>{
              'familyRef': userFamilies.first.reference,
            },
          );
        },
        child: Column(
          children: [
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12.0,
                    color: Color(0x1A000000),
                    offset: Offset(0.0, 6.0),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/wheel_motion.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Wheel of Chores',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.037,
                    ),
              ),
            ),
          ],
        ),
      ),
      // Games Button
      GestureDetector(
        onTap: () async {
          context.pushNamed('GamesList');
        },
        child: Column(
          children: [
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12.0,
                    color: Color(0x1A000000),
                    offset: Offset(0.0, 6.0),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/games_motion.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Games',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.037,
                    ),
              ),
            ),
          ],
        ),
      ),
      // Settings Button
      GestureDetector(
        onTap: () async {
          context.pushNamed('Settings');
        },
        child: Column(
          children: [
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12.0,
                    color: Color(0x1A000000),
                    offset: Offset(0.0, 6.0),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/settings_motion.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Settings',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter Tight',
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.037,
                    ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _featureCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.4; // 40% of screen width
    final iconSize = buttonSize * 0.35; // 35% of button size

    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12.0,
                  color: Color(0x1A000000),
                  offset: Offset(0.0, 4.0),
                )
              ],
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).primary,
                  size: iconSize,
                ),
                SizedBox(height: buttonSize * 0.08),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.035, // Responsive font size
                      ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenWidth * 0.01,
          ),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.037,
                ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
