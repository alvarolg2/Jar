class MovementDataProcessor {
  final Map<String, int> inData;
  final Map<String, int> outData;
  final List<String> sortedDates;
  final int maxCount;

  MovementDataProcessor({
    required this.inData,
    required this.outData,
    required this.sortedDates,
    required this.maxCount,
  });

  factory MovementDataProcessor.process(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return MovementDataProcessor(
        inData: {},
        outData: {},
        sortedDates: [],
        maxCount: 0,
      );
    }

    final Map<String, int> inData = {};
    final Map<String, int> outData = {};
    final Set<String> allDates = {};

    for (var item in data) {
      final date = item['date'] as String;
      final type = item['type'] as String;
      final count = item['count'] as int;

      allDates.add(date);
      if (type == 'in') {
        inData[date] = count;
      } else {
        outData[date] = count;
      }
    }

    final sortedDates = allDates.toList()..sort();

    int maxCount = 0;
    for (var count in inData.values) {
      if (count > maxCount) maxCount = count;
    }
    for (var count in outData.values) {
      if (count > maxCount) maxCount = count;
    }

    return MovementDataProcessor(
      inData: inData,
      outData: outData,
      sortedDates: sortedDates,
      maxCount: maxCount,
    );
  }

  static String formatDateLabel(String date) {
    return date.length >= 10
        ? '${date.substring(8, 10)}/${date.substring(5, 7)}'
        : date;
  }
}
