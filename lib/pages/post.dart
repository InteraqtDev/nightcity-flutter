import 'package:flutter/material.dart';
// import '../widgets/videoPlayer.dart';
import '../data0/RxList.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  // post 列表。post 类型有视频或者图片。
  RxList<Map<String, dynamic>> posts = RxList([
    {
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=1',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=1',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=2',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=3',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=3',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=5',
    },
    {
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=4',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=6',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=5',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=11',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=6',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=10',
    },
    {
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=7',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=1',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=8',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=3',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=9',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=5',
    },
    {
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=10',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=6',
    },
    {
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=11',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=11',
    },
  ]);

  RxList<Widget>? postNodes;

  createNodes() {
    if (postNodes != null) return;

    double width = MediaQuery.of(context).size.width;
    postNodes = posts.map<Widget>((post, _) {
      var containerWidth = post['type'] == 'image' ? (width / 2 -16) : width;
      return Container(
        key:  GlobalKey(),
        color: Colors.white,
        margin: EdgeInsets.only(right:8,bottom: 8),
        padding: EdgeInsets.only(bottom:8),
        width: containerWidth,
        child: Column(
          children: [
            // 图片
            Image.network(post['url'], fit: BoxFit.fitWidth, width: containerWidth, height: 200,),
            // 标题
            Text(post['title']),
            // 作者
            Text(post['author']),
          ],
        ),
      );
    });
  }

  int fetchTime = 1;
  int lastRefreshTime = 0;

  @override
  Widget build(BuildContext context) {

    if (postNodes == null) createNodes();

    if (lastRefreshTime != fetchTime) {
      lastRefreshTime = fetchTime;
      Future.delayed(Duration(seconds: 5), () {
        posts.unshift(_posts);
        setState(() {});
      });
    }

    return Scaffold(
      body: Container(
        color: Colors.grey.shade300,
        // 左 padding 8
        padding: EdgeInsets.only(left: 8),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
                title: Text('Home'),
                floating: true,
                flexibleSpace: Placeholder(),
                expandedHeight: 200,
                pinned: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(52),
                  child: Container(
                    color: Colors.white,
                    // search text input
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Search',
                      ),
                    ),
                  ),
                )
            ),
            SliverToBoxAdapter(
              child: Wrap(
                // direction: Axis.vertical,
                // alignment: WrapAlignment.center,
                // spacing:8.0,
                // runAlignment:WrapAlignment.center,
                // runSpacing: 8.0,
                // crossAxisAlignment: WrapCrossAlignment.center,
                // textDirection: TextDirection.rtl,
                // verticalDirection: VerticalDirection.up,
                // 遍历 posts，如果是图片类型 width 就是 width/2，如果是视频类型 width 就是 width.
                children:  postNodes?.data ?? [],

              ),
            )
          ],
        )
      )
    );
  }
}

List<Map<String, dynamic>> _posts = [
  {
    'type': 'image',
    'url': 'https://picsum.photos/200/200?random=12',
    'title': 'Image Title',
    'author': 'Image Author',
    'avatar': 'https://picsum.photos/200/200?random=10',
  },
  {
    'type': 'image',
    'url': 'https://picsum.photos/200/200?random=12',
    'title': 'Image Title',
    'author': 'Image Author',
    'avatar': 'https://picsum.photos/200/200?random=10',
  }
];