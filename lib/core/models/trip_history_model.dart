class TripHistory {
  final int? id;
  final int userId;
  final int destinationId;
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

  factory TripHistory.fromMap(Map<String, dynamic> map) {
    return TripHistory(
      id: map['id'],
      userId: map['user_id'],
      destinationId: map['destination_id'],
      transport: map['transport'],
      totalBudget: map['total_budget'],
      date: map['date'],
    );
  }
}
