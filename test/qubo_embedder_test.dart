import 'package:flutter_test/flutter_test.dart';
import 'package:qubo_embedder/qubo_embedder.dart';

import 'package:ml_linalg/linalg.dart';

void main() {
  test('test', () {
    final qubo = Qubo(size: 4);
    qubo.addEntry(0, 0, value: 1.0);
    qubo.addEntry(1, 1, value: 2.0);
    qubo.addEntry(2, 2, value: 3.0);
    qubo.addEntry(3, 3, value: 4.0);
    print(qubo);

    final hamiltonian = Hamiltonian.fromQubo(qubo);
    print(hamiltonian.matrix);
  });
}
