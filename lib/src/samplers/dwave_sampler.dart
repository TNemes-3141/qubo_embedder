import 'dart:math' show pow;

import '../solver.dart';
import '../math.dart';
import '../solution_record.dart';
import '../exceptions.dart';

class DwaveSampler extends Solver {
  final String token;
  final String solver;

  DwaveSampler(this.token, this.solver) : super(SolverType.dwaveSampler);

  @override
  SolutionRecord sample(Hamiltonian hamiltonian, {int? recordLength}) {
    final combinations = pow(2, hamiltonian.dimension).round();
    recordLength ??= combinations;

    if (recordLength > combinations) {
      throw InvalidOperationException(
        InvalidOperation.recordLengthLargerThanPossibleCombinations,
      );
    }

    return SolutionRecord(recordLength);
  }
}
