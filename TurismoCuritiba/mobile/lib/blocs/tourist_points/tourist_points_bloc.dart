import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/tourist_point.dart';
import '../../repository/firebase_repository.dart';

// Events
abstract class TouristPointsEvent extends Equatable {
  const TouristPointsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTouristPoints extends TouristPointsEvent {
  final String? category;

  const LoadTouristPoints({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadNearbyTouristPoints extends TouristPointsEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LoadNearbyTouristPoints({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });

  @override
  List<Object> get props => [latitude, longitude, radiusKm];
}

class SearchTouristPoints extends TouristPointsEvent {
  final String query;
  final String languageCode;

  const SearchTouristPoints({
    required this.query,
    required this.languageCode,
  });

  @override
  List<Object> get props => [query, languageCode];
}

class LoadTouristPointDetails extends TouristPointsEvent {
  final String pointId;

  const LoadTouristPointDetails(this.pointId);

  @override
  List<Object> get props => [pointId];
}

class AddToFavorites extends TouristPointsEvent {
  final String userId;
  final String pointId;

  const AddToFavorites({
    required this.userId,
    required this.pointId,
  });

  @override
  List<Object> get props => [userId, pointId];
}

class RemoveFromFavorites extends TouristPointsEvent {
  final String userId;
  final String pointId;

  const RemoveFromFavorites({
    required this.userId,
    required this.pointId,
  });

  @override
  List<Object> get props => [userId, pointId];
}

class AddReview extends TouristPointsEvent {
  final String pointId;
  final String userId;
  final double rating;
  final String comment;

  const AddReview({
    required this.pointId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [pointId, userId, rating, comment];
}

// States
abstract class TouristPointsState extends Equatable {
  const TouristPointsState();

  @override
  List<Object?> get props => [];
}

class TouristPointsInitial extends TouristPointsState {}

class TouristPointsLoading extends TouristPointsState {}

class TouristPointsLoaded extends TouristPointsState {
  final List<TouristPoint> points;
  final String? category;

  const TouristPointsLoaded({
    required this.points,
    this.category,
  });

  @override
  List<Object?> get props => [points, category];
}

class TouristPointsError extends TouristPointsState {
  final String message;

  const TouristPointsError(this.message);

  @override
  List<Object> get props => [message];
}

class TouristPointDetailsLoaded extends TouristPointsState {
  final TouristPoint point;

  const TouristPointDetailsLoaded(this.point);

  @override
  List<Object> get props => [point];
}

class TouristPointsSearchResults extends TouristPointsState {
  final List<TouristPoint> results;
  final String query;

  const TouristPointsSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}

class FavoriteUpdated extends TouristPointsState {
  final bool isAdded;
  final String pointId;

  const FavoriteUpdated({
    required this.isAdded,
    required this.pointId,
  });

  @override
  List<Object> get props => [isAdded, pointId];
}

class ReviewAdded extends TouristPointsState {
  final String pointId;

  const ReviewAdded(this.pointId);

  @override
  List<Object> get props => [pointId];
}

// BLoC
class TouristPointsBloc extends Bloc<TouristPointsEvent, TouristPointsState> {
  final FirebaseRepository repository;

  TouristPointsBloc({required this.repository}) : super(TouristPointsInitial()) {
    on<LoadTouristPoints>(_onLoadTouristPoints);
    on<LoadNearbyTouristPoints>(_onLoadNearbyTouristPoints);
    on<SearchTouristPoints>(_onSearchTouristPoints);
    on<LoadTouristPointDetails>(_onLoadTouristPointDetails);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<AddReview>(_onAddReview);
  }

  Future<void> _onLoadTouristPoints(
    LoadTouristPoints event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      emit(TouristPointsLoading());
      
      final points = await repository.getTouristPoints(category: event.category);
      
      emit(TouristPointsLoaded(
        points: points,
        category: event.category,
      ));
    } catch (e) {
      emit(TouristPointsError('Erro ao carregar pontos turísticos: $e'));
    }
  }

  Future<void> _onLoadNearbyTouristPoints(
    LoadNearbyTouristPoints event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      emit(TouristPointsLoading());
      
      final points = await repository.getNearbyTouristPoints(
        event.latitude,
        event.longitude,
        event.radiusKm,
      );
      
      emit(TouristPointsLoaded(
        points: points,
        category: 'nearby',
      ));
    } catch (e) {
      emit(TouristPointsError('Erro ao carregar pontos próximos: $e'));
    }
  }

  Future<void> _onSearchTouristPoints(
    SearchTouristPoints event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      emit(TouristPointsLoading());
      
      final results = await repository.searchTouristPoints(
        event.query,
        event.languageCode,
      );
      
      emit(TouristPointsSearchResults(
        results: results,
        query: event.query,
      ));
    } catch (e) {
      emit(TouristPointsError('Erro na busca: $e'));
    }
  }

  Future<void> _onLoadTouristPointDetails(
    LoadTouristPointDetails event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      emit(TouristPointsLoading());
      
      final point = await repository.getTouristPointById(event.pointId);
      
      if (point != null) {
        emit(TouristPointDetailsLoaded(point));
      } else {
        emit(const TouristPointsError('Ponto turístico não encontrado'));
      }
    } catch (e) {
      emit(TouristPointsError('Erro ao carregar detalhes: $e'));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      final success = await repository.addToFavorites(
        event.userId,
        event.pointId,
      );
      
      if (success) {
        emit(FavoriteUpdated(isAdded: true, pointId: event.pointId));
      } else {
        emit(const TouristPointsError('Erro ao adicionar aos favoritos'));
      }
    } catch (e) {
      emit(TouristPointsError('Erro ao adicionar aos favoritos: $e'));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      final success = await repository.removeFromFavorites(
        event.userId,
        event.pointId,
      );
      
      if (success) {
        emit(FavoriteUpdated(isAdded: false, pointId: event.pointId));
      } else {
        emit(const TouristPointsError('Erro ao remover dos favoritos'));
      }
    } catch (e) {
      emit(TouristPointsError('Erro ao remover dos favoritos: $e'));
    }
  }

  Future<void> _onAddReview(
    AddReview event,
    Emitter<TouristPointsState> emit,
  ) async {
    try {
      final success = await repository.addReview(
        event.pointId,
        event.userId,
        event.rating,
        event.comment,
      );
      
      if (success) {
        emit(ReviewAdded(event.pointId));
      } else {
        emit(const TouristPointsError('Erro ao adicionar avaliação'));
      }
    } catch (e) {
      emit(TouristPointsError('Erro ao adicionar avaliação: $e'));
    }
  }
}
