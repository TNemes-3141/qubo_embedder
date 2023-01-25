import 'package:tuple/tuple.dart';

class Utils {
  static Map<Tuple2<int, int>, double> hamiltonianToMap(
    List<List<double>> hamiltonian,
  ) {
    final size = hamiltonian.length;

    for (var rowIndex = 0; rowIndex < hamiltonian.length; rowIndex++) {
      final row = hamiltonian[rowIndex];
      assert(row.length == size);
      for (var i = 0; i < rowIndex; i++) {
        assert(row[i] == 0);
      }
    }

    final qubo = {for (var e in _generateDiagonal(size)) e: 0.0};

    for (var rowIndex = 0; rowIndex < size; rowIndex++) {
      for (var columnIndex = 0; columnIndex < size; columnIndex++) {
        if (hamiltonian[rowIndex][columnIndex] != 0) {
          qubo[Tuple2(rowIndex, columnIndex)] =
              hamiltonian[rowIndex][columnIndex];
        }
      }
    }

    return qubo;
  }

  static Iterable<Tuple2<int, int>> _generateDiagonal(int size) sync* {
    for (var i = 0; i < size; i++) {
      yield Tuple2(i, i);
    }
  }
}
