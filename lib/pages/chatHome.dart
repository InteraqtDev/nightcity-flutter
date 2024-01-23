// 登录界面，需要输入用户名和密码
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'contacts.dart';
import 'recentChat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _bottomNavigationColor = Colors.white;
  final _selectedColor = Colors.cyan;
  int _currentIndex = 2;

  /// PageView 控制器 , 用于控制 PageView
  final _pageController = PageController(
    /// 初始索引值
    initialPage: 1,
  );
  @override
  void dispose() {
    super.dispose();
    /// 销毁 PageView 控制器
    _pageController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: PageView(

        /// 控制跳转翻页的控制器
        controller: _pageController,
        /// 页面滑动
        /// 这里设置 PageView 页面滑动也能
        onPageChanged: (index) {
          setState(() {
            // 更新当前的索引值
            _currentIndex = index;
          });
        },
        /// Widget 组件数组 , 设置多个 Widget 组件
        /// 同一时间只显示一个页面组件
        children: routes.where((route) => route['index'] != null).map((route) {
          return route['page'] as Widget;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // 黑色背景，白色 icon
        backgroundColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: routes.map((route) {
          return BottomNavigationBarItem(
            icon: Icon(
              route['icon'] as IconData,
              color: _bottomNavigationColor,
            ),
            activeIcon: Icon(
              route['icon'] as IconData,
              color: _selectedColor,
            ),
            label: route['label'] as String,
          );
        }).toList(),
        currentIndex: _currentIndex,
        onTap: (int index) {
          var route = routes[index];
          if (route['index'] != null) {
            _pageController.jumpToPage(route['index']! as int);
            setState(() {
              _currentIndex = index;
            });
          } else {
            context.go(route['path']! as String);
          }

        },
      ),
    );
  }
}

var routes = [
  {
    'icon': Icons.arrow_back,
    'label': 'cast',
    'path': '/home',
  },
  {
    'page': const ContactScreen(),
    'icon': Icons.people_alt_outlined,
    'label': 'contacts',
    'index': 0,
  },
  {
    'page': const RecentChatScreen(),
    'icon': Icons.message,
    'label': 'recent',
    'index': 1,
  },
];