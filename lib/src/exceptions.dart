enum InvalidOperation {
  pairVariableSmallerThanPrimaryVariable,
  providedValueNotBinary,
  recordLengthLargerThanPossibleCombinations,
  recordIsFull,
}

enum DataFormatError {
  listNotSquare,
  lowerTriangleEntryNotZero,
  entryNotBinary,
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
      case DataFormatError.entryNotBinary:
        return "Entries can be either 0 or 1 (binary).";
      default:
        return "Provided incorrectly formatted data.";
    }
  }
}
