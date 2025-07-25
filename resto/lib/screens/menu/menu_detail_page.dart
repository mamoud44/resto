import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:resto/models/menu_model.dart';
import 'package:resto/providers/cart_provider.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuItem item;

  const MenuDetailPage({super.key, required this.item});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int quantity = 1;
  final Set<int> selectedAddOns = {};
  final Set<int> selectedWithout = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    final cart = Provider.of<CartProvider>(context, listen: false);
    final existing = cart.items.firstWhereOrNull(
      (e) =>
          e.item.id == widget.item.id &&
          const DeepCollectionEquality().equals(
            e.supplementsAvec,
            selectedAddOns.toList(),
          ) &&
          const DeepCollectionEquality().equals(
            e.supplementsSans,
            selectedWithout.toList(),
          ),
    );

    if (existing != null) {
      quantity = existing.quantity;
      selectedAddOns.addAll(existing.supplementsAvec ?? []);
      selectedWithout.addAll(existing.supplementsSans ?? []);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get totalPrice {
    final base = widget.item.price;
    final addOnsTotal = widget.item.supplementsAvec
        .where((s) => selectedAddOns.contains(s.id))
        .fold(0, (sum, s) => sum + s.price);
    return (base + addOnsTotal) * quantity.toDouble();
  }

  void _showCustomizationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suppléments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...widget.item.supplementsAvec.map(
                      (s) => CheckboxListTile(
                        title: Text(
                          "${s.name} ${s.price > 0 ? "(+${s.price} FCFA)" : "(gratuit)"}",
                        ),
                        value: selectedAddOns.contains(s.id),
                        onChanged: (val) {
                          setModalState(() {
                            val == true
                                ? selectedAddOns.add(s.id)
                                : selectedAddOns.remove(s.id);
                          });
                          setState(() {}); // met à jour le total
                        },
                      ),
                    ),
                    const Divider(),
                    const Text(
                      "Sans (à retirer)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...widget.item.supplementsSans.map(
                      (s) => CheckboxListTile(
                        title: Text(s.name),
                        value: selectedWithout.contains(s.id),
                        onChanged: (val) {
                          setModalState(() {
                            val == true
                                ? selectedWithout.add(s.id)
                                : selectedWithout.remove(s.id);
                          });
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Valider"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: item.id,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: FadeTransition(
                  opacity: _animation,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormat.format(item.price),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantité",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(
                              () => quantity = quantity > 1 ? quantity - 1 : 1,
                            ),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showCustomizationModal,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Suppléments",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cart.addToCart(
                          item: item,
                          quantity: quantity,
                          supplementsAvec: selectedAddOns.toList(),
                          supplementsSans: selectedWithout.toList(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Ajouté pour ${currencyFormat.format(totalPrice)}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        "Ajouter pour ${currencyFormat.format(totalPrice)}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        elevation: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
