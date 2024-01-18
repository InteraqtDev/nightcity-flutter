import 'dart:math';

import 'package:nightcity_flutter/data0/RxMap.dart';

import 'computed.dart';
import './Observable.dart';
import 'atom.dart';
import 'dep.dart';
import 'notify.dart';
import 'operations.dart';
import 'util.dart';
import 'reactiveEffect.dart';
import 'reactive.dart';


class RxList<T> extends Computed<List<T>> implements Observable<List<T>, int, T> {
  @override
  late List<T> data;
  @override
  late Map<dynamic, Dep>? depsMap = {};
  Map<int, Dep> indexKeyDeps = {};
  List<Atom<int>>? atomIndexes;
  int atomIndexesDepCount = 0;
  List<List<ReactiveEffect>> effectFramesArray =[];

  RxList(List<T>? source, [Getter<List<T>>? getter, ApplyPatchType? applyPatch,
      DirtyCallback? scheduleRecompute, Callbacks? callbacks,
      SkipIndicator? skipIndicator, bool? forceAtom])
      : super(getter, applyPatch, scheduleRecompute, callbacks, skipIndicator,
      forceAtom) {
    if (source != null) {
      data = source;
    }
  }

  List<T> push(List<T> items) {
    return splice(data.length, 0, items);
  }

  T pop() {
    return splice(data.length - 1, 1)[0];
  }

  T shift() {
    return splice(0, 1, [])[0];
  }

  List<T> unshift(List<T> items) {
    return splice(0, 0, items);
  }

  List<T> splice(int start, int deleteCount, [List<T>? inputItems]) {
    Notifier.instance.pauseTracking();
    Notifier.instance.createEffectSession();

    final originLength = data.length;
    final deleteItemsCount = min(deleteCount, originLength - start);
    final result = data.sublist(start, start + deleteCount);
    var items = inputItems ?? <T>[];
    if (items.isEmpty) {
      data.removeRange(start, start + deleteCount);
    } else {
      data.replaceRange(start, start + deleteCount, items);

    }

    if (deleteItemsCount != items.length) {
      Notifier.instance.trigger<List<T>, int, T>(this, TriggerOpTypes.SET,
          InputTriggerInfo(key: 'length', newValue: data.length));
    }
    final changedIndexEnd =
    deleteItemsCount != items.length ? data.length : start + items.length;
    if (indexKeyDeps.isNotEmpty) {
      for (var i = start; i < changedIndexEnd; i++) {
        final dep = indexKeyDeps[i]!;
        Notifier.instance.triggerEffects(dep, {
          'source': this,
          'key': i,
          'newValue': data[i],
        });
      }
    }
    Notifier.instance.trigger(this, TriggerOpTypes.METHOD,
        InputTriggerInfo(method: 'splice', argv: [start, deleteCount, items]) );
    Notifier.instance.digestEffectSession();
    Notifier.instance.resetTracking();
    return result;
  }

  void set(int index, dynamic inputValue) {
    var value = (inputValue is RxList || inputValue is RxMap) ? inputValue.data : inputValue;
    data[index] = value as T;
    final dep = indexKeyDeps[index];
    if (dep != null) {
      Notifier.instance.triggerEffects(dep, {
        'source': this,
        'key': index,
        'newValue': value,
      });
    }
    Notifier.instance.trigger(this, TriggerOpTypes.EXPLICIT_KEY_CHANGE,
        InputTriggerInfo(key: index, newValue: value));
  }

  dynamic at(int index) {
    final dep = Notifier.instance.track(this, TrackOpTypes.GET, index);
    if (dep != null && !indexKeyDeps.containsKey(index)) {
      indexKeyDeps[index] = dep;
    }

    return reactive(data[index], this, index);
  }
  // 重载 [] operator，转发到 at 上。
  operator [](int index) {
    return at(index);
  }
  // 重载 []= 转发到 set 上
  operator []=(int index, T value) {
    set(index, value);
  }


  dynamic get(int index) {
    return at(index);
  }

  getRaw(int index) {
    Notifier.instance.track(this, TrackOpTypes.GET, index);

    return data[index];
  }

  void forEach(void Function(T item, int index) handler) {
    for (var i = 0; i < data.length; i++) {
      handler(at(i)!, i);
    }
    Notifier.instance.track(this, TrackOpTypes.GET, 'length');
  }

  // removeAt，转发到 splice 上
  T? removeAt(int index) {
    return splice(index, 1, [])[0];
  }

  // Iterator<dynamic> get iterator {
  //   var index = 0;
  //   final data = this.data;
  //   Notifier.instance.track(this, TrackOpTypes.ITERATE, 'length');
  //   return Iterator<dynamic>(() {
  //     if (index < data.length) {
  //       final value = at(index);
  //       index++;
  //       return value;
  //     } else {
  //       return null;
  //     }
  //   });
  // }

  RxList<U> map<U>(dynamic Function(dynamic item, Atom<int>? index) mapFn, [bool? needIndex]) {
    final source = this;
    if (needIndex == true) {
      atomIndexesDepCount++;
    }
    return RxList<U>(
      null,
      (that) {
        var mappedList = that as RxList<U>;
        mappedList.track(source, TrackOpTypes.METHOD, TriggerOpTypes.METHOD);
        mappedList.track(source, TrackOpTypes.EXPLICIT_KEY_CHANGE,
            TriggerOpTypes.EXPLICIT_KEY_CHANGE);
        return source.data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          // FIXME 代码要检查
          final getFrame = ReactiveEffect.collectEffect();
          final newItem = mapFn(source.at(index), source.atomIndexes?[index]);
          mappedList.effectFramesArray.add(getFrame());
          return newItem as U;
        }).toList();
      },
      (that, List<TriggerInfo> triggerInfos) {
        var  mappedList = that as RxList<U>;
        for (var info in triggerInfos) {
          final method = info.method;
          final argv = info.argv;
          final result = info.result;
          final key = info.key;
          final newValue = info.newValue;
          assert( method == 'splice' || key != null, 'trigger info has no method and key');
          if (method == 'splice') {
            final newItemsInArgs = (argv![2] ?? []) as List<T>;
            final effectFrames = <List<ReactiveEffect>>[];
            final newItems = newItemsInArgs.asMap().entries.map((entry) {
              final index = (entry.key + argv[0]) as int;
              final item = source.at(index);
              final getFrame = collect!();
              final newItem = mapFn(item, source.atomIndexes?[index]);
              effectFrames.add(getFrame());
              return newItem as U;
            }).toList();

            mappedList.splice(argv[0], argv[1], newItems);

            final deletedFrames = mappedList.effectFramesArray!.sublist(argv[0], argv[0] + argv[1]);
            mappedList.effectFramesArray!.replaceRange(argv[0], argv[0] + argv[1], effectFrames);
            for (var frame in deletedFrames) {
              for (var effect in frame) {
                mappedList.destroy(effect);
              }
            }
          } else {
            final index = key as int;
            final getFrame = mappedList.collect();
            mappedList.set(index, mapFn(source.at(index), source.atomIndexes?[index]));
            final newFrame = getFrame();
            for (var effect in mappedList.effectFramesArray[index]) {
              mappedList.destroy(effect);
            }
            mappedList.effectFramesArray[index] = newFrame;
          }
        }
      },
        null,
      Callbacks(
        onDestroy: (effect) {
          if (needIndex ==true) {
            atomIndexesDepCount--;
          }
        },
      ),
      null,
      null,
    );
  }

  void find() {}

  void findIndex() {}

  void filter() {}

  void groupBy() {}

  void indexBy() {}

  int get length {
    return data.length;
  }

  void onUntrack(ReactiveEffect effect) {}
}


