import 'package:flutter_test/flutter_test.dart';

import 'package:qubo_embedder/qubo_embedder.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('test', () {
    final hamiltonian = [
      [0.0, 1.0, 2.0],
      [0.0, 1.0, 2.0],
      [0.0, 0.0, 2.0],
    ];

    expect(Utils.hamiltonianToMap(hamiltonian), 0);
  });
}
