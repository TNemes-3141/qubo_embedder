import 'package:flutter_test/flutter_test.dart';
import 'package:qubo_embedder/qubo_embedder.dart';

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

  test('vector test', () {
    final solutionVector = SolutionVector.fromList([0, 1, 1, 0]);

    print(solutionVector.vector);
  });

  test('energy test', () {
    final hamiltonian = Hamiltonian.fromList([
      [-8.0, 8.0, 8.0, 8.0, 0.5, 0.5, 8.0, 0.5, 0.5],
      [0.0, -8.0, 8.0, 0.5, 8.0, 0.5, 0.5, 8.0, 0.5],
      [0.0, 0.0, -8.0, 0.5, 0.5, 8.0, 0.5, 0.5, 8.0],
      [0.0, 0.0, 0.0, -8.0, 8.0, 8.0, 8.0, 0.5, 0.5],
      [0.0, 0.0, 0.0, 0.0, -8.0, 8.0, 0.5, 8.0, 0.5],
      [0.0, 0.0, 0.0, 0.0, 0.0, -8.0, 0.5, 0.5, 8.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -8.0, 8.0, 8.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -8.0, 8.0],
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -8.0]
    ]);

    var results = Solver.simulator()
        .sampleQubo(Qubo.fromHamiltonian(hamiltonian), recordLength: 5);

    print(results);
  });

  test('dwave api tets', () async {
    const apiRegion = "eu-central-1";
    const apiToken = "";
    const params = ApiParams(apiRegion: apiRegion, apiToken: apiToken);

    await DwaveApi.getAvailableQpuSolvers(params);
  });
}
