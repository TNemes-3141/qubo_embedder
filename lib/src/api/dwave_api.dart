import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

import './constants.dart';
import './embedder.dart';
import './codecs.dart';
import '../exceptions.dart';

int submittedProblems = 0;

class DwaveApi {
  static const apiDomain = "cloud.dwavesys.com";
  static const apiPath = "/sapi/v2";

  static Future<List<QpuSolverInfo>> getAvailableQpuSolvers(
      ApiParams params) async {
    final uri = Uri.https(
      "${params.apiRegion}.$apiDomain",
      "$apiPath/solvers/remote/",
      {
        "filter": "none,+id,+status,+properties.category,+properties.num_qubits"
      },
    );

    final response = await http.get(uri, headers: {
      "X-Auth-Token": params.apiToken,
      "Content-type": "application/json",
    });
    _validate(response);

    try {
      final jsonMap = json.decode(response.body);

      final result = <QpuSolverInfo>[];
      for (var map in jsonMap) {
        if (map["status"] == Constants.solversRemote.status.online &&
            map["properties"]["category"] ==
                Constants.solversRemote.properties.category.qpu) {
          result.add(
            QpuSolverInfo(
              name: map["id"],
              numQubits: map["properties"]["num_qubits"],
            ),
          );
        }
      }

      return result;
    } on FormatException {
      throw NetworkException(response.statusCode, response.body);
    }
  }

  static Future<bool> isSolverAvailable(
      ApiParams params, String apiSolver) async {
    final uri = Uri.https(
      "${params.apiRegion}.$apiDomain",
      "$apiPath/solvers/remote/$apiSolver",
      {"filter": "none,+id,+status"},
    );

    final response = await http.get(uri, headers: {
      "X-Auth-Token": params.apiToken,
      "Content-type": "application/json",
    });
    _validate(response);

    try {
      final jsonMap = json.decode(response.body);

      return jsonMap["status"] == Constants.solversRemote.status.online;
    } on FormatException {
      return false;
    }
  }

  static Future<SolverGraphInfo> getSolverGraph(
      ApiParams params, String apiSolver) async {
    final uri = Uri.https(
      "${params.apiRegion}.$apiDomain",
      "$apiPath/solvers/remote/$apiSolver",
      {"filter": "none,+properties.qubits,+properties.couplers"},
    );

    final response = await http.get(uri, headers: {
      "X-Auth-Token": params.apiToken,
      "Content-type": "application/json",
    });
    _validate(response);

    try {
      final jsonMap = json.decode(response.body);

      return SolverGraphInfo(
          qubits: (jsonMap["properties"]["qubits"] as List<dynamic>)
              .map((e) => e as int)
              .toList(),
          couplers: (jsonMap["properties"]["couplers"] as List<dynamic>)
              .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
              .toList());
    } on FormatException {
      throw NetworkException(response.statusCode, response.body);
    }
  }

  static Future<String> postEmbeddingToSolver(
      ApiParams params,
      String apiSolver,
      SolverGraphInfo solverGraph,
      Embedding embedding) async {
    final encodedEmbedding = _encodeEmbeddingProperties(solverGraph, embedding);
    submittedProblems++;

    final uri = Uri.https(
      "${params.apiRegion}.$apiDomain",
      "$apiPath/problems",
    );

    final Map<String, dynamic> jsonBody = {
      "solver": apiSolver,
      "label": "[QUBO_EMBEDDER] Automized submission $submittedProblems",
      "data": {
        "format": "qp",
        "lin": encodedEmbedding.item1,
        "quad": encodedEmbedding.item2,
      },
      "type": _embeddingTypeToString(embedding.type),
      "params": {"num_reads": 500},
    };

    final response = await http.post(
      uri,
      headers: {
        "X-Auth-Token": params.apiToken,
        "Content-type": "application/json",
      },
      body: json.encode(jsonBody),
    );
    _validate(response);

    try {
      final jsonMap = json.decode(response.body);

      return jsonMap["id"];
    } on FormatException {
      throw NetworkException(response.statusCode, response.body);
    }
  }

  static void _validate(http.Response response) {
    if (!response.statusCode.isOkStatus()) {
      if (response.statusCode.isUnauthorized()) {
        throw DwaveApiException(DwaveApiError.incorrectApiToken);
      }
      final decodedBody = json.decode(response.body);
      throw NetworkException(response.statusCode, decodedBody["error_msg"]);
    }
  }

  static Tuple2<String, String> _encodeEmbeddingProperties(
      SolverGraphInfo solverGraph, Embedding embedding) {
    final linearBiases =
        List<double>.filled(solverGraph.qubits.length, double.nan);
    for (var physicalQubit in embedding.qubitCoeffitients.keys) {
      final index = solverGraph.qubits.indexOf(physicalQubit);
      if (index == -1) {
        throw DwaveApiException(
            DwaveApiError.qubitInEmbeddingNotFoundInSolverGraph);
      }
      linearBiases[index] = embedding.qubitCoeffitients[physicalQubit]!;
    }
    final linearEncoded = Encoder.encodeCoeffitients(linearBiases);

    final quadraticBiases = List<double>.filled(
        embedding.couplerCoeffitients.keys.length, double.nan);
    int currentIndex = 0;
    for (var coupler in solverGraph.couplers) {
      var entries = embedding.couplerCoeffitients.entries.where(
          (entry) => entry.key[0] == coupler[0] && entry.key[1] == coupler[1]);
      if (entries.isNotEmpty) {
        quadraticBiases[currentIndex] = entries.first.value;
        currentIndex++;
      }
    }
    if (currentIndex != quadraticBiases.length) {
      throw DwaveApiException(
          DwaveApiError.couplerInEmbeddingNotFoundInSolverGraph);
    }
    final quadraticEncoded = Encoder.encodeCoeffitients(quadraticBiases);

    return Tuple2(linearEncoded, quadraticEncoded);
  }

  static String _embeddingTypeToString(EmbeddingType type) {
    switch (type) {
      case EmbeddingType.qubo:
        return Constants.problems.type.qubo;
      case EmbeddingType.ising:
        return Constants.problems.type.ising;
    }
  }
}

class ApiParams {
  final String apiRegion;
  final String apiToken;

  const ApiParams({required this.apiRegion, required this.apiToken});
}

class QpuSolverInfo {
  final String name;
  final int numQubits;

  const QpuSolverInfo({required this.name, required this.numQubits});
}

class SolverGraphInfo {
  final List<int> qubits;
  final List<List<int>> couplers;

  const SolverGraphInfo({required this.qubits, required this.couplers});
}

extension HttpStatusCodes on int {
  bool isOkStatus() {
    return this >= 200 && this < 300;
  }

  bool isUnauthorized() {
    return this == 401;
  }
}
