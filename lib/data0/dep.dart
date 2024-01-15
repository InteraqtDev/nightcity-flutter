import 'notify.dart';
import 'reactiveEffect.dart';

class Dep {
  late Set<ReactiveEffect> effects;
  Dep(List<ReactiveEffect>? effects) {
    this.effects = Set<ReactiveEffect>.from(effects ?? []);
  }
  add(ReactiveEffect effect) {
    effects.add(effect);
  }
  delete(ReactiveEffect effect) {
    effects.remove(effect);
  }
  has(ReactiveEffect effect) {
    return effects.contains(effect);
  }
  int w = 0;
  int n = 0;
  bool wasTracked() => (w & Notifier.trackOpBit) > 0;
  bool newTracked() => (n & Notifier.trackOpBit) > 0;
}

Dep createDep(List<ReactiveEffect>? effects) {
  Dep dep = Dep(effects);
  dep.w = 0;
  dep.n = 0;
  return dep;
}

bool wasTracked(Dep dep) => dep.wasTracked();
bool newTracked(Dep dep) => dep.newTracked();

void initDepMarkers(ReactiveEffect effect) {
  List<Dep> deps = effect.deps;
  if (deps.isNotEmpty) {
    for (int i = 0; i < deps.length; i++) {
      deps[i].w |= Notifier.trackOpBit;
    }
  }
}

void finalizeDepMarkers(ReactiveEffect effect) {
  List<Dep> deps = effect.deps;
  if (deps.isNotEmpty) {
    int ptr = 0;
    for (int i = 0; i < deps.length; i++) {
      Dep dep = deps[i];
      if (wasTracked(dep) && !newTracked(dep)) {
        dep.delete(effect);
      } else {
        deps[ptr++] = dep;
      }
      dep.w &= ~Notifier.trackOpBit;
      dep.n &= ~Notifier.trackOpBit;
    }
    deps.length = ptr;
  }
}


