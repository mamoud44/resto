import 'package:flutter/material.dart';

class BonusPage extends StatelessWidget {
  const BonusPage({super.key});

  final int currentOrders = 8; // 🔁 À connecter dynamiquement
  final int rewardThreshold = 10;
  final int maxFreeOrderAmount = 15000;

  @override
  Widget build(BuildContext context) {
    final int remainingOrders = rewardThreshold - currentOrders;
    final bool isEligible = currentOrders >= rewardThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bonus Commande"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "🎁 Fidélité & Bonus",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Obtenez une commande gratuite après $rewardThreshold commandes",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              "(max ${maxFreeOrderAmount.toString()} FCFA)",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black45),
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: currentOrders / rewardThreshold,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$currentOrders / $rewardThreshold commandes effectuées",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🎉 Si bonus débloqué
                  if (isEligible)
                    Column(
                      children: [
                        const Icon(
                          Icons.celebration,
                          color: Colors.green,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Bravo 🎉 ! Vous avez débloqué un bonus !",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Utilisable jusqu'à $maxFreeOrderAmount FCFA",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Naviguer vers commande gratuite
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text("Utiliser mon bonus"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.lock_clock,
                          color: Colors.orange,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Encore $remainingOrders commande${remainingOrders > 1 ? 's' : ''} pour débloquer votre bonus !",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
