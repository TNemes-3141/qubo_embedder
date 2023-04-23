import 'dart:collection' show SplayTreeMap;
import 'dart:math' show pow;

import '../solver.dart';
import '../math.dart';
import '../qubo.dart';
import '../solution_record.dart';
import '../exceptions.dart';

class Simulator extends Solver {
  Simulator() : super(SolverType.simulator);

  @override
  Future<SolutionRecord> sampleQubo(Qubo qubo, {int? recordLength}) async {
    final combinations = pow(2, qubo.size).round();
    recordLength ??= combinations;

    if (recordLength > combinations) {
      throw InvalidOperationException(
        InvalidOperation.recordLengthLargerThanPossibleCombinations,
      );
    }

    final hamiltonian = Hamiltonian.fromQubo(qubo);

    var orderedSolutions = SplayTreeMap<double, SolutionVector>();
    var solutionVector =
        SolutionVector.filled(hamiltonian.dimension, fillValue: 0);
    var terminate = false;

    while (!terminate) {
      var energy = Calculator.energy(hamiltonian, solutionVector);
      orderedSolutions[energy] = solutionVector.deepCopy();

      terminate = solutionVector.increment();
    }

    final record = SolutionRecord(recordLength);

    for (var entry in orderedSolutions.entries) {
      var full = record.addEntry(
        energy: entry.key,
        solutionVector: entry.value,
        numOccurrences: 1,
      );

      if (full) break;
    }

    return record;
  }
}
