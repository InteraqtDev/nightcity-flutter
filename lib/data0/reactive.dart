
import 'RxList.dart';
import 'RxMap.dart';
import 'atom.dart';
import 'Observable.dart';

class LeafAtom<T> extends Atom<T>{
  Observable host;
  dynamic key;
  LeafAtom( this.host, this.key): super(host.getRaw(key));
  @override
  T? call([T? nextValue]) {
    if (nextValue != null) {
      host[key] = nextValue;
    }
    return host.getRaw(key);
  }
  getRaw(index) {
    return host.getRaw(index)!;
  }
  T operator + (dynamic inputTarget) {
    var target = inputTarget is Atom ? inputTarget() : inputTarget;

    var self = host.getRaw(key);
    
    if (self is String && target is String) {
      return (self + target) as T;
    }

    if ((self is num && target is num)) {
      return (self + target) as T;
    }
    throw 'value and target must be num';
  }
  T operator - (dynamic inputTarget) {
    var target = inputTarget is Atom ? inputTarget() : inputTarget;
    var self = host.getRaw(key);

    if (!(self is num && target is num)) {
      throw 'value and target must be num';
    }
    return (self - target) as T;
  }
}

dynamic reactive<T, V>(dynamic item, [Observable? parent, dynamic key]) {

  if (item is Observable && targetToObservable[item] != null) {
    return targetToObservable[item] as Observable<T, dynamic, dynamic>;
  }

  dynamic newItem;
  if (item is List) {
    newItem= RxList<T>(item as List<T>, null, null, null, null, null, null);
  } else if (item is Map) {
    newItem= RxMap<T, V>(item as Map<T, V>, null, null, null, null, null, null);
  } else if (parent!=null){
    // CAUTION 这里是 return!，不需要缓存。
    return LeafAtom<T>(parent, key) ;
  } else {
    newItem= atom(item) as Observable<T, dynamic, dynamic>;
  }
  targetToObservable[item] = newItem;
  return newItem;
}

var targetToObservable = Expando();
