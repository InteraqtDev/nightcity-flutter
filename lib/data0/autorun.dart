
import 'reactiveEffect.dart';

class Autorun extends ReactiveEffect {
  Function fn;
  Autorun(this.fn)
      : super(true) ;

  @override
  void effectFn() {
    fn();
  }
}

autorun(Function fn) {
  final effect =  Autorun(fn);
  effect.run(null);
  return (stop: () => { ReactiveEffect.destroy(effect)} );
}
