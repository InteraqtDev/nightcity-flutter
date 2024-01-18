import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/cast.dart';
import 'pages/message.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'cast',
          builder: (BuildContext context, GoRouterState state) {
            return const CastScreen();
          },
        ),
        GoRoute(
          path: 'message',
          builder: (BuildContext context, GoRouterState state) {
            return const MessageScreen();
          },
        ),
      ],
    ),
  ],
);



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

