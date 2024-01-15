import 'dart:collection';

import './Observable.dart';
import 'RxList.dart';
import 'RxMap.dart';
import 'dep.dart';
import 'operations.dart';
import 'computed.dart';
import 'reactiveEffect.dart';
import 'util.dart';

class KeyItemPair {
  dynamic key;
  dynamic oldValue;
  dynamic newValue;
}

class TriggerResult {
  List<KeyItemPair>? add;
  List<KeyItemPair>? update;
  List<KeyItemPair>? remove;
}

typedef KeyToDepMap = HashMap<dynamic, Dep>;

class TrackFrame {
  Function start;
  List<Dep> deps = [];
  Function end;
  TrackFrame(this.start, this.end);
}

class TriggerStack {
  String? type;
  dynamic debugTarget;
  TriggerOpTypes? opType;
  dynamic key;
  dynamic oldValue;
  dynamic newValue;
  List<List<String>> targetLoc = [];
}

class InputTriggerInfo {
    String? method;
    List<dynamic>? argv;
    TriggerResult? result;
    dynamic key;
    dynamic newValue;
    dynamic oldValue;
    InputTriggerInfo({this.method, this.argv, this.result, this.key, this.newValue, this.oldValue});
}

class TriggerInfo {
  dynamic source;
  String? method;
  List<dynamic>? argv;
  TriggerResult? result;
  dynamic key;
  dynamic newValue;
  dynamic oldValue;
  TriggerInfo({this.source, this.method, this.argv, this.result, this.key, this.newValue, this.oldValue});
}

class DebuggerEventExtraInfo {
  dynamic target;
  TrackOpTypes? type;
  dynamic key;
  dynamic newValue;
  dynamic oldValue;
  Map<dynamic, dynamic>? oldTarget;
}

class DebuggerEvent {
  ReactiveEffect effect;
  dynamic target;
  TrackOpTypes? type;
  dynamic key;
  dynamic newValue;
  dynamic oldValue;
  Map<dynamic, dynamic>? oldTarget;
  DebuggerEvent(this.effect, this.target, this.type, this.key, this.newValue, this.oldValue, this.oldTarget);
}

const ITERATE_KEY =  Symbol('iterate');
const MAP_KEY_ITERATE_KEY =  Symbol('Map key iterate');

const maxMarkerBits = 30;

class Notifier {
  static var trackOpBit = 1;
  static Notifier? _instance;
  static Notifier get instance => _instance ??= Notifier();

  Map<dynamic, KeyToDepMap> targetMap = {};
  Map<dynamic, int> arrayExplicitKeyDepCount = {};
  bool shouldTrack = true;
  int effectTrackDepth = 0;
  List<TrackFrame> frameStack = [];
  List<TriggerStack> triggerStack = [];
  bool shouldTrigger = true;
  List<bool> trackStack = [];
  List<ReactiveEffect> effectsInSession = [];
  Map<ReactiveEffect, List<TriggerInfo>> effectsInSessionPayloads = {};
  bool inEffectSession = false;
  bool isDigesting = false;
  int sessionDepth = 0;

  void createEffectSession() {
    if (isDigesting) return;
    inEffectSession = true;
    sessionDepth++;
  }

  void scheduleEffect(ReactiveEffect effect, TriggerInfo info) {
    assert(inEffectSession, 'should be in effect session');
    effectsInSession.add(effect);
    effectsInSessionPayloads.putIfAbsent(effect, () => []).add(info);
  }

  void digestEffectSession() {
    if (isDigesting) return;
    sessionDepth--;
    if (sessionDepth > 0) return;
    isDigesting = true;

    while(effectsInSession.isNotEmpty) {
      var effect = effectsInSession.removeAt(0);
      var infos = effectsInSessionPayloads.remove(effect);
      effect.run(infos);
    }
    // for (var effect in effectsInSession) {
    //   var infos = effectsInSessionPayloads[effect]!;
    //   effect.run(infos);
    //   effectsInSession.remove(effect);
    //   effectsInSessionPayloads.remove(effect);
    // }
    assert(effectsInSession.isEmpty, 'effectsInSession should be empty');
    inEffectSession = false;
    isDigesting = false;
  }

  Dep? track(target, TrackOpTypes type, key) {
    if (ReactiveEffect.activeScopes.isEmpty || !shouldTrack) return null;
    var activeEffect = ReactiveEffect.activeScopes.last;

    assert(!(activeEffect is Computed && target == activeEffect), 'should not read self in computed');
    // var depsMap = targetMap[target];
    var depsMap = target.depsMap;

    // if (depsMap == null) {
    //   targetMap[target] = KeyToDepMap();
    //   depsMap = targetMap[target];
    // }
    var dep = depsMap![key];
    dep ??= depsMap[key] = createDep(null);
    var eventInfo = {'effect': activeEffect, 'target': target, 'type': type, 'key': key};
    trackEffects(dep, eventInfo);
    return dep;
  }

  void trackEffects(dep, [debuggerEventExtraInfo]) {
    if (ReactiveEffect.activeScopes.isEmpty) return;

    var activeEffect = ReactiveEffect.activeScopes.last;
    var shouldTrack = false;
    if (effectTrackDepth <= maxMarkerBits) {
      if (!newTracked(dep)) {
        dep.n |= Notifier.trackOpBit;
        shouldTrack = !wasTracked(dep);
      }
    } else {
      shouldTrack = !dep.has(activeEffect);
    }
    if (shouldTrack) {
      dep.add(activeEffect);
      activeEffect.deps.add(dep);
      if (frameStack.isNotEmpty) frameStack.last.deps.add(dep);
      if (activeEffect.onTrack != null) {
        activeEffect.onTrack!({'effect': activeEffect, ...debuggerEventExtraInfo});
      }
    }
  }

  void trigger<T, K, V>(Observable<T, K, V> source, TriggerOpTypes type, InputTriggerInfo inputInfo, [oldTarget]) {
    if (!shouldTrigger) return;
    TriggerInfo info = TriggerInfo(
      source: source,
      method: inputInfo.method,
      argv: inputInfo.argv,
      result: inputInfo.result,
      key: inputInfo.key,
      newValue: inputInfo.newValue,
      oldValue: inputInfo.oldValue,
    );
    // var depsMap = targetMap[source];
    var depsMap = source.depsMap;
    if (depsMap == null) return;
    List<Dep?> deps = [];
    if (type == TriggerOpTypes.CLEAR) {
      deps = depsMap.entries.map( (entry) => entry.value).toList();
    } else if (info.key == 'length' && source is RxList) {
      var newLength = info.newValue;
      depsMap.forEach((key, dep) {
        if ((key is String && key == 'length') || (key is int && key >= newLength)) {
          deps.add(dep);
        }
      });
    } else {
      if (info.key != null && depsMap[(info.key)] != null) {
        deps.add(depsMap[(info.key)]);
      }
      switch (type) {
        case TriggerOpTypes.ADD:
          if (source is! RxList) {
            if (depsMap[ITERATE_KEY] !=null) deps.add(depsMap[ITERATE_KEY]);

            if (source is RxMap && depsMap[MAP_KEY_ITERATE_KEY] !=null) {
              deps.add(depsMap[MAP_KEY_ITERATE_KEY]);
            }
          } else if (info.key is int) {
            if(depsMap['length']!=null) deps.add(depsMap['length']);
          }
          break;
        case TriggerOpTypes.DELETE:
          if (source is! RxList) {
            if (depsMap[ITERATE_KEY] !=null) deps.add(depsMap[ITERATE_KEY]!);
            if (source is RxMap && depsMap[MAP_KEY_ITERATE_KEY] !=null) {
              deps.add(depsMap[MAP_KEY_ITERATE_KEY]!);
            }
          }
          break;
        case TriggerOpTypes.SET:
          if (source is RxMap && depsMap[ITERATE_KEY] !=null) {
            deps.add(depsMap[ITERATE_KEY]!);
          }
          break;
        case TriggerOpTypes.METHOD:
          if (depsMap[TriggerOpTypes.METHOD]!=null) deps.add(depsMap[TriggerOpTypes.METHOD]);
          break;
        case TriggerOpTypes.EXPLICIT_KEY_CHANGE:
          if (depsMap[TriggerOpTypes.EXPLICIT_KEY_CHANGE] != null) {
            deps.add(depsMap[TriggerOpTypes.EXPLICIT_KEY_CHANGE]!);
          }
          break;
        case TriggerOpTypes.ATOM:
          // TODO: Handle this case.
        case TriggerOpTypes.CLEAR:
          // TODO: Handle this case.
      }
    }
    var eventInfo = {
      'target': source,
      'type': type,
      'key': info.key,
      'newValue': info.newValue,
      'oldValue': info.oldValue,
      'oldTarget': oldTarget
    };
    if (deps.length == 1) {
      if (deps[0] != null) {
        triggerEffects(deps[0]!, info, eventInfo);
      }
    } else {
      List<ReactiveEffect> effects = [];
      for (var dep in deps) {
        if (dep != null) {
          effects.addAll(dep.effects);
        }
      }
      triggerEffects(createDep(effects), info, eventInfo);
    }
  }

  void triggerEffects(Dep dep, info, [debuggerEventExtraInfo]) {
    for (var effect in dep.effects) {
      triggerEffect(effect, info, debuggerEventExtraInfo);
    }
  }

  void triggerEffect(effect, TriggerInfo info, [debuggerEventExtraInfo]) {
    if (effect.onTrigger != null) {
      effect.onTrigger({'effect': effect, ...debuggerEventExtraInfo});
    }
    if (inEffectSession) {
      scheduleEffect(effect, info);
    } else {
      effect.run([info]);
    }
  }

  void enableTracking() {
    trackStack.add(shouldTrack);
    shouldTrack = true;
  }

  void pauseTracking() {
    trackStack.add(shouldTrack);
    shouldTrack = false;
  }

  void resetTracking() {
    var last = trackStack.removeLast();
    shouldTrack = last;
  }
}


