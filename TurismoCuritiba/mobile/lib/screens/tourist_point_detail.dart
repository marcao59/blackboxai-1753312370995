import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/tourist_points/tourist_points_bloc.dart';
import '../models/tourist_point.dart';

class TouristPointDetail extends StatefulWidget {
  const TouristPointDetail({Key? key}) : super(key: key);

  @override
  State<TouristPointDetail> createState() => _TouristPointDetailState();
}

class _TouristPointDetailState extends State<TouristPointDetail> {
  GoogleMapController? _mapController;
  PageController _imageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final TouristPoint point = ModalRoute.of(context)!.settings.arguments as TouristPoint;

    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(point, languageCode),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(point, languageCode),
                      const SizedBox(height: 16),
                      _buildRatingSection(point, languageCode),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(point, languageCode),
                      const SizedBox(height: 24),
                      _buildInfoSection(point, languageCode),
                      const SizedBox(height: 24),
                      _buildMapSection(point, languageCode),
                      const SizedBox(height: 24),
                      _buildActionButtons(point, languageCode),
                      const SizedBox(height: 24),
                      _buildReviewSection(point, languageCode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(TouristPoint point, String languageCode) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => _toggleFavorite(point),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _sharePoint(point, languageCode),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: point.imageUrls.isNotEmpty
            ? Stack(
                children: [
                  PageView.builder(
                    controller: _imageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: point.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        point.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      );
                    },
                  ),
                  if (point.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: point.imageUrls.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.location_on, size: 80),
              ),
      ),
    );
  }

  Widget _buildTitleSection(TouristPoint point, String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          point.getLocalizedName(languageCode),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                point.getLocalizedAddress(languageCode),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(TouristPoint point, String languageCode) {
    final ratingTexts = {
      'pt': 'avaliações',
      'en': 'reviews',
      'es': 'reseñas',
    };

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < point.rating.floor()
                  ? Icons.star
                  : index < point.rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: Colors.amber,
              size: 24,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${point.rating.toStringAsFixed(1)} (${point.reviewCount} ${ratingTexts[languageCode] ?? ratingTexts['pt']})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(TouristPoint point, String languageCode) {
    final titles = {
      'pt': 'Sobre',
      'en': 'About',
      'es': 'Acerca de',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[languageCode] ?? titles['pt']!,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          point.getLocalizedDescription(languageCode),
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(TouristPoint point, String languageCode) {
    final infoTexts = {
      'pt': {
        'info': 'Informações',
        'phone': 'Telefone',
        'website': 'Website',
        'hours': 'Horário de Funcionamento',
      },
      'en': {
        'info': 'Information',
        'phone': 'Phone',
        'website': 'Website',
        'hours': 'Opening Hours',
      },
      'es': {
        'info': 'Información',
        'phone': 'Teléfono',
        'website': 'Sitio web',
        'hours': 'Horario de Apertura',
      },
    };

    final texts = infoTexts[languageCode] ?? infoTexts['pt']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['info']!,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        if (point.phone != null) ...[
          _buildInfoRow(
            Icons.phone,
            texts['phone']!,
            point.phone!,
            () => _launchPhone(point.phone!),
          ),
          const SizedBox(height: 8),
        ],
        if (point.website != null) ...[
          _buildInfoRow(
            Icons.web,
            texts['website']!,
            point.website!,
            () => _launchUrl(point.website!),
          ),
          const SizedBox(height: 8),
        ],
        if (point.openingHours != null) ...[
          _buildInfoRow(
            Icons.access_time,
            texts['hours']!,
            point.openingHours![languageCode] ?? point.openingHours!.values.first,
            null,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: onTap != null ? const Color(0xFF2E7D32) : null,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(TouristPoint point, String languageCode) {
    final titles = {
      'pt': 'Localização',
      'en': 'Location',
      'es': 'Ubicación',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[languageCode] ?? titles['pt']!,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(point.latitude, point.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(point.id),
                  position: LatLng(point.latitude, point.longitude),
                  infoWindow: InfoWindow(
                    title: point.getLocalizedName(languageCode),
                  ),
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TouristPoint point, String languageCode) {
    final buttonTexts = {
      'pt': {
        'directions': 'Como Chegar',
        'visited': 'Marcar como Visitado',
      },
      'en': {
        'directions': 'Get Directions',
        'visited': 'Mark as Visited',
      },
      'es': {
        'directions': 'Cómo Llegar',
        'visited': 'Marcar como Visitado',
      },
    };

    final texts = buttonTexts[languageCode] ?? buttonTexts['pt']!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openDirections(point),
            icon: const Icon(Icons.directions),
            label: Text(texts['directions']!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _markAsVisited(point),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(texts['visited']!),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(TouristPoint point, String languageCode) {
    final reviewTexts = {
      'pt': {
        'title': 'Avaliações',
        'add': 'Adicionar Avaliação',
        'rating': 'Sua avaliação',
        'comment': 'Comentário (opcional)',
        'submit': 'Enviar',
        'cancel': 'Cancelar',
      },
      'en': {
        'title': 'Reviews',
        'add': 'Add Review',
        'rating': 'Your rating',
        'comment': 'Comment (optional)',
        'submit': 'Submit',
        'cancel': 'Cancel',
      },
      'es': {
        'title': 'Reseñas',
        'add': 'Agregar Reseña',
        'rating': 'Tu calificación',
        'comment': 'Comentario (opcional)',
        'submit': 'Enviar',
        'cancel': 'Cancelar',
      },
    };

    final texts = reviewTexts[languageCode] ?? reviewTexts['pt']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts['title']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton.icon(
              onPressed: () => _showAddReviewDialog(point, texts),
              icon: const Icon(Icons.add),
              label: Text(texts['add']!),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Placeholder for reviews list
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'As avaliações aparecerão aqui quando implementadas.',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite(TouristPoint point) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.appUser != null) {
      final userId = authState.firebaseUser.uid;
      
      if (_isFavorite) {
        context.read<TouristPointsBloc>().add(
          RemoveFromFavorites(userId: userId, pointId: point.id),
        );
      } else {
        context.read<TouristPointsBloc>().add(
          AddToFavorites(userId: userId, pointId: point.id),
        );
      }
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _sharePoint(TouristPoint point, String languageCode) {
    final name = point.getLocalizedName(languageCode);
    final description = point.getLocalizedDescription(languageCode);
    
    Share.share(
      'Confira este ponto turístico: $name\n\n$description\n\nTurismo Curitiba',
      subject: name,
    );
  }

  void _openDirections(TouristPoint point) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${point.latitude},${point.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _markAsVisited(TouristPoint point) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.appUser != null) {
      // Implementation for marking as visited
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marcado como visitado!')),
      );
    }
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showAddReviewDialog(TouristPoint point, Map<String, String> texts) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['add']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texts['rating']!),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    rating = index + 1.0;
                  },
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: texts['comment'],
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(texts['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              _submitReview(point, rating, commentController.text);
              Navigator.pop(context);
            },
            child: Text(texts['submit']!),
          ),
        ],
      ),
    );
  }

  void _submitReview(TouristPoint point, double rating, String comment) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TouristPointsBloc>().add(
        AddReview(
          pointId: point.id,
          userId: authState.firebaseUser.uid,
          rating: rating,
          comment: comment,
        ),
      );
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
