import 'package:tuple/tuple.dart';
import 'package:ml_linalg/linalg.dart';

import './exceptions.dart';

class Qubo {
  final int size;
  final Map<Tuple2<int, int>, double> _qubo = {};

  Qubo({required this.size});

  void addEntry(
    int variableIndex,
    int variablePairIndex, {
    required double value,
  }) {
    if (variableIndex >= size) throw IndexOutOfRangeException("variableIndex");
    if (variablePairIndex >= size) {
      throw IndexOutOfRangeException("variableIndex");
    }
    if (variablePairIndex < variableIndex) {
      throw InvalidOperationException(
        InvalidOperation.pairVariableSmallerThanPrimaryVariable,
      );
    }

    final key = Tuple2(variableIndex, variablePairIndex);

    _qubo[key] = value;
  }

  double? getEntry(
    int variableIndex,
    int variablePairIndex,
  ) {
    final key = Tuple2(variableIndex, variablePairIndex);
    final element = _qubo[key];

    return element;
  }

  @override
  String toString() {
    String content = "[qubits: $size] {";
    for (var entry in _qubo.entries) {
      content += "(${entry.key.item1}, ${entry.key.item2}): ${entry.value}, ";
    }
    content += "}";

    return content;
  }
}

class Hamiltonian {
  final Matrix _matrix;

  Hamiltonian._(this._matrix);

  factory Hamiltonian.fromList(List<List<double>> list) {
    _checkListFormat(list);

    final matrix = Matrix.fromList(list, dtype: DType.float32);
    return Hamiltonian._(matrix);
  }

  factory Hamiltonian.fromQubo(Qubo qubo) {
    final matrix = _quboToMatrix(qubo);
    return Hamiltonian._(matrix);
  }

  List<List<double>> get matrix {
    var flatList = _matrix.asFlattenedList;
    return List<List<double>>.generate(
      _matrix.rowCount,
      (rowIndex) => List<double>.generate(
        _matrix.columnCount,
        (columnIndex) => flatList[rowIndex * _matrix.columnCount + columnIndex],
      ),
    );
  }

  static void _checkListFormat(List<List<double>> list) {
    final size = list.length;

    for (var rowIndex = 0; rowIndex < list.length; rowIndex++) {
      final row = list[rowIndex];
      if (row.length != size) {
        throw DataFormattingException(DataFormatError.listNotSquare);
      }
      for (var i = 0; i < rowIndex; i++) {
        if (row[i] != 0) {
          throw DataFormattingException(
            DataFormatError.lowerTriangleEntryNotZero,
          );
        }
      }
    }
  }

  static Matrix _quboToMatrix(Qubo qubo) {
    List<List<double>> rows = [];

    for (var i = 0; i < qubo.size; i++) {
      var row = List.filled(qubo.size, 0.0);
      for (var j = i; j < qubo.size; j++) {
        var entry = qubo.getEntry(i, j);
        if (entry != null) {
          row[j] = entry;
        }
      }
      rows.add(row);
    }

    return Matrix.fromList(rows, dtype: DType.float32);
  }
}
