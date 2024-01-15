import './dep.dart';
import './notify.dart';

typedef EffectCollectFrame = List<ReactiveEffect>;

class ReactiveEffect {
  static List<ReactiveEffect> activeScopes = [];
  static void destroy(ReactiveEffect effect, [bool? fromParent]) {
    if (!effect.active) return;
    effect.cleanup();
    effect.active = false;
    if (effect.parent != null && !fromParent!) {
      final last = effect.parent!.children.removeLast();
      if (last != effect) {
        effect.parent!.children[effect.index] = last;
        last.index = effect.index;
      }
    }
    effect.parent = null;
    for (var child in effect.children) {
      ReactiveEffect.destroy(child, true);
    }
    effect.children = [];
    effect.onDestroy?.call(effect);
  }

  static List<EffectCollectFrame> effectCollectFrames = [];

  static Function collectEffect() {
    final frame = <ReactiveEffect>[];
    ReactiveEffect.effectCollectFrames.add(frame);
    return () {
      assert(ReactiveEffect.effectCollectFrames.last == frame, 'collect effect frame error');
      return ReactiveEffect.effectCollectFrames.removeLast();
    };
  }

  List<Dep> deps = [];
  late bool active;
  ReactiveEffect? parent;
  List<ReactiveEffect> children = [];
  int index = 0;

  ReactiveEffect(this.active) {
    if (!active) return;
    if (ReactiveEffect.activeScopes.isNotEmpty) {
      parent = ReactiveEffect.activeScopes.last;
      parent!.children.add(this);
      index = parent!.children.length - 1;
    }
    if(ReactiveEffect.effectCollectFrames.isNotEmpty) {
      final collectFrame = ReactiveEffect.effectCollectFrames.last;
      collectFrame.add(this);
    }
  }

  void Function(ReactiveEffect t)? onDestroy;
  Function? onTrack;
  Function? onTrigger;

  void effectFn() {}

  dynamic run(List<TriggerInfo>? infos) {
    if (!active) {
      return effectFn();
    }
    if (ReactiveEffect.activeScopes.contains(this)) {
      throw 'recursive effect call';
    }
    try {
      Notifier.trackOpBit = 1 << ++Notifier.instance.effectTrackDepth;
      ReactiveEffect.activeScopes.add(this);
      Notifier.instance.enableTracking();
      if (Notifier.instance.effectTrackDepth <= maxMarkerBits) {
        initDepMarkers(this);
      } else {
        cleanup();
      }
      for (var child in children) {
        ReactiveEffect.destroy(child, true);
      }
      children = [];
      return effectFn();
    } finally {
      if (Notifier.instance.effectTrackDepth <= maxMarkerBits) {
        finalizeDepMarkers(this);
      }
      Notifier.instance.resetTracking();
      ReactiveEffect.activeScopes.removeLast();
      Notifier.trackOpBit = 1 << --Notifier.instance.effectTrackDepth;
    }
  }

  void cleanup() {
    final deps = this.deps;
    if (deps.isNotEmpty) {
      for (var i = 0; i < deps.length; i++) {
        deps[i].delete(this);
      }
      deps.clear();
    }
  }
}
