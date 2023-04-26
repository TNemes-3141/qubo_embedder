import 'dart:typed_data';
import 'dart:convert';

class Encoder {
  static String encodeCoeffitients(List<double> coeffitients) {
    final bytes = List<ByteData>.generate(
      coeffitients.length,
      (index) => ByteData(8)..setFloat64(0, coeffitients[index], Endian.little),
    );
    final linearCombined =
        bytes.map((b) => b.buffer.asUint8List()).expand((l) => l).toList();
    return base64.encode(linearCombined);
  }
}
