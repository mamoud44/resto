import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:resto/models/order_summary_model.dart';
import 'package:resto/services/order_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderSummary>> _ordersFuture;
  Timer? _refreshTimer;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Set<String> _notifiedOrders = {};

  final List<String> _statusSteps = [
    'recu',
    'accepte',
    'preparation',
    'livraison',
    'livre',
  ];

  final Map<String, String> _statusLabels = {
    'recu': 'Commande reçue',
    'accepte': 'Commande acceptée',
    'preparation': 'En préparation',
    'livraison': 'En cours de livraison',
    'livre': 'Commande livrée',
  };

  final Map<String, IconData> _statusIcons = {
    'recu': Icons.mark_email_read_outlined,
    'accepte': Icons.check_circle_outline,
    'preparation': Icons.kitchen_outlined,
    'livraison': Icons.delivery_dining,
    'livre': Icons.verified_outlined,
  };

  final Map<String, String> _stepDurations = {
    'recu': '~1 min',
    'accepte': '~2 min',
    'preparation': '~10 min',
    'livraison': '~15 min',
    'livre': '',
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadOrders();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadOrders(),
    );
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderService.fetchOrderSummariesTyped().then((orders) {
        for (final order in orders) {
          if (order.status == 'livre' &&
              !_notifiedOrders.contains(order.orderNumber)) {
            _showDeliveredNotification(order.orderNumber);
            _notifiedOrders.add(order.orderNumber);
          }
        }
        return orders;
      });
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showDeliveredNotification(String orderNumber) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'order_channel',
          'Commandes',
          channelDescription: 'Notifications de suivi de commande',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.green,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      orderNumber.hashCode,
      'Commande livrée ✅',
      'Votre commande n°$orderNumber a été livrée avec succès.',
      notificationDetails,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "livre":
        return Colors.green;
      case "preparation":
      case "accepte":
        return Colors.orange;
      case "livraison":
        return Colors.blue;
      case "annule":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStepColor(String step, String currentStatus) {
    final currentIndex = _statusSteps.indexOf(currentStatus);
    final stepIndex = _statusSteps.indexOf(step);
    if (stepIndex < currentIndex) return Colors.green;
    if (stepIndex == currentIndex) return Colors.orange;
    return Colors.grey.shade300;
  }

  String _formatDate(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate).toLocal();
      final formatter = DateFormat("EEEE dd MMMM yyyy 'à' HH:mm", 'fr_FR');
      return formatter.format(dateTime);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Commandes"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<OrderSummary>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune commande trouvée 📭"));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🧾 En-tête commande
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _statusIcons[order.status] ?? Icons.info_outline,
                            color: _getStatusColor(order.status),
                            size: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Commande n°${order.orderNumber}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Date : ${_formatDate(order.date)}",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _statusLabels[order.status] ??
                                      "Statut inconnu",
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currencyFormat.format(order.total),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🧭 Timeline intégrée
                      Column(
                        children: _statusSteps.map((step) {
                          final isActive =
                              _statusSteps.indexOf(order.status) >=
                              _statusSteps.indexOf(step);
                          final isCurrent = step == order.status;
                          final color = _getStepColor(step, order.status);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          _statusIcons[step],
                                          color: color,
                                          size: 26,
                                        ),
                                        if (isCurrent)
                                          _BlinkingDot(color: color),
                                      ],
                                    ),
                                    if (step != _statusSteps.last)
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: color,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _statusLabels[step]!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isActive
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isActive
                                                ? Colors.black87
                                                : Colors.grey,
                                          ),
                                        ),
                                        if (_stepDurations[step]!.isNotEmpty)
                                          Text(
                                            _stepDurations[step]!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final Color color;
  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
