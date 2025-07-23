import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.appUser != null) {
      _nameController.text = authState.appUser!.name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, languageState) {
            final languageCode = languageState.locale.languageCode;
            final titles = {
              'pt': 'Perfil',
              'en': 'Profile',
              'es': 'Perfil',
            };
            return Text(titles[languageCode] ?? titles['pt']!);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (authState is AuthAuthenticated) {
            return _buildProfileContent(authState);
          }
          
          return _buildSignInPrompt();
        },
      ),
    );
  }

  Widget _buildProfileContent(AuthAuthenticated authState) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(authState, languageCode),
              const SizedBox(height: 32),
              _buildProfileForm(authState, languageCode),
              const SizedBox(height: 32),
              _buildLanguageSection(languageCode),
              const SizedBox(height: 32),
              _buildFavoritesSection(authState, languageCode),
              const SizedBox(height: 32),
              _buildVisitedSection(authState, languageCode),
              const SizedBox(height: 32),
              _buildSettingsSection(languageCode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AuthAuthenticated authState, String languageCode) {
    final headerTexts = {
      'pt': {
        'welcome': 'Bem-vindo',
        'member': 'Membro desde',
      },
      'en': {
        'welcome': 'Welcome',
        'member': 'Member since',
      },
      'es': {
        'welcome': 'Bienvenido',
        'member': 'Miembro desde',
      },
    };

    final texts = headerTexts[languageCode] ?? headerTexts['pt']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: authState.appUser?.photoUrl != null
                ? NetworkImage(authState.appUser!.photoUrl!)
                : null,
            child: authState.appUser?.photoUrl == null
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            '${texts['welcome']}, ${authState.appUser?.name ?? 'Usuário'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (authState.appUser != null)
            Text(
              '${texts['member']} ${_formatDate(authState.appUser!.createdAt, languageCode)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(AuthAuthenticated authState, String languageCode) {
    final formTexts = {
      'pt': {
        'personalInfo': 'Informações Pessoais',
        'name': 'Nome',
        'email': 'Email',
        'namePlaceholder': 'Digite seu nome',
      },
      'en': {
        'personalInfo': 'Personal Information',
        'name': 'Name',
        'email': 'Email',
        'namePlaceholder': 'Enter your name',
      },
      'es': {
        'personalInfo': 'Información Personal',
        'name': 'Nombre',
        'email': 'Correo electrónico',
        'namePlaceholder': 'Ingresa tu nombre',
      },
    };

    final texts = formTexts[languageCode] ?? formTexts['pt']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts['personalInfo']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: texts['name'],
                hintText: texts['namePlaceholder'],
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: texts['email'],
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              controller: TextEditingController(
                text: authState.firebaseUser.email ?? 'Usuário Anônimo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(String languageCode) {
    final languageTexts = {
      'pt': {
        'title': 'Idioma',
        'subtitle': 'Selecione seu idioma preferido',
      },
      'en': {
        'title': 'Language',
        'subtitle': 'Select your preferred language',
      },
      'es': {
        'title': 'Idioma',
        'subtitle': 'Selecciona tu idioma preferido',
      },
    };

    final texts = languageTexts[languageCode] ?? languageTexts['pt']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts['title']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              texts['subtitle']!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ...LanguageBloc.supportedLanguages.entries.map((entry) {
              final isSelected = entry.key == languageCode;
              return RadioListTile<String>(
                title: Text(LanguageBloc.languageNames[entry.key]!),
                value: entry.key,
                groupValue: languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageBloc>().add(
                      LanguageChanged(entry.value),
                    );
                  }
                },
                activeColor: const Color(0xFF2E7D32),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(AuthAuthenticated authState, String languageCode) {
    final favoriteTexts = {
      'pt': {
        'title': 'Favoritos',
        'subtitle': 'Seus pontos turísticos favoritos',
        'empty': 'Nenhum favorito ainda',
        'viewAll': 'Ver todos',
      },
      'en': {
        'title': 'Favorites',
        'subtitle': 'Your favorite tourist attractions',
        'empty': 'No favorites yet',
        'viewAll': 'View all',
      },
      'es': {
        'title': 'Favoritos',
        'subtitle': 'Tus atracciones turísticas favoritas',
        'empty': 'Aún no hay favoritos',
        'viewAll': 'Ver todos',
      },
    };

    final texts = favoriteTexts[languageCode] ?? favoriteTexts['pt']!;
    final favoriteCount = authState.appUser?.favoritePoints.length ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts['title']!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      texts['subtitle']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (favoriteCount > 0)
                  TextButton(
                    onPressed: () {
                      // Navigate to favorites list
                    },
                    child: Text(texts['viewAll']!),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  Text(
                    favoriteCount > 0
                        ? '$favoriteCount ${favoriteCount == 1 ? 'favorito' : 'favoritos'}'
                        : texts['empty']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitedSection(AuthAuthenticated authState, String languageCode) {
    final visitedTexts = {
      'pt': {
        'title': 'Histórico de Visitas',
        'subtitle': 'Lugares que você já visitou',
        'empty': 'Nenhuma visita registrada',
        'viewAll': 'Ver todos',
      },
      'en': {
        'title': 'Visit History',
        'subtitle': 'Places you have visited',
        'empty': 'No visits recorded',
        'viewAll': 'View all',
      },
      'es': {
        'title': 'Historial de Visitas',
        'subtitle': 'Lugares que has visitado',
        'empty': 'No hay visitas registradas',
        'viewAll': 'Ver todos',
      },
    };

    final texts = visitedTexts[languageCode] ?? visitedTexts['pt']!;
    final visitedCount = authState.appUser?.visitedPoints.length ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts['title']!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      texts['subtitle']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (visitedCount > 0)
                  TextButton(
                    onPressed: () {
                      // Navigate to visited list
                    },
                    child: Text(texts['viewAll']!),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  Text(
                    visitedCount > 0
                        ? '$visitedCount ${visitedCount == 1 ? 'local visitado' : 'locais visitados'}'
                        : texts['empty']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String languageCode) {
    final settingsTexts = {
      'pt': {
        'title': 'Configurações',
        'about': 'Sobre o App',
        'privacy': 'Política de Privacidade',
        'terms': 'Termos de Uso',
        'logout': 'Sair',
      },
      'en': {
        'title': 'Settings',
        'about': 'About App',
        'privacy': 'Privacy Policy',
        'terms': 'Terms of Use',
        'logout': 'Sign Out',
      },
      'es': {
        'title': 'Configuraciones',
        'about': 'Acerca de la App',
        'privacy': 'Política de Privacidad',
        'terms': 'Términos de Uso',
        'logout': 'Cerrar Sesión',
      },
    };

    final texts = settingsTexts[languageCode] ?? settingsTexts['pt']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts['title']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              Icons.info_outline,
              texts['about']!,
              () => _showAboutDialog(),
            ),
            _buildSettingsItem(
              Icons.privacy_tip_outlined,
              texts['privacy']!,
              () => _showPrivacyPolicy(),
            ),
            _buildSettingsItem(
              Icons.description_outlined,
              texts['terms']!,
              () => _showTermsOfUse(),
            ),
            const Divider(),
            _buildSettingsItem(
              Icons.logout,
              texts['logout']!,
              () => _showLogoutDialog(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF2E7D32),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSignInPrompt() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final promptTexts = {
          'pt': {
            'title': 'Faça login para continuar',
            'subtitle': 'Acesse seu perfil e personalize sua experiência',
            'button': 'Entrar',
          },
          'en': {
            'title': 'Sign in to continue',
            'subtitle': 'Access your profile and personalize your experience',
            'button': 'Sign In',
          },
          'es': {
            'title': 'Inicia sesión para continuar',
            'subtitle': 'Accede a tu perfil y personaliza tu experiencia',
            'button': 'Iniciar Sesión',
          },
        };

        final texts = promptTexts[languageCode] ?? promptTexts['pt']!;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 24),
                Text(
                  texts['title']!,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  texts['subtitle']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInAnonymously());
                  },
                  child: Text(texts['button']!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.appUser != null) {
      final updatedUser = authState.appUser!.copyWith(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );
      
      context.read<AuthBloc>().add(UpdateUserProfile(updatedUser));
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Turismo Curitiba'),
        content: const Text(
          'Aplicativo oficial de turismo de Curitiba.\n\n'
          'Versão 1.0.0\n\n'
          'Desenvolvido para ajudar você a descobrir os melhores pontos turísticos da cidade.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // Implementation for privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Política de Privacidade em desenvolvimento')),
    );
  }

  void _showTermsOfUse() {
    // Implementation for terms of use
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Termos de Uso em desenvolvimento')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOut());
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String languageCode) {
    final months = {
      'pt': [
        'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
      ],
      'en': [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ],
      'es': [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ],
    };

    final monthList = months[languageCode] ?? months['pt']!;
    return '${monthList[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
