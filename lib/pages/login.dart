// 登录界面，需要输入用户名和密码
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // 黑色背景
        backgroundColor: Colors.black,
        // body 是一个输入 ip 的框，上面写的文字是"连接至燃石宇宙"
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                opacity: 0.2,
                image: AssetImage("assets/login.png"),
                fit: BoxFit.fitHeight
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '登录',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 300,
                  child: TextField(
                    // focus时白色文字
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: '用户名',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 300,
                  child: TextField(
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                      labelText: '密码',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  // 无圆角按钮，黑底白字
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                  onPressed: () {
                    context.go('/home');
                  },
                  child: Text('登录'),
                ),
              ],
            ),
          ),
        ));
  }
}
