import 'dart:math' show pow;

import '../solver.dart';
import '../qubo.dart';
import '../solution_record.dart';
import '../exceptions.dart';
import '../api/dwave_api.dart';
import '../api/embedder.dart';

class DwaveSampler extends Solver {
  final String region;
  final String token;
  final String solver;

  late final ApiParams _params;

  DwaveSampler(this.region, this.token, this.solver)
      : super(SolverType.dwaveSampler) {
    _params = ApiParams(apiRegion: region, apiToken: token);
  }

  @override
  Future<SolutionRecord> sampleQubo(Qubo qubo, {int? recordLength}) async {
    final combinations = pow(2, qubo.size).round();
    recordLength ??= combinations;

    if (recordLength > combinations) {
      throw InvalidOperationException(
        InvalidOperation.recordLengthLargerThanPossibleCombinations,
      );
    }
    if (qubo.size > 4) {
      throw InvalidOperationException(
        InvalidOperation.dwaveSamplingLargerThanFourNotSupported,
      );
    }

    if (!await DwaveApi.isSolverAvailable(_params, solver)) {
      throw DwaveApiException(DwaveApiError.solverNotAvailable);
    }

    final graphInfo = await DwaveApi.getSolverGraph(_params, solver);
    final embedding =
        Embedder.embedQubo(qubo, graphInfo, EmbeddingAlgorithm.pseudo);

    if (embedding.isEmpty) {
      throw ProcessFailedException(ProcessFailed.noEmbeddingFound);
    }

    final submissionId = await DwaveApi.postEmbeddingToSolver(
        _params, solver, graphInfo, embedding);

    final record = SolutionRecord(recordLength);

    return record;
  }
}
