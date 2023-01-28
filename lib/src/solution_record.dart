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

  @override
  String toString() {
    String content = "   energy\tsample\toccurrences\n";
    var counter = 1;

    for (var entry in _entries) {
      content += "($counter) $entry\n";
      counter++;
    }

    return content;
  }
}

class SolutionRecordEntry {
  final double energy;
  final SolutionVector solutionVector;
  final int numOccurrences;

  SolutionRecordEntry(this.energy, this.solutionVector, this.numOccurrences);

  @override
  String toString() {
    return "$energy\t$solutionVector\tx$numOccurrences";
  }
}
