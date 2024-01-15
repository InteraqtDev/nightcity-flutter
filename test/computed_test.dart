import 'package:nightcity_flutter/data0/RxMap.dart';
import 'package:nightcity_flutter/data0/atom.dart';
import 'package:nightcity_flutter/data0/autorun.dart';
import 'package:nightcity_flutter/data0/reactive.dart';
import 'package:test/test.dart';


void main() {
  group('computed basic', () {
    test('atom & computed', () {
      final num1 = atom(1);
      final num2 = atom(2);
      final num3 = atom<int>(0, ((_1) => num1()!+num2()!));

      expect(num3(), equals(3));

      num1(3);
      expect(num3(), equals(5));

      num2(4);
      expect(num3(), equals(7));
    });

    test('reactive & computed', () {
      final x2 = reactive(List.filled(5, 0, growable: true));
      final c2 = x2.map<int>((item, _) => item + 1);

      x2.unshift([1]);
      expect(c2.length, equals(6));
      expect(c2.data, equals([2, 1, 1, 1, 1, 1]));
    });
    //
    test('reactive leaf & computed', () {
      final data = reactive({'l1': 1, 'l2': 2});
      final data2 = reactive({'l1': 3, 'l2': 4});

      final num = Atom<int>(null, (_) {
        var l1 = data.l1();
        var l2 = data.l2();
        var l3 = data2.l1();
        var l4 = data2.l2();
        return l1 + l2 + l3 + l4;
        // return (data.l1() + data.l2() + data2.l1() + data2.l2()) as int;
      });
      expect(num(), equals(10));

      data.l1 = 5;
      expect(num(), equals(14));
      data2.l2 = 5;
      expect(num(), equals(15));
    });
    //
    test('reactive leaf & object computed', () {
      final data = reactive({'l1': 1, 'l2': 2});
      final data2 = reactive({'l1': 3, 'l2': 4});

      final num = RxMap(null, (_) => {
        'result': data.l1() + data.l2() + data2.l1() + data2.l2()
      }) as dynamic;

      expect(num.result(), equals(10));

      data.l1(5);
      expect(num.result(), equals(14));

      data2.l2(5);
      expect(num.result(), equals(15));
    });
  });

  group('computed life cycle', () {
    test('should destroy inner computed', () {
      var innerRuns = 0;
      final a = Atom(0);
      final b = Atom(0);
      final outerComputed = autorun(() {
        a();
        autorun(() {
          b();
          innerRuns++;
        });
      });
      expect(innerRuns, equals(1));
      b(1);
      expect(innerRuns, equals(2));
      a(1);
      expect(innerRuns, equals(3));
      b(2);
      // TODO: Expect the computed to re-run and the inner computed to be automatically collected.
      expect(innerRuns, equals(4));

      outerComputed.stop();
      b(2);
      // After destroying the outer computed, the inner computed should also be collected.
      expect(innerRuns, equals(4));
    });
  });
}