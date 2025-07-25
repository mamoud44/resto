class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String deliveryType;
  final String? arrivalTime;
  final String paymentMethod;
  final int totalPrice;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.deliveryType,
    required this.arrivalTime,
    required this.paymentMethod,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      status: json['status'],
      deliveryType: json['delivery_type'],
      arrivalTime: json['arrival_time'],
      paymentMethod: json['payment_method'],
      totalPrice: json['total_price'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
