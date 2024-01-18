import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' as OpenIM;

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: 'sf63ap7ljyul',
  );
  String? token;

  Future initOpenIm()  async {
    final success = await OpenIM.OpenIM.iMManager.initSDK(
      platformID: 2,   // Platform, referring to the IMPlatform class.
      apiAddr: "http://192.168.31.150:10002",   // SDK's API interface address.
      wsAddr: "ws://192.168.31.150:10001",    // SDK's WebSocket address.
      dataDir: (await getApplicationDocumentsDirectory()).path,   // Data storage path. For example, you can use getApplicationDocumentsDirectory() to get a path.
      objectStorage: 'cos',  // Image server (default is 'cos').
      logLevel: 6,   // Log level (default value is 6).
      listener: OpenIM.OnConnectListener(
        onConnectSuccess: () {
          // Successfully connected to the server.
        },
        onConnecting: () {
          // Connecting to the server, suitable for showing a "Connecting" status on the UI.
        },
        onConnectFailed: (code, errorMsg) {
          // Failed to connect to the server, you can notify the user that the current network connection is not available.
        },
        onUserTokenExpired: () {
          // User's login token (UserSig) has expired, prompting the user to log in again with a new token.
        },
        onKickedOffline: () {
          // The current user has been kicked offline, and you can prompt the user to log in again with a message like "You have been logged in on another device. Do you want to log in again?"
        },
      ),
    );
  }

  Future getUserToken() async {
    final response =  await http.post(
      Uri.parse('http://192.168.31.150:4000/api/getUserToken'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-user-id': _user.id,
      },
      body: jsonEncode(<String, num>{
        'platformId': 2,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load album');
    }

    var data = (jsonDecode(response.body) as Map<String, dynamic>);
    token = data['data']['token'];
  }

  Future setupListener() async {

    OpenIM.OpenIM.iMManager
    //
      ..userManager.setUserListener(OpenIM.OnUserListener(
      ))
    // Add message listener (remove when not in use)
      ..messageManager.setAdvancedMsgListener(OpenIM.OnAdvancedMsgListener(
      ))

    // Set up message sending progress listener
      ..messageManager.setMsgSendProgressListener(OpenIM.OnMsgSendProgressListener(
      ))
    // Set up friend relationship listener
      ..friendshipManager.setFriendshipListener(OpenIM.OnFriendshipListener(
      ))

    // Set up conversation listener
      ..conversationManager.setConversationListener(OpenIM.OnConversationListener(
      ))

    // Set up group listener
      ..groupManager.setGroupListener(OpenIM.OnGroupListener(
      ));


    //Receive
    OpenIM.OpenIM.iMManager.messageManager.setAdvancedMsgListener(OpenIM.OnAdvancedMsgListener(
        onRecvNewMessage:(OpenIM.Message msg) {
          // Received new message 📨
          final textMessage = types.TextMessage(
            author: types.User(id: msg.sendID!, firstName:msg.senderNickname),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: msg.serverMsgID!,
            text: msg.textElem!.content!,
          );
          _addMessage(textMessage);
        }
    ));
  }

  Future loginUser() async {
    await initOpenIm();
    await getUserToken();
    await setupListener();
    try {
      await OpenIM.OpenIM.iMManager.login(
        userID: _user.id, // userID is obtained from your own business server
        token: token!, // The token should be acquired by your business server by exchanging with OpenIM server based on a secret key
      );
    } catch (e) {
      print(e);
    }

  }

  Future sendMessage(String text) async {

    final response =  await http.post(
      Uri.parse('http://192.168.31.150:10002/msg/send_msg'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'operationID': "1646445464564",
        'token': token!,

      },
      body: jsonEncode(<String, dynamic>{
        "sendID": "$_user.id",
        "recvID": "h4eqq7niohkp",
        "groupID": "",
        "senderNickname": "openIMAdmin-Gordon",
        "senderFaceURL": "http://www.head.com",
        "senderPlatformID": 2,
        "content": {
          "content": "$text"
        },
        "contentType": 101,
        "sessionType": 1,
        "isOnlineOnly": false,
        "notOfflinePush": false,
        "sendTime": 1695212630740,
        "offlinePushInfo": {
          "title": "send message",
          "desc": "",
          "ex": "",
          "iOSPushSound": "default",
          "iOSBadgeCount": true
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load album');
    }

    final data= jsonDecode(response.body) as Map<String, dynamic>;
    print(data);


  }

  Future sendMessage2(String text) async {
    OpenIM.Message msg = await OpenIM.OpenIM.iMManager.messageManager.createTextMessage(text: text);
  OpenIM.OpenIM.iMManager.messageManager.sendMessage(
      message: msg,
      offlinePushInfo: OpenIM.OfflinePushInfo(title:"you have new message"),
    userID: "h4eqq7niohkp",
      groupID: ""
  ).then((value) {
    print(value);
  })
      .catchError((error, _){
        print(error);
  })
        .whenComplete(() {

  });;

  }

  @override
  void initState() {
    super.initState();
    // FIXME 垃圾 sdk
    loginUser();
    // getUserToken();

  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);


    sendMessage2(message.text);

  }

  void _loadMessages() async {
    // final response = await rootBundle.loadString('assets/messages.json');
    // final messages = (jsonDecode(response) as List)
    //     .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
    //     .toList();
    //
    // setState(() {
    //   _messages = messages;
    // });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Chat(
      messages: _messages,
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
      theme: const DefaultChatTheme(
        seenIcon: Text(
          'read',
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
      ),
    ),
  );
}