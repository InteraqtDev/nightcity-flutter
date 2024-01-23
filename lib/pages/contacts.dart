import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data0/RxList.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => ContactScreenState();
}

class ContactScreenState extends State<ContactScreen> {
  RxList<Map<String, dynamic>> contacts = RxList([
    {
      'id': 1,
      'name': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=1',
    },
    {
      'id': 2,
      'name': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=3',
    },
  ]);

  Widget build(BuildContext context) {
    // 上面是联系人搜索框，下面是 listView 构建的联系人列表，列表每一项展示联系人头像和名字
    return Scaffold(
        // 黑色背景
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          // 隐藏返回
          automaticallyImplyLeading: false,
          // 联系人搜索框
          title: const TextField(
            decoration: InputDecoration(
              hintText: '搜索',
              hintStyle: TextStyle(color: Colors.white),
              // 只有 bottom border,白色
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),

            ),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // 用 listView 构建的联系人列表
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(contacts[index]['avatar']),
                ),
                title: Text(contacts[index]['name'], style: const TextStyle(color: Colors.white),),
                onTap: () {
                  context.go('/message/${contacts[index]['id']}');
                },
              );
            },
          ),

        ));
  }
}
