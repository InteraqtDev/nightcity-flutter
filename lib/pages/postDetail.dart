


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  PostDetailScreen({Key? key, required this.postId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Column(
        children: <Widget>[
          Image.network('https://via.placeholder.com/400x200'), // 示例图片
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Post Content Here',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // 假设有10条评论
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Comment ${index + 1}'),
                  subtitle: Text('Comment content here...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}