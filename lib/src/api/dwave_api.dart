import 'dart:convert';
import 'package:http/http.dart' as http;

import './constants.dart';
import '../exceptions.dart';

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

  static void _validate(http.Response response) {
    if (!response.statusCode.isOkStatus()) {
      if (response.statusCode.isUnauthorized()) {
        throw DwaveApiException(DwaveApiError.incorrectApiToken);
      }
      final decodedBody = json.decode(response.body);
      throw NetworkException(response.statusCode, decodedBody["error_msg"]);
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