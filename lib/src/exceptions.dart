enum InvalidOperation {
  pairVariableSmallerThanPrimaryVariable,
  quboEntryDoesNotExist,
}

enum DataFormatError {
  listNotSquare,
  lowerTriangleEntryNotZero,
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

  InvalidOperationException(this.operation);

  @override
  String get exceptionId => "InvalidOperationException";

  @override
  String get message {
    switch (operation) {
      case InvalidOperation.pairVariableSmallerThanPrimaryVariable:
        return "Pair variable index must be higher or equal to the index of the primary variable.";
      case InvalidOperation.quboEntryDoesNotExist:
        return "QUBO entry does not exist.";
      default:
        return "Attempted to execute an invalid operation.";
    }
  }
}

class DataFormattingException extends QuboEmbedderException {
  final DataFormatError dataFormatError;

  DataFormattingException(this.dataFormatError);

  @override
  String get exceptionId => "DataFormattingException";

  @override
  String get message {
    switch (dataFormatError) {
      case DataFormatError.listNotSquare:
        return "List for Hamiltonian must resemble a square matrix (number of columns = number of rows).";
      case DataFormatError.lowerTriangleEntryNotZero:
        return "Entries in the lower triangle of the list have to be zero.";
      default:
        return "Provided incorrectly formatted data.";
    }
  }
}
