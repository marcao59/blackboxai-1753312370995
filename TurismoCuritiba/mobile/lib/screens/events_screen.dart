import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/language/language_bloc.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        final languageCode = languageState.locale.languageCode;
        
        final screenTexts = {
          'pt': {
            'title': 'Eventos',
            'featured': 'Destaques',
            'upcoming': 'Próximos',
            'all': 'Todos',
            'noEvents': 'Nenhum evento encontrado',
            'loadingEvents': 'Carregando eventos...',
          },
          'en': {
            'title': 'Events',
            'featured': 'Featured',
            'upcoming': 'Upcoming',
            'all': 'All',
            'noEvents': 'No events found',
            'loadingEvents': 'Loading events...',
          },
          'es': {
            'title': 'Eventos',
            'featured': 'Destacados',
            'upcoming': 'Próximos',
            'all': 'Todos',
            'noEvents': 'No se encontraron eventos',
            'loadingEvents': 'Cargando eventos...',
          },
        };

        final texts = screenTexts[languageCode] ?? screenTexts['pt']!;

        return Scaffold(
          appBar: AppBar(
            title: Text(texts['title']!),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: texts['featured']!),
                Tab(text: texts['upcoming']!),
                Tab(text: texts['all']!),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeaturedEvents(texts, languageCode),
              _buildUpcomingEvents(texts, languageCode),
              _buildAllEvents(texts, languageCode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedEvents(Map<String, String> texts, String languageCode) {
    // Mock featured events data
    final featuredEvents = _getMockEvents().where((event) => event.isFeatured).toList();

    return _buildEventsList(featuredEvents, texts, languageCode);
  }

  Widget _buildUpcomingEvents(Map<String, String> texts, String languageCode) {
    // Mock upcoming events data
    final upcomingEvents = _getMockEvents().where((event) => event.isUpcoming).toList();

    return _buildEventsList(upcomingEvents, texts, languageCode);
  }

  Widget _buildAllEvents(Map<String, String> texts, String languageCode) {
    // Mock all events data
    final allEvents = _getMockEvents();

    return _buildEventsList(allEvents, texts, languageCode);
  }

  Widget _buildEventsList(List<Event> events, Map<String, String> texts, String languageCode) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              texts['noEvents']!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh events logic
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event, languageCode);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToEventDetail(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[300],
              ),
              child: event.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        event.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.event, size: 50),
                    ),
            ),
            
            // Event Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title and Featured Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.getLocalizedTitle(languageCode),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (event.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DESTAQUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event Description
                  Text(
                    event.getLocalizedDescription(languageCode),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Event Date and Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Text(
                        _formatEventDate(event.startDate, event.endDate, languageCode),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Event Location
                  if (event.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Event Status
                  Row(
                    children: [
                      _buildEventStatusChip(event, languageCode),
                      const Spacer(),
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
  }

  Widget _buildEventStatusChip(Event event, String languageCode) {
    final statusTexts = {
      'pt': {
        'ongoing': 'Em Andamento',
        'upcoming': 'Próximo',
        'past': 'Finalizado',
      },
      'en': {
        'ongoing': 'Ongoing',
        'upcoming': 'Upcoming',
        'past': 'Past',
      },
      'es': {
        'ongoing': 'En Curso',
        'upcoming': 'Próximo',
        'past': 'Finalizado',
      },
    };

    final texts = statusTexts[languageCode] ?? statusTexts['pt']!;
    
    String status;
    Color color;
    
    if (event.isOngoing) {
      status = texts['ongoing']!;
      color = Colors.green;
    } else if (event.isUpcoming) {
      status = texts['upcoming']!;
      color = Colors.blue;
    } else {
      status = texts['past']!;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatEventDate(DateTime startDate, DateTime endDate, String languageCode) {
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
    
    if (startDate.day == endDate.day && 
        startDate.month == endDate.month && 
        startDate.year == endDate.year) {
      // Same day event
      return '${startDate.day} ${monthList[startDate.month - 1]} ${startDate.year}';
    } else {
      // Multi-day event
      return '${startDate.day} ${monthList[startDate.month - 1]} - ${endDate.day} ${monthList[endDate.month - 1]} ${endDate.year}';
    }
  }

  void _navigateToEventDetail(Event event) {
    // Navigate to event detail screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.getLocalizedTitle('pt')),
        content: Text(event.getLocalizedDescription('pt')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (event.ticketUrl != null)
            ElevatedButton(
              onPressed: () {
                // Open ticket URL
                Navigator.pop(context);
              },
              child: const Text('Comprar Ingresso'),
            ),
        ],
      ),
    );
  }

  // Mock data for demonstration
  List<Event> _getMockEvents() {
    final now = DateTime.now();
    
    return [
      Event(
        id: '1',
        title: {
          'pt': 'Terra-Feira com São Bel',
          'en': 'Terra-Feira with São Bel',
          'es': 'Terra-Feira con São Bel',
        },
        description: {
          'pt': 'Evento especial de música e cultura local com apresentações ao vivo.',
          'en': 'Special music and local culture event with live performances.',
          'es': 'Evento especial de música y cultura local con presentaciones en vivo.',
        },
        imageUrls: ['https://via.placeholder.com/400x200?text=Terra-Feira'],
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7, hours: 6)),
        location: 'Praça Tiradentes, Centro',
        category: 'música',
        isFeatured: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Event(
        id: '2',
        title: {
          'pt': 'Festival de Inverno de Curitiba',
          'en': 'Curitiba Winter Festival',
          'es': 'Festival de Invierno de Curitiba',
        },
        description: {
          'pt': 'Festival anual com shows, teatro e gastronomia típica de inverno.',
          'en': 'Annual festival with shows, theater and typical winter gastronomy.',
          'es': 'Festival anual con espectáculos, teatro y gastronomía típica de invierno.',
        },
        imageUrls: ['https://via.placeholder.com/400x200?text=Festival+Inverno'],
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 21)),
        location: 'Vários locais da cidade',
        category: 'festival',
        isFeatured: true,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Event(
        id: '3',
        title: {
          'pt': 'Exposição de Arte Contemporânea',
          'en': 'Contemporary Art Exhibition',
          'es': 'Exposición de Arte Contemporáneo',
        },
        description: {
          'pt': 'Mostra de artistas locais e nacionais no Museu Oscar Niemeyer.',
          'en': 'Exhibition of local and national artists at the Oscar Niemeyer Museum.',
          'es': 'Muestra de artistas locales y nacionales en el Museo Oscar Niemeyer.',
        },
        imageUrls: ['https://via.placeholder.com/400x200?text=Arte+Contemporanea'],
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 30)),
        location: 'Museu Oscar Niemeyer',
        category: 'arte',
        isFeatured: false,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Event(
        id: '4',
        title: {
          'pt': 'Feira Gastronômica do Largo da Ordem',
          'en': 'Largo da Ordem Food Fair',
          'es': 'Feria Gastronómica del Largo da Ordem',
        },
        description: {
          'pt': 'Feira semanal com comidas típicas e artesanato local.',
          'en': 'Weekly fair with typical foods and local crafts.',
          'es': 'Feria semanal con comidas típicas y artesanías locales.',
        },
        imageUrls: ['https://via.placeholder.com/400x200?text=Feira+Gastronomica'],
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3, hours: 8)),
        location: 'Largo da Ordem, Centro Histórico',
        category: 'gastronomia',
        isFeatured: false,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
