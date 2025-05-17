class Subscription {
  final String id;
  final String name;
  final String displayNameAr;
  final String descriptionAr;
  final double amount;
  final double? originalAmount;
  final String currency;
  final int durationValue;
  final String durationUnit;
  final List<Feature> features;

  Subscription({
    required this.id,
    required this.name,
    required this.displayNameAr,
    required this.descriptionAr,
    required this.amount,
    this.originalAmount,
    required this.currency,
    required this.durationValue,
    required this.durationUnit,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      displayNameAr: json['displayName']?['ar'] ?? json['displayNameAr'],
      descriptionAr: json['description']?['ar'] ?? json['descriptionAr'],
      amount: (json['price']?['amount'] ?? json['amount'] as num).toDouble(),
      originalAmount: json['price']?['originalAmount'] != null
          ? (json['price']?['originalAmount'] as num).toDouble()
          : json['originalAmount'] != null
              ? (json['originalAmount'] as num).toDouble()
              : null,
      currency: json['price']?['currency'] ?? json['currency'],
      durationValue: json['duration']?['value'] ?? json['durationValue'],
      durationUnit: json['duration']?['unit'] ?? json['durationUnit'],
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => Feature.fromJson(f))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayNameAr': displayNameAr,
      'descriptionAr': descriptionAr,
      'amount': amount,
      'originalAmount': originalAmount,
      'currency': currency,
      'durationValue': durationValue,
      'durationUnit': durationUnit,
      'features': features.map((f) => f.toJson()).toList(),
    };
  }
}

class Feature {
  final String titleAr;
  final String descriptionAr;
  final String? icon;

  Feature({
    required this.titleAr,
    required this.descriptionAr,
    this.icon,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      titleAr: json['title']?['ar'] ?? json['titleAr'],
      descriptionAr: json['description']?['ar'] ?? json['descriptionAr'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleAr': titleAr,
      'descriptionAr': descriptionAr,
      'icon': icon,
    };
  }
} 