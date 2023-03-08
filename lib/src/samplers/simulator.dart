import 'dart:collection' show SplayTreeMap;
import 'dart:math' show pow;

import '../solver.dart';
import '../math.dart';
import '../solution_record.dart';
import '../exceptions.dart';

class Simulator extends Solver {
  Simulator() : super(SolverType.simulator);

  @override
  SolutionRecord sample(Hamiltonian hamiltonian, {int? recordLength}) {
    final combinations = pow(2, hamiltonian.dimension).round();
    recordLength ??= combinations;

    if (recordLength > combinations) {
      throw InvalidOperationException(
        InvalidOperation.recordLengthLargerThanPossibleCombinations,
      );
    }

    var orderedSolutions = SplayTreeMap<double, SolutionVector>();
    var solutionVector =
        SolutionVector.filled(hamiltonian.dimension, fillValue: 0);
    var terminate = false;

    while (!terminate) {
      var energy = Calculator.energy(hamiltonian, solutionVector);
      orderedSolutions[energy] = solutionVector.deepCopy();

      terminate = solutionVector.increment();
    }

    var record = SolutionRecord(recordLength);

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
