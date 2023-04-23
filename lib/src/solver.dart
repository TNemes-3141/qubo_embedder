import './samplers/dwave_sampler.dart';
import './samplers/simulator.dart';

import './qubo.dart';
import './solution_record.dart';

enum SolverType {
  dwaveSampler,
  simulator,
}

abstract class Solver {
  final SolverType type;

  Solver(this.type);

  static DwaveSampler dwaveSampler({
    required String region,
    required String token,
    required String solver,
  }) =>
      DwaveSampler(region, token, solver);

  static Simulator simulator() => Simulator();

  Future<SolutionRecord> sampleQubo(Qubo qubo, {int? recordLength});
}
