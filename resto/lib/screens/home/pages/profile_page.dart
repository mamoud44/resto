import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:resto/providers/auth_provider.dart';
import 'package:resto/routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showEditInfoModal(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email);
    final addressController = TextEditingController(text: user.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Modifier mes informations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                      ),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              try {
                                await Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).updateProfile({
                                  'full_name': nameController.text.trim(),
                                  'phone': phoneController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'address': addressController.text.trim(),
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Informations mises à jour !',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                String message =
                                    'Erreur lors de la mise à jour.';
                                if (e is DioException &&
                                    e.response?.data is Map) {
                                  message =
                                      e.response?.data.values.first
                                          .toString() ??
                                      message;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Enregistrer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
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

  void _showChangePasswordModal(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Changer le mot de passe",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      controller: currentController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe actuel',
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      controller: newController,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe',
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      controller: confirmController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer nouveau mot de passe',
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final current = currentController.text;
                              final newPass = newController.text;
                              final confirm = confirmController.text;

                              if (newPass != confirm) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Les mots de passe ne correspondent pas.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);
                              try {
                                await Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).changePassword(current, newPass);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mot de passe modifié !'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                String message =
                                    'Erreur lors du changement de mot de passe.';
                                if (e is DioException &&
                                    e.response?.data is Map) {
                                  message =
                                      e.response?.data.values.first
                                          .toString() ??
                                      message;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() => isLoading = false);
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Mettre à jour"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
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

  void _logout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    final hasAddress =
        user?.address != null && user!.address!.trim().isNotEmpty;
    final addressParts = hasAddress
        ? user.address!.split(',').map((e) => e.trim()).toList()
        : [];

    final city = addressParts.isNotEmpty ? addressParts[0] : '';
    final commune = addressParts.length > 1 ? addressParts[1] : '';
    final street = addressParts.length > 2 ? addressParts[2] : '';
    final door = addressParts.length > 3 ? addressParts[3] : '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      if (hasAddress)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (city.isNotEmpty)
                              Text(
                                'Ville : $city',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            if (commune.isNotEmpty)
                              Text(
                                'Commune : $commune',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            if (street.isNotEmpty)
                              Text(
                                'Rue : $street',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            if (door.isNotEmpty)
                              Text(
                                'Porte / Résidence : $door',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.red),
                  title: const Text("Modifier mes informations"),
                  onTap: () => _showEditInfoModal(context),
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.red),
                  title: const Text("Changer mon mot de passe"),
                  onTap: () => _showChangePasswordModal(context),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.red),
                  title: const Text("Mes commandes"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.red),
                  title: const Text("Bonus commandes"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.bonus),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Se déconnecter"),
                  onTap: () => _logout(context),
                ),
              ],
            ),
    );
  }
}
