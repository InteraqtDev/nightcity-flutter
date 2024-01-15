
import 'dep.dart';
import 'Observable.dart';
import 'notify.dart';
import 'operations.dart';
import 'computed.dart';


class Atom<T> extends Computed<T> implements Observable<T, dynamic, dynamic>{
  @override
  late Map<dynamic, Dep>? depsMap = {};
  @override
  late T data;
  Atom(T? source, [Getter<T>? getter, ApplyPatchType? applyPatch,
  DirtyCallback? scheduleRecompute, Callbacks? callbacks,
  SkipIndicator? skipIndicator, bool? forceAtom])
      : super(getter, applyPatch, scheduleRecompute, callbacks, skipIndicator,
  forceAtom) {

    if (getter ==null) {
      data = source!;
    }
  }
  T? call([T? nextValue]) {
    if (nextValue !=null) {
      data = nextValue;
      Notifier.instance.trigger(this, TriggerOpTypes.ATOM, InputTriggerInfo(key: 'value', newValue: nextValue));
    }

    Notifier.instance.track(this, TrackOpTypes.ATOM, 'value');
    return data;
  }
  @override
  operator [](dynamic index) {
    throw 'not support';
  }
  // 重载 []= 转发到 set 上
  @override
  operator []=(dynamic index, dynamic value) {
    throw 'not support';
  }
  T operator +(dynamic target) {
    if (data is String && target is String) {
      return ((data as String) + target) as T;
    }

    if ((data is num && target is num)) {
      return ((data as num) + target) as T;
    }
    Notifier.instance.track(this, TrackOpTypes.ATOM, 'value');

    throw 'value and target must be num';
  }
  T operator -(dynamic target) {
    if (!(data is num && target is num)) {
      throw 'value and target must be num';
    }
    Notifier.instance.track(this, TrackOpTypes.ATOM, 'value');

    return ((data as num) - target) as T;
  }
  getRaw(index) {
    Notifier.instance.track(this, TrackOpTypes.ATOM, 'value');
    return data!;
  }
}

Atom<T> atom<T>(T? value, [Getter<T>? getter, ApplyPatchType? applyPatch,
  DirtyCallback? scheduleRecompute, Callbacks? callbacks,
  SkipIndicator? skipIndicator, bool? forceAtom]
) {

  return Atom<T>(value, getter, applyPatch, scheduleRecompute, callbacks, skipIndicator, forceAtom);
}
