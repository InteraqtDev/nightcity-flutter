import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'shop.dart';
import 'post.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bottomNavigationColor = Colors.white;
  final _selectedColor = Colors.cyan;
  int _currentIndex = 0;

  /// PageView 控制器 , 用于控制 PageView
  final _pageController = PageController(
    /// 初始索引值
    initialPage: 0,
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
            _pageController.jumpToPage(index);
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
    'page': const PostScreen(),
    'icon': Icons.home,
    'label': 'home',
    'index': 0,
  },
  {
    'page': ShopScreen(),
    'icon': Icons.shop,
    'label': 'shop',
    'index': 1,
  },
  {
    'icon': Icons.cast,
    'label': 'cast',
    'path': '/cast'
  },
  {
    'icon': Icons.message,
    'label': 'message',
    'path': '/chat'
  }
];