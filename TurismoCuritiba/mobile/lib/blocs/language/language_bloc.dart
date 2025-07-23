import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LanguageChanged extends LanguageEvent {
  final Locale locale;

  const LanguageChanged(this.locale);

  @override
  List<Object> get props => [locale];
}

class LanguageLoaded extends LanguageEvent {}

// States
abstract class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial() : super(const Locale('pt', 'BR'));
}

class LanguageLoadSuccess extends LanguageState {
  const LanguageLoadSuccess(Locale locale) : super(locale);
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageInitial()) {
    on<LanguageChanged>(_onLanguageChanged);
    on<LanguageLoaded>(_onLanguageLoaded);
  }

  void _onLanguageChanged(LanguageChanged event, Emitter<LanguageState> emit) {
    emit(LanguageLoadSuccess(event.locale));
  }

  void _onLanguageLoaded(LanguageLoaded event, Emitter<LanguageState> emit) {
    // Load saved language from preferences (simplified for now)
    emit(LanguageLoadSuccess(const Locale('pt', 'BR')));
  }

  String get currentLanguageCode {
    return state.locale.languageCode;
  }

  static const Map<String, Locale> supportedLanguages = {
    'pt': Locale('pt', 'BR'),
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
  };

  static const Map<String, String> languageNames = {
    'pt': 'Português',
    'en': 'English',
    'es': 'Español',
  };
}
