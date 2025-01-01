class GraphEntry {
  final int months;
  final GraphData data;

  GraphEntry({
    required this.months,
    required this.data,
  });
}

class GraphData {
  final double credited;
  final double uncredited;

  GraphData({
    required this.credited,
    required this.uncredited,
  });
}
