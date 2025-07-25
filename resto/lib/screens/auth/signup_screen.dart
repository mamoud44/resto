import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../constants/colors.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final String _defaultCity = "Abidjan";

  bool _isObscure = true;
  bool _isLoading = false;
  String? _passwordError;

  void _validatePassword(String value) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    setState(() {
      _passwordError = regex.hasMatch(value)
          ? null
          : 'Min. 8 caractères, 1 majuscule, 1 chiffre, 1 symbole';
    });
  }

  void _register() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = '$_defaultCity, ${_addressController.text.trim()}';
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if ([
      fullName,
      email,
      phone,
      _addressController.text.trim(),
      password,
      confirmPassword,
    ].any((e) => e.isEmpty)) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }

    if (_passwordError != null) {
      _showError('Mot de passe non sécurisé.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).register({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'password': password,
        'password2': confirmPassword,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie ! Connectez-vous.')),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        String message = 'Erreur lors de l\'inscription.';
        if (errorData is Map && errorData.isNotEmpty) {
          message = errorData.values.first.toString();
        }
        _showError(message);
      } else {
        _showError('Erreur inattendue : ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.08),
              Text(
                'Créer un compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenue parmi nous ! Remplissez les champs ci-dessous.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Nom complet',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  'Numéro de téléphone',
                  Icons.phone_android,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _addressController,
                decoration: _inputDecoration(
                  'Adresse complète (Commune, Rue, N° porte ou residence)',
                  Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                onChanged: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
