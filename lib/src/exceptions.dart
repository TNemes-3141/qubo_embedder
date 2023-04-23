enum InvalidOperation {
  pairVariableSmallerThanPrimaryVariable,
  providedValueNotBinary,
  recordLengthLargerThanPossibleCombinations,
  recordIsFull,
  dwaveSamplingLargerThanFourNotSupported,
}

enum DataFormatting {
  listNotSquare,
  lowerTriangleEntryNotZero,
  entryNotBinary,
}

enum DwaveApiError {
  incorrectApiToken,
  solverNotAvailable,
}

abstract class QuboEmbedderException implements Exception {
  String get exceptionId;
  String get message;

  @override
  String toString() {
    return "$exceptionId: $message";
  }
}

class IndexOutOfRangeException extends QuboEmbedderException {
  final String paramName;

  IndexOutOfRangeException(this.paramName);

  @override
  String get exceptionId => "IndexOutOfRangeException";

  @override
  String get message => "Parameter $paramName was out of range.";
}

class InvalidOperationException extends QuboEmbedderException {
  final InvalidOperation operation;
  final String? paramName;

  InvalidOperationException(this.operation, {this.paramName});

  @override
  String get exceptionId => "InvalidOperationException";

  @override
  String get message {
    switch (operation) {
      case InvalidOperation.pairVariableSmallerThanPrimaryVariable:
        return "Pair variable index must be higher or equal to the index of the primary variable.";
      case InvalidOperation.providedValueNotBinary:
        return "Value '${paramName ?? ""}' for this operation must be binary.";
      case InvalidOperation.recordLengthLargerThanPossibleCombinations:
        return "Requested record length cannot exceed the number of possible combinations.";
      case InvalidOperation.recordIsFull:
        return "Capacity of the record is exhausted.";
      case InvalidOperation.dwaveSamplingLargerThanFourNotSupported:
        return "Using the DWave sampler on problem sizes larger than 4 is currently not supported.";
      default:
        return "Attempted to execute an invalid operation.";
    }
  }
}

class DataFormattingException extends QuboEmbedderException {
  final DataFormatting dataFormatError;

  DataFormattingException(this.dataFormatError);

  @override
  String get exceptionId => "DataFormattingException";

  @override
  String get message {
    switch (dataFormatError) {
      case DataFormatting.listNotSquare:
        return "List for Hamiltonian must resemble a square matrix (number of columns = number of rows).";
      case DataFormatting.lowerTriangleEntryNotZero:
        return "Entries in the lower triangle of the list have to be zero.";
      case DataFormatting.entryNotBinary:
        return "Entries can be either 0 or 1 (binary).";
      default:
        return "Provided incorrectly formatted data.";
    }
  }
}

class DwaveApiException extends QuboEmbedderException {
  final DwaveApiError dwaveApiError;

  DwaveApiException(this.dwaveApiError);

  @override
  String get exceptionId => "DwaveApiException";

  @override
  String get message {
    switch (dwaveApiError) {
      case DwaveApiError.incorrectApiToken:
        return "Provided API key is incorrect, nonexistent or does not authorize for the usage of the DWave API.";
      case DwaveApiError.solverNotAvailable:
        return "Provided solver is currently offline or does not exist.";
      default:
        return "Dwave API failed.";
    }
  }
}

class NetworkException extends QuboEmbedderException {
  final int statusCode;
  final String? msg;

  NetworkException(this.statusCode, this.msg);

  @override
  String get exceptionId => "NetworkException";

  @override
  String get message =>
      "Request to the REST API returned status code ($statusCode). ${msg == null || msg!.isEmpty ? "No message." : "Message:\n$msg"}";
}

class RequiredArgumentNullException extends QuboEmbedderException {
  final String paramName;

  RequiredArgumentNullException(this.paramName);

  @override
  String get exceptionId => "RequiredArgumentNullException";

  @override
  String get message => "Required argument '$paramName' must not be null.";
}
