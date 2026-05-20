import 'bms_parser.dart';

class BmsMockDataSource {
  BmsMockDataSource({BmsParser? parser}) : parser = parser ?? MockBmsParser();

  final BmsParser parser;

  List<int> nextFrame() => const [0x49, 0x4E, 0x4E, 0x50, 0x4F];
}
