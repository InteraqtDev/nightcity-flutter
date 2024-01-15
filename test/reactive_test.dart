import 'package:test/test.dart';
import 'package:nightcity_flutter/data0/atom.dart';
import 'package:nightcity_flutter/data0/reactive.dart';
import 'package:nightcity_flutter/data0/RxMap.dart';
import 'package:nightcity_flutter/data0/RxList.dart';

void main() {
  group('atom basic', () {
    test('initialize & update atom', () {
      final num = atom(1);
      num(2);
      expect(num(), equals(2));
      num(3);
      expect(num(), equals(3));
    });
  });

  group('reactive basic', () {
    test('initialize & update leaf', () {
      final obj = reactive({'leaf': 1}) as dynamic;
      expect(obj.leaf(), equals(1));
      expect(obj.leaf.runtimeType.toString(), equals('LeafAtom<dynamic>'));
      final leaf = obj.leaf;
      leaf(3);
      expect(obj.leaf(), equals(3));
    });
  });

  group('number/string atom with primitive operations', () {
    test('with number operator', () {
      final num = atom(1);
      expect(num + 2, equals(3));
      num(5);
      expect(num - 3, equals(2));
    });


    test('string atom', () {
      final num = atom('a');
      expect(num(), equals('a'));
      expect(num + 'b', equals('ab'));
    });
  });

  group('array reactive', () {
    test('array reactive basic', () {
      final arr = reactive<int, dynamic>([1, 2, 3]) as RxList<int>;
      arr.removeAt(1);
    });
  });

}
