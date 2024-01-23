import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nightcity_flutter/pages/message.dart';
import 'pages/chatHome.dart';
import 'pages/connect.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/cast.dart';
import 'pages/postDetail.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      // redirect 到 connect page
      redirect: (_, state) {
        if (state.fullPath == '/') {
          return '/home';
        }
      } ,
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
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'postDetail/:postId',
          builder: (BuildContext context, GoRouterState state) {
            return PostDetailScreen(postId: state.pathParameters["postId"]!.toString(),);
          },
        ),
        GoRoute(
          path: 'cast',
          builder: (BuildContext context, GoRouterState state) {
            return const CastScreen();
          },
        ),
        GoRoute(
          path: 'chat',
          builder: (BuildContext context, GoRouterState state) {
            return const ChatScreen();
          },
        ),
        GoRoute(
          path: 'message/:chatId',
          builder: (BuildContext context, GoRouterState state) {
            return MessageScreen(chatId: state.pathParameters["chatId"]!);
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

