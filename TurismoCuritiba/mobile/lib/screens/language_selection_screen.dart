import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/auth/auth_bloc.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Turismo Curitiba',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Descubra a cidade maravilhosa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Language Selection Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Selecione seu idioma',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Choose your language',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF616161),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Elige tu idioma',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF616161),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Language Options
                      _buildLanguageOption(
                        context,
                        'Português',
                        'Brasil',
                        const Locale('pt', 'BR'),
                        '🇧🇷',
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageOption(
                        context,
                        'English',
                        'United States',
                        const Locale('en', 'US'),
                        '🇺🇸',
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageOption(
                        context,
                        'Español',
                        'España',
                        const Locale('es', 'ES'),
                        '🇪🇸',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Skip Button
                TextButton(
                  onPressed: () => _selectLanguage(context, const Locale('pt', 'BR')),
                  child: Text(
                    'Continuar em Português',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    String country,
    Locale locale,
    String flag,
  ) {
    return InkWell(
      onTap: () => _selectLanguage(context, locale),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    country,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2E7D32),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _selectLanguage(BuildContext context, Locale locale) {
    // Update language
    context.read<LanguageBloc>().add(LanguageChanged(locale));
    
    // Initialize authentication
    context.read<AuthBloc>().add(SignInAnonymously());
    
    // Navigate to home
    Navigator.of(context).pushReplacementNamed('/');
  }
}
