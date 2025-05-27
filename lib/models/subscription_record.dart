class SubscriptionRecord {
  final String id;
  final String userId;
  final String subscriptionId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionRecord({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionRecord(
      id: json['_id']?['\$oid'] ?? json['id'] ?? '',
      userId: json['userId']?['\$oid'] ?? json['userId'] ?? '',
      subscriptionId:
          json['subscriptionId']?['\$oid'] ?? json['subscriptionId'] ?? '',
      startDate:
          DateTime.parse(json['startDate']?['\$date'] ?? json['startDate']),
      endDate: DateTime.parse(json['endDate']?['\$date'] ?? json['endDate']),
      status: json['status'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt']?['\$date'] ?? json['createdAt']),
      updatedAt:
          DateTime.parse(json['updatedAt']?['\$date'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {'\$oid': id},
      'userId': {'\$oid': userId},
      'subscriptionId': {'\$oid': subscriptionId},
      'startDate': {'\$date': startDate.toIso8601String()},
      'endDate': {'\$date': endDate.toIso8601String()},
      'status': status,
      'createdAt': {'\$date': createdAt.toIso8601String()},
      'updatedAt': {'\$date': updatedAt.toIso8601String()},
    };
  }
}
