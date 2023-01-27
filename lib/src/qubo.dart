import 'package:tuple/tuple.dart';

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
