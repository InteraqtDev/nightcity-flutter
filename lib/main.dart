import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/connect.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/cast.dart';
import 'pages/message.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      // redirect 到 connect page
      redirect: (_, __) {return '/login';} ,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'connect',
          builder: (BuildContext context, GoRouterState state) {
            return const ConnectScreen();
          },
        ),
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const  LoginScreen();
          },
        ),
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

