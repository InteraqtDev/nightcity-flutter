import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data0/RxList.dart';

class RecentChatScreen extends StatefulWidget {
  const RecentChatScreen({Key? key}) : super(key: key);

  @override
  State<RecentChatScreen> createState() => RecentChatScreenState();
}

class RecentChatScreenState extends State<RecentChatScreen> {
  RxList<Map<String, dynamic>> recentChats = RxList([
    // {
    //   'id': 1,
    //   'type': 'peer',
    //   'target': {
    //     'id': 1,
    //     'name': 'Video Author',
    //     'avatar': 'https://picsum.photos/200/200?random=1',
    //   },
    //
    // },
    // {
    //   'id': 2,
    //   'type': 'peer',
    //   'target': {
    //     'id': 2,
    //     'name': 'Video Author',
    //     'avatar': 'https://picsum.photos/200/200?random=1',
    //   },
    // },
  ]);

  Widget build(BuildContext context) {
    var displayNode = recentChats.length == 0
        ? Center(
            child: Text(
              '暂无聊天记录',
              style: TextStyle(color: Colors.white),
            ),
          )
        : ListView.builder(
            itemCount: recentChats.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(recentChats[index]['target']['avatar']),
                ),
                title: Text(
                  recentChats[index]['target']['name'],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  context.go('/message/${recentChats[index]['id']}');
                },
              );
            },
          );

    return Scaffold(
        // 黑色背景
        backgroundColor: Colors.black,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // 用 listView 构建的联系人列表
          child: displayNode,
        ));
  }
}
