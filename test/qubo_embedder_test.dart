import 'package:flutter_test/flutter_test.dart';
import 'package:qubo_embedder/qubo_embedder.dart';

import 'package:ml_linalg/linalg.dart';

void main() {
  test('test', () {
    final qubo = Qubo(size: 5);
    qubo.addEntry(0, 0, value: 0.0);
    qubo.getEntry(1, 0);

    print(qubo);
  });
}
