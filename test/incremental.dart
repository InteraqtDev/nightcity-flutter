import 'package:nightcity_flutter/data0/RxMap.dart';
import 'package:nightcity_flutter/data0/atom.dart';
import 'package:nightcity_flutter/data0/autorun.dart';
import 'package:nightcity_flutter/data0/reactive.dart';
import 'package:test/test.dart';


void main() {
  group('computed basic', () {
    test('atom & computed', () {
      final source = reactive([1,2,3]);
      var mapFnRuns = 0;
      final mappedArr = source.map<int>((item, _) {
          mapFnRuns++;
          return item + 3;
      });
      expect(mappedArr.data, equals([4,5,6]));
      expect(mapFnRuns, equals(3));

      source.splice(1, 0, [5]);
      expect(mappedArr.data, equals([4,8,5,6]));
      expect(mapFnRuns, equals(4));

      source.push([9, 10]);
      expect(mappedArr.data, equals([4,8,5,6,12, 13]));
      expect(mapFnRuns,  equals(6));

      source.pop();
      expect(mappedArr.data, equals([4,8,5,6,12]));
      expect(mapFnRuns, equals(6));

      source.shift();
      expect(mappedArr.data, equals([8,5,6,12]));
      expect(mapFnRuns, equals(6));

      source.unshift([6, 8]);
      expect(mappedArr.data, equals([9, 11, 8,5,6,12]));
      expect(mapFnRuns, equals(8));

      source.splice(1, source.length -1);
      expect(mappedArr.data, equals([9]));
      expect(mapFnRuns, equals(8));

      source[0] = 2;
      expect(mappedArr.data, equals([5]));
      expect(mapFnRuns, equals(9));
    });

    test('Array map with key change', ()  {
      final source = reactive([{'id': 1}, {'id': 2}, {'id': 3}]);
      var mapFnRuns = 0;
      final mappedArr = source.map((item, _) {
          mapFnRuns++;
          return { 'id': item.id + 3 };
      });
      // explicit key change
      source[0] = {'id': 5};
      expect(mappedArr[0].id(), equals(8));

      // change two item
      expect(mappedArr[1].id(), equals(5));
      expect(mappedArr[2].id(), equals(6));

      var temp = source[1];
      source[1] = source[2];
      source[2] = temp;
      expect(mappedArr[1].id(), equals(6));
      expect(mappedArr[2].id(), equals(5));
    });

    test('inc map with atom leaf', () {
      final source = reactive([{'id': 1}, {'id': 2}, {'id': 3}]);
      var mapFnRuns = 0;
      final mappedArr = source.map((item, _) {
          mapFnRuns++;
          return item.id;
      });

      expect(mappedArr.data[0](), equals(1));
      expect(mappedArr.data[1](), equals(2));
      expect(mappedArr.data[2](), equals(3));
      expect(mapFnRuns, equals(3));
      source[0].id = 5;
      expect(mappedArr.data[0](), equals(5));
      expect(mappedArr.data[1](), equals(2));
      expect(mappedArr.data[2](), equals(3));
      expect(mapFnRuns, equals(3));

      final source2 = reactive([{'id': 1}, {'id': 2}, {'id': 3}]);
      var mapFnRuns2 = 0;
      final mappedArr2 = source2.map((item, _) {
        mapFnRuns2++;
        return item.id;
      });
      expect(mappedArr2.data[0](), equals(1));
      expect(mappedArr2.data[1](), equals(2));
      expect(mappedArr2.data[2](), equals(3));
      expect(mapFnRuns2, equals(3));

      source2[0] = {'id': 6};
      expect(mappedArr2.data[0](), equals(6));
      expect(mappedArr2.data[1](), equals(2));
      expect(mappedArr2.data[2](), equals(3));
      expect(mapFnRuns2, equals(4));

    });

  });
}