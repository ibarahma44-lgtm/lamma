import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'widgets/modern_navbar.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    usePathUrlStrategy();
    print('URL strategy set');

    // Initialize Firebase through our config
    print('Starting Firebase initialization...');
    await initFirebase();
    print('Firebase initialized');

    GoRouter.optionURLReflectsImperativeAPIs = true;
    print('GoRouter options set');

    print('Initializing app state...');
    final appState = FFAppState();
    await appState.initializePersistedState();
    print('App state initialized');

    print('Starting app...');
    runApp(ChangeNotifierProvider(
      create: (context) => appState,
      child: MyApp(),
    ));
    print('App started successfully');
  } catch (e, stackTrace) {
    print('CRITICAL ERROR initializing app:');
    print('Error: $e');
    print('Stack trace:');
    print(stackTrace);

    // If the error is a duplicate-app error, just proceed to run the app
    if (e
        .toString()
        .contains('A Firebase App named "[DEFAULT]" already exists')) {
      runApp(ChangeNotifierProvider(
        create: (context) => FFAppState(),
        child: MyApp(),
      ));
      return;
    }

    // Show a more detailed error UI for other errors
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Error initializing app',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    runApp(ChangeNotifierProvider(
                      create: (context) => FFAppState(),
                      child: MyApp(),
                    ));
                  },
                  child: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    // Initialize user stream
    userStream = lammaFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        if (_appStateNotifier.showSplashImage) {
          _appStateNotifier.stopShowingSplashImage();
        }
      });
    jwtTokenStream.listen((_) {});
  }

  @override
  void dispose() {
    authUserSub.cancel();
    userStream.drain();
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Lamma',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

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
