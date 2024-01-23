import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      'id': 1,
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=1',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=1',
    },
    {
      'id': 2,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=2',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=3',
    },
    {
      'id': 3,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=3',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=5',
    },
    {
      'id': 4,
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=4',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=6',
    },
    {
      'id': 5,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=5',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=11',
    },
    {
      'id': 6,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=6',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=10',
    },
    {
      'id': 7,
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=7',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=1',
    },
    {
      'id': 8,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=8',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=3',
    },
    {
      'id': 9,
      'type': 'image',
      'url': 'https://picsum.photos/200/200?random=9',
      'title': 'Image Title',
      'author': 'Image Author',
      'avatar': 'https://picsum.photos/200/200?random=5',
    },
    {
      'id': 10,
      'type': 'video',
      'url': 'https://picsum.photos/200/200?random=10',
      'title': 'Video Title',
      'author': 'Video Author',
      'avatar': 'https://picsum.photos/200/200?random=6',
    },
    {
      'id': 11,
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
      var containerWidth = post['type'] == 'image' ? (width - 24) / 2 : width;
      return Container(
        key: GlobalKey(),
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 8),
        width: containerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // 元素都左对齐
          children: [
            GestureDetector(
              onTap: () {
                context.go('/postDetail/${post['id']}');
              },
              child: Container(
                  // 点击跳转到帖子详情页
                  height: 200,
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),

                  // 背景是图片，高度是200，宽度是 containerWidth，必须填满
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(post['url']),
                    ),
                  ),
                  // child 在 container 底部
                  alignment: Alignment.bottomLeft,
                  // 点击跳转到帖子详情页
                  child: Row(children: [
                    // 眼睛 icon 和播放数
                    Expanded(
                      child: Row(
                        // spaceBetween，两端对齐
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                              size: 16,
                            ),
                            // 播放数
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: Text(
                                '100',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ]),
                          Row(children: [
                            const Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                              size: 16,
                            ),
                            // 播放数
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: Text(
                                '100',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ])
                        ],
                      ),
                    ),
                  ])),
            ),
            Container(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题，左对齐
                      Text(
                        post['title'],
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // 作者
                      Text(post['author']),
                    ]))
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
      Future.delayed(const Duration(seconds: 5), () {
        posts.unshift(_posts);
        setState(() {});
      });
    }

    return Scaffold(
        body: Container(
            color: Colors.grey.shade300,
            // 左 padding 8
            child: RefreshIndicator(
                onRefresh: () async {
                  fetchTime++;
                  setState(() {});
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                        title: Container(
                          color: Colors.white,
                          // 左右 flex 布局，左边是当前用户头像和搜索框，右边是创建 post 的 icon
                          child: Row(
                            children: [
                              // 左边是当前用户头像和搜索框
                              Expanded(
                                child: Row(
                                  children: [
                                    // 当前用户头像
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: const CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            'https://picsum.photos/200/200?random=1'),
                                      ),
                                    ),
                                    // 搜索框
                                    const Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                          contentPadding: EdgeInsets.all(10),
                                          hintText: '搜索',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 创建 post 的按钮，按钮里面是添加的 icon
                              Container(
                                margin:
                                    const EdgeInsets.only(right: 8, left: 8),
                                child: IconButton(
                                  // 按钮是黑色的
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                  ),
                                  color: Colors.white,
                                  icon: const Icon(
                                    Icons.add,
                                  ),
                                  onPressed: () {
                                    fetchTime++;
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        // 隐藏后退按钮
                        automaticallyImplyLeading: false,
                        // title 不要 padding
                        titleSpacing: 0,
                        floating: true,
                        pinned: true,
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(48),
                          child: Container(
                            color: Colors.white,
                            // tab，选项有 最新、热门
                            child: Row(
                              children: [
                                // 最新
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        '最新',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ),
                                // 热门
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      '热门',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        width: double.infinity,
                        child: Wrap(
                          // direction: Axis.vertical,
                          // alignment: WrapAlignment.center,
                          spacing: 8.0,
                          // runAlignment:WrapAlignment.center,
                          runSpacing: 8.0,
                          // crossAxisAlignment: WrapCrossAlignment.center,
                          // textDirection: TextDirection.rtl,
                          // verticalDirection: VerticalDirection.up,
                          // 遍历 posts，如果是图片类型 width 就是 width/2，如果是视频类型 width 就是 width.
                          children: postNodes?.data ?? [],
                        ),
                      ),
                    )
                  ],
                ))));
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
