
import 'notify.dart';
import 'RxMap.dart';
import 'RxList.dart';
import 'atom.dart';
import 'reactiveEffect.dart';
import './Observable.dart';
import 'operations.dart';
import 'reactive.dart';

void replace(dynamic source, dynamic nextSourceValue) {
  if (source is RxList) {
    source.splice(0, source.length, nextSourceValue);
  } else if (source is RxMap) {
    // FIXME 增加  replace 方法
    source.replace(nextSourceValue);
  } else {
    assert(false, 'unknown source type to replace data');
  }
}

final computedToInternal = <dynamic, Computed>{};

typedef OnRecomputeCallback = void Function(Computed t);
typedef OnPatchCallback = void Function(Computed t);
typedef OnDestroyCallback = void Function(ReactiveEffect t);
typedef OnTrackCallback = void Function(ReactiveEffect onTrack);
typedef DirtyCallback = void Function(void Function([bool force]) recompute);
typedef SkipIndicator =({
  bool? skip
});

class Callbacks {
  OnRecomputeCallback? onRecompute;
  OnPatchCallback? onPatch;
  OnDestroyCallback? onDestroy;
  OnTrackCallback? onTrack;
  Callbacks({this.onRecompute, this.onPatch, this.onDestroy, this.onTrack});
}

typedef ApplyPatchType<T> = Function(Computed<T> target, List<TriggerInfo> info);


typedef TrackFn = Function(dynamic target,TrackOpTypes type,dynamic key);
typedef Getter<R> = R Function(dynamic target);


void destroyComputed(Observable computedItem) {
  final internal = computedToInternal[computedItem]!;
  ReactiveEffect.destroy(internal, false);
}


class Computed<T> extends ReactiveEffect {
  bool isDirty = false;
  late T data;
  bool immediate = false;
  bool recomputing = false;
  List<TriggerInfo> triggerInfos = [];
  DirtyCallback? scheduleRecompute;

  Getter<T>? getter;
  ApplyPatchType<T>? applyPatch;
  Callbacks? callbacks;
  SkipIndicator? skipIndicator;
  bool? forceAtom;

  Computed(this.getter, [this.applyPatch, this.scheduleRecompute,
      this.callbacks, this.skipIndicator, this.forceAtom])
      : super(getter !=null) {

    if (getter == null) {
      return;
    }

    if (scheduleRecompute is Function) {
      scheduleRecompute = scheduleRecompute;
    } else {
      immediate = true;
    }
    if (callbacks?.onDestroy != null) onDestroy = callbacks!.onDestroy;
    if (callbacks?.onTrack != null) onTrack = callbacks!.onTrack;
    final initialValue = super.run(null);
    data = initialValue;
    computedToInternal[data] = this;
  }



  @override
  T effectFn() {
    if (applyPatch != null) {
      Notifier.instance.pauseTracking();
      final result = getter!(this);
      Notifier.instance.resetTracking();
      return result;
    } else {
      return getter!(this);
    }
  }
  @override
  void run(List<TriggerInfo>? infos) {
    if (skipIndicator?.skip == true) return;
    triggerInfos.addAll(infos!);
    isDirty = true;
    if (immediate) {
      recompute();
    } else {
      scheduleRecompute!(recompute);
    }
  }
  // appylPatch 中的 工具函数
  // manual track
  track(target, type, key) {
    Notifier.instance.enableTracking();
    Notifier.instance.track(target, type, key);
    Notifier.instance.resetTracking();
  }
  collect() {
    return ReactiveEffect.collectEffect();
  }
  destroy(ReactiveEffect effect) {
    return ReactiveEffect.destroy(effect);
  }

  void recompute([bool forceRecompute = false]) {
    if (!isDirty && !forceRecompute) return;
    if (forceRecompute || applyPatch == null) {
      final newData = super.run(null);
      if (this is Atom) {
        (this as Atom)(newData);
      } else {
        replace(this, newData);
      }
    } else {
      Notifier.instance.pauseTracking();
      applyPatch!(this, triggerInfos);
      Notifier.instance.pauseTracking();
      triggerInfos.clear();
    }
    isDirty = false;
  }
}


Observable? computed(
    Getter getter,
    [
      ApplyPatchType? applyPatch,
      DirtyCallback? dirtyCallback,
      Callbacks? callbacks,
      SkipIndicator? skipIndicator,
      bool? forceAtom
    ]
) {
  final internal = Computed(getter, applyPatch, dirtyCallback, callbacks,
      skipIndicator, forceAtom);
  return internal.data;
}

Atom<T> atomComputed<T>(
    Getter getter, ApplyPatchType? applyPatch, DirtyCallback? dirtyCallback,
    [Callbacks? callbacks,
      SkipIndicator? skipIndicator]) {
  final internal = Computed(getter, applyPatch, dirtyCallback, callbacks,
      skipIndicator, true);
  return internal.data! as Atom<T>;
}

void recompute(Observable computedItem, [bool force = false]) {
  final internal = computedToInternal[computedItem]!;
  internal.recompute(force);
}

bool isComputed(target) {
  return computedToInternal.containsKey(target);
}

dynamic getComputedGetter(target) {
  return computedToInternal[target]?.getter;
}


