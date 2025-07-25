class OrderSummary {
  final int id;
  final String orderNumber;
  final String status;
  final String date;
  final int total;
  final String paymentMethod;
  final String deliveryType;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.date,
    required this.total,
    required this.paymentMethod,
    required this.deliveryType,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'],
      orderNumber: json['order_number'],
      status: json['status'],
      date: json['created_at'],
      total: json['total_price'],
      paymentMethod: json['payment_method'] ?? 'inconnu',
      deliveryType: json['delivery_type'] ?? 'inconnu',
    );
  }
}
