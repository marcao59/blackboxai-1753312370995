import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/tourist_points/tourist_points_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repository/firebase_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA50JwotsjCqaTUOtidl-Q2d12mA5DgKa0",
        authDomain: "blackbox-turismo-curitiba.firebaseapp.com",
        projectId: "blackbox-turismo-curitiba",
        storageBucket: "blackbox-turismo-curitiba.firebasestorage.app",
        messagingSenderId: "308975092257",
        appId: "1:308975092257:web:8c4e75b65a197d489a5960"
      ),
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseRepository repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(repository: repository),
        ),
        BlocProvider<TouristPointsBloc>(
          create: (context) => TouristPointsBloc(repository: repository),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return TurismoCuritibaApp(
            locale: state.locale,
          );
        },
      ),
    );
  }
}
