import 'computed.dart';
import './Observable.dart';
import 'dep.dart';
import 'reactiveEffect.dart';
import 'notify.dart';
import 'operations.dart';
import 'reactive.dart';




class RxMap<K,V> extends Computed<Map<K, V>> implements Observable<Map<K, V>, K, V> {
  @override
  late Map<K, V> data = {};
  @override
  late Map<dynamic, Dep>? depsMap = {};
  Map<dynamic, List<ReactiveEffect>>? keyToEffectFrames = Map();

  RxMap(Map<K, V>? source, [Getter<Map<K, V>>? getter, ApplyPatchType? applyPatch,
      DirtyCallback? scheduleRecompute, Callbacks? callbacks,
      SkipIndicator? skipIndicator, bool? forceAtom])
      : super(getter, applyPatch, scheduleRecompute, callbacks, skipIndicator,
      forceAtom) {

    if (source != null) {
      data = source;
    }
  }
  @override
  noSuchMethod(Invocation invocation) {
    var memberNameStr = invocation.memberName.toString();
    var memberName= memberNameStr.substring(8, memberNameStr.length-2) as K;

    var isGetter = invocation.isGetter || invocation.isMethod && invocation.positionalArguments.isEmpty;
    var isSetter = invocation.isSetter || invocation.isMethod && invocation.positionalArguments.isNotEmpty;
    if (isGetter) {
      // 处理属性的获取
      final key = memberName;
      Notifier.instance.track(this, TrackOpTypes.GET, key);
      var result = reactive(data[key], this, key);
      // 说明是直接 invoke leaf atom
      return (invocation.isMethod) ? result() : result;
    } else if (isSetter) {
      // 处理属性的设置
      var newValue = invocation.positionalArguments.first;
      var key = invocation.isSetter ? memberName.toString().substring(0, memberName.toString().length-1) : memberName.toString();

      data[key as K] = newValue;
      Notifier.instance.trigger<Map<K, V>, K, V>(
          this, TriggerOpTypes.SET,
          InputTriggerInfo(key: key, newValue: newValue)
      );
      return;
    } else{
      throw 'not support';
    }

    return super.noSuchMethod(invocation);
  }
  @override
  operator [](K index) {
    Notifier.instance.track(this, TrackOpTypes.GET, index);
    return data[index];
  }
  // 重载 []= 转发到 set 上
  @override
  operator []=(K index, V value) {
    data[index] = value;

    Notifier.instance.trigger<Map<K, V>, K, V>(
        this, TriggerOpTypes.SET,
        InputTriggerInfo(key: index, newValue: value)
    );
    Notifier.instance.trigger<Map<K, V>, K, V>(
        this, TriggerOpTypes.EXPLICIT_KEY_CHANGE,
        InputTriggerInfo(key: index, newValue: value)
    );
  }
  getRaw(K index) {
    Notifier.instance.track(this, TrackOpTypes.GET, index);
    return data[index]!;
  }
  replace(Map<K, V> nextValue) {
    Notifier.instance.pauseTracking();
    Notifier.instance.createEffectSession();

    // 对比 data 和 nextValue，如果值不相同就 set，并 trigger set，否则不做任何事情。
    // CAUTION 这里的比较是浅比较，如果是深比较，那么就需要考虑性能问题了。
    nextValue.forEach((key, value) {
      if (data[key] != value) {
        data[key] = value;
        Notifier.instance.trigger<Map<K, V>, K, V>(
            this, TriggerOpTypes.SET,
            InputTriggerInfo(key: key, newValue: value)
        );
      }
    });

    Notifier.instance.trigger<Map<K, V>, K, V>(
        this, TriggerOpTypes.METHOD,
        InputTriggerInfo(method: 'replace', argv: [nextValue])
    );

    Notifier.instance.digestEffectSession();
    Notifier.instance.resetTracking();

  }
}