void A(void Function([int]) b) {
  int c = 10;  // 示例参数
  b(c);        // 调用 b 并传递参数
}

void main() {
  // 使用 A 的例子

  // // b 使用参数
  // A((int? c) {
  //   print("Function with parameter: $c");
  // });
  //
  // // b 忽略参数
  // A(([_]) {
  //   print("Function ignoring parameter");
  // });
  //
  // // b 完全不定义任何参数
  // A(() {
  //   print("Function with no parameter");
  // });
}
