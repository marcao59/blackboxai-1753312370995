import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/tourist_points/tourist_points_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../models/tourist_point.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _getCurrentLocation();
  }

  void _loadInitialData() {
    context.read<TouristPointsBloc>().add(const LoadTouristPoints());
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turismo Curitiba'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
              _buildNearbySection(),
              const SizedBox(height: 24),
              _buildFeaturedSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final welcomeTexts = {
          'pt': {
            'title': 'Bem-vindo a Curitiba!',
            'subtitle': 'Descubra os melhores pontos turísticos da cidade',
          },
          'en': {
            'title': 'Welcome to Curitiba!',
            'subtitle': 'Discover the best tourist attractions in the city',
          },
          'es': {
            'title': '¡Bienvenido a Curitiba!',
            'subtitle': 'Descubre las mejores atracciones turísticas de la ciudad',
          },
        };

        final texts = welcomeTexts[languageCode] ?? welcomeTexts['pt']!;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts['title']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                texts['subtitle']!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final placeholders = {
          'pt': 'Buscar pontos turísticos...',
          'en': 'Search tourist attractions...',
          'es': 'Buscar atracciones turísticas...',
        };

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: placeholders[languageCode] ?? placeholders['pt'],
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadInitialData();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                context.read<TouristPointsBloc>().add(
                  SearchTouristPoints(
                    query: query,
                    languageCode: languageCode,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final categoryTexts = {
          'pt': {
            'title': 'Categorias',
            'categories': [
              {'name': 'Rotas Turísticas', 'icon': Icons.route, 'category': 'rotas'},
              {'name': 'Perto de Você', 'icon': Icons.near_me, 'category': 'nearby'},
              {'name': 'O que Fazer', 'icon': Icons.local_activity, 'category': 'atividades'},
              {'name': 'Onde Comer', 'icon': Icons.restaurant, 'category': 'restaurantes'},
              {'name': 'Onde Dormir', 'icon': Icons.hotel, 'category': 'hoteis'},
              {'name': 'Eventos', 'icon': Icons.event, 'category': 'eventos'},
            ],
          },
          'en': {
            'title': 'Categories',
            'categories': [
              {'name': 'Tourist Routes', 'icon': Icons.route, 'category': 'rotas'},
              {'name': 'Near You', 'icon': Icons.near_me, 'category': 'nearby'},
              {'name': 'What to Do', 'icon': Icons.local_activity, 'category': 'atividades'},
              {'name': 'Where to Eat', 'icon': Icons.restaurant, 'category': 'restaurantes'},
              {'name': 'Where to Stay', 'icon': Icons.hotel, 'category': 'hoteis'},
              {'name': 'Events', 'icon': Icons.event, 'category': 'eventos'},
            ],
          },
          'es': {
            'title': 'Categorías',
            'categories': [
              {'name': 'Rutas Turísticas', 'icon': Icons.route, 'category': 'rotas'},
              {'name': 'Cerca de Ti', 'icon': Icons.near_me, 'category': 'nearby'},
              {'name': 'Qué Hacer', 'icon': Icons.local_activity, 'category': 'atividades'},
              {'name': 'Dónde Comer', 'icon': Icons.restaurant, 'category': 'restaurantes'},
              {'name': 'Dónde Dormir', 'icon': Icons.hotel, 'category': 'hoteis'},
              {'name': 'Eventos', 'icon': Icons.event, 'category': 'eventos'},
            ],
          },
        };

        final texts = categoryTexts[languageCode] ?? categoryTexts['pt']!;
        final categories = texts['categories'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts['title']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  category['name'],
                  category['icon'],
                  category['category'],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, String category) {
    return Card(
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySection() {
    if (_currentPosition == null) return const SizedBox.shrink();

    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final titles = {
          'pt': 'Perto de Você',
          'en': 'Near You',
          'es': 'Cerca de Ti',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titles[languageCode] ?? titles['pt']!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () => _loadNearbyPoints(),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BlocBuilder<TouristPointsBloc, TouristPointsState>(
                builder: (context, state) {
                  if (state is TouristPointsLoaded && state.category == 'nearby') {
                    return _buildHorizontalPointsList(state.points);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final titles = {
          'pt': 'Destaques',
          'en': 'Featured',
          'es': 'Destacados',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[languageCode] ?? titles['pt']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<TouristPointsBloc, TouristPointsState>(
              builder: (context, state) {
                if (state is TouristPointsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TouristPointsLoaded) {
                  final featuredPoints = state.points.take(5).toList();
                  return _buildVerticalPointsList(featuredPoints, languageCode);
                } else if (state is TouristPointsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHorizontalPointsList(List<TouristPoint> points) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: _buildPointCard(point, true),
        );
      },
    );
  }

  Widget _buildVerticalPointsList(List<TouristPoint> points, String languageCode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildPointCard(point, false),
        );
      },
    );
  }

  Widget _buildPointCard(TouristPoint point, bool isHorizontal) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        return Card(
          child: InkWell(
            onTap: () => _navigateToDetail(point),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: isHorizontal ? 100 : 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[300],
                  ),
                  child: point.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            point.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.location_on, size: 40),
                        ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.getLocalizedName(languageCode),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: isHorizontal ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (!isHorizontal) ...[
                        Text(
                          point.getLocalizedDescription(languageCode),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            point.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Spacer(),
                          if (!isHorizontal)
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCategoryTap(String category) {
    if (category == 'nearby' && _currentPosition != null) {
      _loadNearbyPoints();
    } else if (category == 'eventos') {
      Navigator.pushNamed(context, '/events');
    } else {
      context.read<TouristPointsBloc>().add(LoadTouristPoints(category: category));
    }
  }

  void _loadNearbyPoints() {
    if (_currentPosition != null) {
      context.read<TouristPointsBloc>().add(
        LoadNearbyTouristPoints(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radiusKm: 10.0,
        ),
      );
    }
  }

  void _navigateToDetail(TouristPoint point) {
    Navigator.pushNamed(
      context,
      '/detail',
      arguments: point,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
