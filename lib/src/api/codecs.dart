import 'dart:typed_data';
import 'dart:convert';

import 'package:binary/binary.dart';

class Encoder {
  static String encodeDoubles(List<double> doubles) {
    final bytes = List<ByteData>.generate(
      doubles.length,
      (index) => ByteData(8)..setFloat64(0, doubles[index], Endian.little),
    );
    final combined =
        bytes.map((b) => b.buffer.asUint8List()).expand((l) => l).toList();
    return base64.encode(combined);
  }
}

class Decoder {
  static List<double> decodeDoubles(String base64String) {
    final decoded = base64.decode(base64String);
    final splitted = decoded.partition(8).map((p) => Uint8List.fromList(p));
    return splitted
        .map((l) => ByteData.view(l.buffer))
        .map((b) => b.getFloat64(0, Endian.little))
        .toList();
  }

  static List<int> decodeInts(String base64String) {
    final decoded = base64.decode(base64String);
    final splitted = decoded.partition(4).map((p) => Uint8List.fromList(p));
    return splitted
        .map((l) => ByteData.view(l.buffer))
        .map((b) => b.getInt32(0, Endian.little))
        .toList();
  }

  static List<List<int>> decodeBinary(String base64String, int numFields) {
    final partitionSize = (numFields / 8).ceil();
    final decoded = base64.decode(base64String);
    final groupedInts =
        decoded.map((uint) => Uint8(uint)).partition(partitionSize);
    final binaries = groupedInts.map(
      (intlist) => intlist
          .map(
            (uint) => List<int>.generate(
              uint.size,
              (index) => uint.getBit(index),
            ).reversed,
          )
          .expand(
            (byte) => byte,
          ).take(numFields).toList(),
    );

    return binaries.toList();
  }
}

extension Partitioning<T> on Iterable<T> {
  Iterable<List<T>> partition(int partitionSize) {
    final partitions = (length / partitionSize).ceil();
    return List.generate(
      partitions,
      (index) => skip(index * partitionSize).take(partitionSize).toList(),
    );
  }
}
