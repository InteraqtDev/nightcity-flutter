//
// // AppContext 是一个单例，上面存储了当前链接的服务器地址，用户的登录信息，具有清空所有信息的方法。
// //  它在初始化时会从 Shared_preference 中把这些信息取出来。
// //  在设置这些信息时，自动把它存到 Shared_preference 中。
// class AppContext {
//   static final AppContext _appContext = AppContext._internal();
//
//   factory AppContext() {
//     return _appContext;
//   }
//
//   AppContext._internal();
//
//   String _serverAddress;
//   String _username;
//   String _password;
//
//   String get serverAddress => _serverAddress;
//
//   String get username => _username;
//
//   String get password => _password;
//
//   void setServerAddress(String serverAddress) {
//     _serverAddress = serverAddress;
//
//
// }