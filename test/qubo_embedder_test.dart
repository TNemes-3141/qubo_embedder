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
    const apiToken = "DEV-26e55bfa2c93e9c1b22c85a124c9cf10d7b47a5a";
    const params = ApiParams(apiRegion: apiRegion, apiToken: apiToken);

    final r = await DwaveApi.getSolverGraph(params, "Advantage_system5.3");

    print(r);
  });

  test('embedder test', () async {
    final hamiltonian = Hamiltonian.fromList([
      [-3.0, 2.0, 2.0, 2.0],
      [0.0, -3.0, 2.0, 2.0],
      [0.0, 0.0, -3.0, 2.0],
      [0.0, 0.0, 0.0, -3.0],
    ]);
    final qubo = Qubo.fromHamiltonian(hamiltonian);

    const apiRegion = "eu-central-1";
    const apiToken = "DEV-26e55bfa2c93e9c1b22c85a124c9cf10d7b47a5a";
    const params = ApiParams(apiRegion: apiRegion, apiToken: apiToken);

    final info = await DwaveApi.getSolverGraph(params, "Advantage_system5.3");

    final embedding = Embedder.embedQubo(qubo, info, EmbeddingAlgorithm.pseudo);

    final subId = await DwaveApi.postEmbeddingToSolver(
        params, "Advantage_system5.3", info, embedding);

    print("");
  });
}
