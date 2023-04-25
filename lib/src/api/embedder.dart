import 'dart:collection';

import './dwave_api.dart';
import '../qubo.dart';
import '../exceptions.dart';

enum EmbeddingType {
  pseudo,
  minor,
}

class Embedder {
  static Embedding embedQubo(
      Qubo qubo, SolverGraphInfo graphInfo, EmbeddingType type) {
    switch (type) {
      case EmbeddingType.pseudo:
        return PseudoEmbedding.create(qubo, graphInfo);
      case EmbeddingType.minor:
      default:
        return MinorEmbedding.create(qubo, graphInfo);
    }
  }
}

abstract class Embedding {
  final EmbeddingType type;

  Embedding(this.type);

  Map<int, double> get qubitCoeffitients;
  Map<List<int>, double> get couplerCoeffitients;

  bool get isEmpty => qubitCoeffitients.isEmpty && couplerCoeffitients.isEmpty;
}

class PseudoEmbedding extends Embedding {
  final Map<int, double> lin;
  final Map<List<int>, double> quad;

  PseudoEmbedding._(this.lin, this.quad) : super(EmbeddingType.pseudo);

  factory PseudoEmbedding.create(Qubo qubo, SolverGraphInfo solverGraph) {
    final lin = <int, double>{};
    final quad = <List<int>, double>{};

    var allQubitsAreZero = true;
    for (var i = 0; i < qubo.size; i++) {
      if (qubo.getEntry(i, i) != null) {
        allQubitsAreZero = false;
        break;
      }
    }
    if (allQubitsAreZero) {
      return PseudoEmbedding._(lin, quad);
    }

    final Map<int, int> logicalToPhysical = {};
    final memory = SplayTreeMap<int, Set<int>>.fromIterable(
      solverGraph.qubits,
      value: (_) => <int>{},
    );
    for (var coupler in solverGraph.couplers) {
      //TODO: Add protection
      memory[coupler[0]]!.add(coupler[1]);
      memory[coupler[1]]!.add(coupler[0]);
    }

    for (var k = 0; k < solverGraph.couplers.length; k++) {
      for (var i = 1; i < qubo.size; i++) {
        if (lin.isEmpty) {
          final firstCoupler = solverGraph.couplers[k];
          lin[firstCoupler[0]] = qubo.getEntry(0, 0) ?? 0;
          logicalToPhysical[0] = firstCoupler[0];
          lin[firstCoupler[1]] = qubo.getEntry(1, 1) ?? 0;
          logicalToPhysical[1] = firstCoupler[1];
          quad[firstCoupler] = qubo.getEntry(0, 1) ?? 0;
        } else {
          final nextQubit = memory.entries
              .firstWhere(
                (entry) => entry.value.containsAll(lin.keys),
                orElse: () => const MapEntry(-1, {}),
              )
              .key;

          if (nextQubit == -1) {
            break;
          }

          lin[nextQubit] = qubo.getEntry(i, i) ?? 0;
          logicalToPhysical[i] = nextQubit;
          for (var j = 0; j < i; j++) {
            quad[[nextQubit, logicalToPhysical[j]!]] = qubo.getEntry(j, i) ?? 0;
          }
        }
      }

      if (lin.length == qubo.size) {
        break;
      }

      lin.clear();
      quad.clear();
    }

    final quadRepaired = {
      for (var entry in quad.entries) entry.key..sort(): entry.value
    };

    return PseudoEmbedding._(lin, quadRepaired);
  }

  @override
  Map<List<int>, double> get couplerCoeffitients => quad;
  @override
  Map<int, double> get qubitCoeffitients => lin;
}

class MinorEmbedding extends Embedding {
  final Map<int, double> lin;
  final Map<List<int>, double> quad;

  MinorEmbedding._(this.lin, this.quad) : super(EmbeddingType.minor);

  factory MinorEmbedding.create(Qubo qubo, SolverGraphInfo solverGraph) =>
      throw InvalidOperationException(
          InvalidOperation.minorEmbeddingNotSupported);

  @override
  Map<List<int>, double> get couplerCoeffitients => quad;
  @override
  Map<int, double> get qubitCoeffitients => lin;
}
