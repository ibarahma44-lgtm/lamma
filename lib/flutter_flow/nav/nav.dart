import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/home/home_widget.dart';
import '/events/events_widget.dart';
import '/events/lamma_events_widget.dart';
import '/events/movie_night_widget.dart';
import '/games_dashboard/games_list_widget.dart';
import '/game/stranger_game_widget.dart';
import '/family_chat/family_chat_widget.dart';
import '/family_creation/family_creation_widget.dart';
import '/family_dashboard/family_dashboard_widget.dart';
import '/wheel_of_chores/wheel_of_chores_widget.dart';
import '/family_information/family_information_widget.dart';
import '/events/movie_nights_list_widget.dart';
import '/events/movie_selection_widget.dart';
import '/events/movie_player_widget.dart';

import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/family_not_found_widget.dart';
import '/components/join_family_widget.dart';
import '/account_profile_creation/auth_2_create/auth2_create_widget.dart';
import '/account_profile_creation/auth_2_login/auth2_login_widget.dart';
import '/account_profile_creation/auth_2_forgot_password/auth2_forgot_password_widget.dart';
import '/account_profile_creation/auth_2_create_profile/auth2_create_profile_widget.dart';
import '/account_profile_creation/auth_2_profile/auth2_profile_widget.dart';
import '/account_profile_creation/auth_2_edit_profile/auth2_edit_profile_widget.dart';

import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/events_record.dart';

import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) {
        print('Router error: ${state.error}');
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Error: ${state.error}'),
            ),
          ),
        );
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) {
            try {
              return appStateNotifier.loggedIn
                  ? HomeWidget()
                  : Auth2LoginWidget();
            } catch (e) {
              print('Error building initial route: $e');
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error: $e'),
                  ),
                ),
              );
            }
          },
        ),
        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          builder: (context, params) => HomeWidget(),
        ),
        FFRoute(
          name: Auth2CreateWidget.routeName,
          path: Auth2CreateWidget.routePath,
          builder: (context, params) => Auth2CreateWidget(),
        ),
        FFRoute(
          name: Auth2LoginWidget.routeName,
          path: Auth2LoginWidget.routePath,
          builder: (context, params) => Auth2LoginWidget(
            textemail: params.getParam(
              'textemail',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: Auth2ForgotPasswordWidget.routeName,
          path: Auth2ForgotPasswordWidget.routePath,
          builder: (context, params) => Auth2ForgotPasswordWidget(),
        ),
        FFRoute(
          name: Auth2CreateProfileWidget.routeName,
          path: Auth2CreateProfileWidget.routePath,
          builder: (context, params) => Auth2CreateProfileWidget(),
        ),
        FFRoute(
          name: Auth2ProfileWidget.routeName,
          path: Auth2ProfileWidget.routePath,
          builder: (context, params) => Auth2ProfileWidget(),
        ),
        FFRoute(
          name: Auth2EditProfileWidget.routeName,
          path: Auth2EditProfileWidget.routePath,
          builder: (context, params) => Auth2EditProfileWidget(),
        ),
        FFRoute(
          name: FamilyCreationWidget.routeName,
          path: FamilyCreationWidget.routePath,
          builder: (context, params) => FamilyCreationWidget(),
        ),
        FFRoute(
          name: FamilyDashboardWidget.routeName,
          path: FamilyDashboardWidget.routePath,
          builder: (context, params) => FamilyDashboardWidget(),
        ),
        FFRoute(
          name: FamilyInformationWidget.routeName,
          path: FamilyInformationWidget.routePath,
          builder: (context, params) => FamilyInformationWidget(
            familyRef:
                params.getParam('familyRef', ParamType.DocumentReference),
          ),
        ),
        FFRoute(
          name: WheelOfChoresWidget.routeName,
          path: WheelOfChoresWidget.routePath,
          builder: (context, params) => WheelOfChoresWidget(
            familyRef: params.getParam(
              'familyRef',
              ParamType.DocumentReference,
            ),
          ),
        ),
        FFRoute(
          name: 'LammaEvents',
          path: '/lamma-events',
          builder: (context, params) => LammaEventsWidget(
            familyRef: params.getParam(
              'familyRef',
              ParamType.DocumentReference,
            ),
          ),
        ),
        FFRoute(
          name: 'MovieNight',
          path: '/movie-night',
          builder: (context, params) => MovieNightWidget(
            familyRef: params.getParam(
              'familyRef',
              ParamType.DocumentReference,
            ),
          ),
        ),
        FFRoute(
          name: 'EventsList',
          path: '/events',
          builder: (context, params) => EventsWidget(
            familyRef: params.getParam(
              'familyRef',
              ParamType.DocumentReference,
            ),
          ),
        ),
        FFRoute(
          name: 'GamesList',
          path: '/games-list',
          builder: (context, params) => GamesListWidget(),
        ),
        FFRoute(
          name: 'StrangerGame',
          path: '/stranger-game',
          builder: (context, params) => StrangerGameWidget(
            gameId: params.getParam('gameId', ParamType.String) ?? '',
            familyId: params.getParam('familyId', ParamType.String) ?? '',
          ),
        ),
        FFRoute(
          name: 'FamilyChat',
          path: '/family-chat',
          builder: (context, params) => FamilyChatWidget(),
        ),
        FFRoute(
          name: 'MovieNightsList',
          path: '/movie-nights',
          builder: (context, params) => MovieNightsListWidget(
            familyRef:
                params.getParam('familyRef', ParamType.DocumentReference),
          ),
        ),
        FFRoute(
          name: 'MovieSelection',
          path: '/movie-selection',
          builder: (context, params) => MovieSelectionWidget(
            familyRef: params.getParam(
              'familyRef',
              ParamType.DocumentReference,
            ),
          ),
        ),
        FFRoute(
          name: 'MoviePlayer',
          path: '/movie-player',
          builder: (context, params) => MoviePlayerWidget(
            movieTitle: params.getParam('movieTitle', ParamType.String) ?? '',
            videoUrl: params.getParam('videoUrl', ParamType.String) ?? '',
          ),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/auth2Login';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
