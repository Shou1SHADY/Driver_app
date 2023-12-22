class HistoryItem {
  String destination;
  double price;
  String source;
  String time;
  String tripState;
  String userId;

  HistoryItem({
    required this.destination,
    required this.price,
    required this.source,
    required this.time,
    required this.tripState,
    required this.userId,
  });

  // Factory method to create a HistoryItem from a Map
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      destination: map['destination'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      source: map['source'] ?? '',
      time: map['time'] ?? '',
      tripState: map['tripState'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}
