class TripHistory {
  final String? id;
  final String userId;
  final String destinationId;
  final String transport;
  final double totalBudget;
  final String date;

  TripHistory({
    this.id,
    required this.userId,
    required this.destinationId,
    required this.transport,
    required this.totalBudget,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'destination_id': destinationId,
      'transport': transport,
      'total_budget': totalBudget,
      'date': date,
    };
  }

  factory TripHistory.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return TripHistory(
      id: documentId ?? map['id'],
      userId: map['user_id'].toString(),
      destinationId: map['destination_id'].toString(),
      transport: map['transport'],
      totalBudget: map['total_budget'] is int ? (map['total_budget'] as int).toDouble() : map['total_budget'] as double,
      date: map['date'],
    );
  }
}
