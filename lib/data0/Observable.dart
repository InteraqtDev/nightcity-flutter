import './dep.dart';
typedef KeyToDepMap = Map<dynamic, Dep>;

abstract class Observable<T, K, V>{
  late KeyToDepMap? depsMap;
  operator [](K index);
  operator []=(K index, V value);
  V getRaw(K index);
}


