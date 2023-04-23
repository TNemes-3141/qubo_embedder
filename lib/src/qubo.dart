import 'package:tuple/tuple.dart';

import './math.dart';
import './exceptions.dart';

class Qubo {
  final int size;
  final Map<Tuple2<int, int>, double> _qubo = {};

  Qubo({required this.size});

  factory Qubo.fromHamiltonian(Hamiltonian hamiltonian) {
    final matrix = hamiltonian.matrix;
    final qubo = Qubo(size: hamiltonian.dimension);

    for (var i = 0; i < matrix.length; i++) {
      for (var j = i; j < matrix[i].length; j++) {
        final element = matrix[i][j];
        if (element != 0) {
          qubo.addEntry(i, j, value: element);
        }
      }
    }

    return qubo;
  }

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
