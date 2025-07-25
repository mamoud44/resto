import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuItem {
  final String name;
  final String description;
  final double price;
  final String image;
  final String restaurant;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.restaurant,
  });
}

class DailyMenuPage extends StatefulWidget {
  const DailyMenuPage({super.key});

  @override
  State<DailyMenuPage> createState() => _DailyMenuPageState();
}

class _DailyMenuPageState extends State<DailyMenuPage>
    with SingleTickerProviderStateMixin {
  final MenuItem item = MenuItem(
    name: "Burger Poulet Frite",
    description:
        "Burger de poulet frit avec frites, garni de laitue, tomates, oignons, sauce spéciale maison, accompagné d'une sauce barbecue fumée et d'une pointe de moutarde douce. Ce plat vous offre un équilibre parfait entre croquant et saveurs riches.",
    price: 3500,
    image: "assets/images/real/hamburger3.jpg",
    restaurant: "Chez Sept Tables",
  );

  final Map<String, double> addOnOptions = {
    "Fromage supplémentaire": 500,
    "Oeuf": 300,
    "Sauce piquante": 0,
    "Champignons": 400,
    "Jambon": 600,
  };

  final List<String> withoutOptions = [
    "Oignons",
    "Tomates",
    "Salade",
    "Mayonnaise",
    "Cornichons",
    "Poivrons",
  ];

  List<String> selectedAddOns = [];
  List<String> selectedWithout = [];
  int quantity = 1;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get totalPrice {
    double addOnsTotal = selectedAddOns.fold(
      0.0,
      (sum, e) => sum + (addOnOptions[e] ?? 0),
    );
    return (item.price + addOnsTotal) * quantity;
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Suppléments",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...addOnOptions.entries.map(
                (entry) => CheckboxListTile(
                  title: Text(
                    "${entry.key} ${entry.value > 0 ? "+ ${entry.value.toInt()} FCFA" : "(gratuit)"}",
                  ),
                  value: selectedAddOns.contains(entry.key),
                  onChanged: (val) {
                    setState(() {
                      val == true
                          ? selectedAddOns.add(entry.key)
                          : selectedAddOns.remove(entry.key);
                    });
                    Navigator.pop(context);
                    _showCustomizationModal();
                  },
                ),
              ),
              const Divider(),
              const Text(
                "Sans (à retirer)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...withoutOptions.map(
                (opt) => CheckboxListTile(
                  title: Text(opt),
                  value: selectedWithout.contains(opt),
                  onChanged: (val) {
                    setState(() {
                      val == true
                          ? selectedWithout.add(opt)
                          : selectedWithout.remove(opt);
                    });
                    Navigator.pop(context);
                    _showCustomizationModal();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: item.image,
                child: Image.asset(
                  item.image,
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                    item.restaurant,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
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
                      "Supplements",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
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

                        // Ne pas quitter la page ici
                        // Navigator.pop(context); ← supprimé
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        "Ajouter pour ${currencyFormat.format(totalPrice)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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
