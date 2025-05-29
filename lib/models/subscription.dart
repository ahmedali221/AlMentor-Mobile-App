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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      displayNameAr: json['displayName']?['ar']?.toString() ??
          json['displayNameAr']?.toString() ??
          '',
      descriptionAr: json['description']?['ar']?.toString() ??
          json['descriptionAr']?.toString() ??
          '',
      amount: (json['price']?['amount'] ?? json['amount'] ?? 0).toDouble(),
      originalAmount: json['price']?['originalAmount'] != null
          ? (json['price']?['originalAmount'] as num).toDouble()
          : json['originalAmount'] != null
              ? (json['originalAmount'] as num).toDouble()
              : null,
      currency: json['price']?['currency']?.toString() ??
          json['currency']?.toString() ??
          '',
      durationValue: json['duration']?['value'] ?? json['durationValue'] ?? 1,
      durationUnit: json['duration']?['unit']?.toString() ??
          json['durationUnit']?.toString() ??
          '',
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
      titleAr:
          json['title']?['ar']?.toString() ?? json['titleAr']?.toString() ?? '',
      descriptionAr: json['description']?['ar']?.toString() ??
          json['descriptionAr']?.toString() ??
          '',
      icon: json['icon']?.toString(),
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