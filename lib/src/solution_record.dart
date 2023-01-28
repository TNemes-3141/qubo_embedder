import './math.dart';
import './exceptions.dart';

class SolutionRecord {
  final int capacity;
  final List<SolutionRecordEntry> _entries = [];

  SolutionRecord(this.capacity);

  bool addEntry({
    required double energy,
    required SolutionVector solutionVector,
    required int numOccurrences,
  }) {
    if (_entries.length == capacity) {
      throw InvalidOperationException(InvalidOperation.recordIsFull);
    }

    _entries.add(SolutionRecordEntry(energy, solutionVector, numOccurrences));

    return _entries.length == capacity;
  }

  Iterable<SolutionRecordEntry> entries() sync* {
    for (var entry in _entries) {
      yield entry;
    }
  }
}

class SolutionRecordEntry {
  final double energy;
  final SolutionVector solutionVector;
  final int numOccurrences;

  SolutionRecordEntry(this.energy, this.solutionVector, this.numOccurrences);
}
