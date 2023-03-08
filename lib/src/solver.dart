import './samplers/dwave_sampler.dart';

import './math.dart';
import './solution_record.dart';

enum SolverType {
  dwaveSampler,
  simulator,
}

abstract class Solver {
  final SolverType type;

  Solver(this.type);

  static DwaveSampler dwaveSampler({
    required String token,
    required String solver,
  }) =>
      DwaveSampler(token, solver);

  SolutionRecord sample(Hamiltonian hamiltonian, {int? recordLength});
}
