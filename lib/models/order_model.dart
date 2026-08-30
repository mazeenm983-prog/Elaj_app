class OrderModel {
  final String id;
  final String userId;
  final String? captainId;
  final String itemsText;
  final String? prescriptionImage;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.captainId,
    required this.itemsText,
    this.prescriptionImage,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      captainId: json['captain_id'],
      itemsText: json['items_text'],
      prescriptionImage: json['prescription_image'],
      deliveryAddress: json['delivery_address'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'captain_id': captainId,
      'items_text': itemsText,
      'prescription_image': prescriptionImage,
      'delivery_address': deliveryAddress,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
