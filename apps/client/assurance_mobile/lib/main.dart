import 'package:assurance_mobile/features/create_insurance/presentation/bloc/create_insurance_bloc.dart';
import 'package:assurance_mobile/features/create_insurance/presentation/screen/create_insurance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'di/injection_container.dart' as di;
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await dotenv.load(fileName: ".env");
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<SplashBloc>()..add(const InitializeApp()),
        ),
        BlocProvider(
          create: (_) => di.sl<OnboardingBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<CreateInsuranceBloc>(),
        ),
      ],
      child: _buildApp(),
    );
  }

  Widget _buildApp() {
    Widget initialScreen;
    if (kIsWeb) {
      initialScreen = const Scaffold();
    } else {
      initialScreen = const SplashScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Editions Lection',
      theme: AppTheme.darkTheme,
      home: initialScreen,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _createRoute(const SplashScreen());
      case '/onboarding':
        return _createRoute(
          BlocProvider(
            create: (_) => di.sl<OnboardingBloc>(),
            child: const OnboardingScreen(),
          ),
        );
      case '/create_insurance':
        return _createRoute(
          BlocProvider(
            create: (_) => di.sl<CreateInsuranceBloc>(),
            child: CreateInsuranceScreen(),
          ),
        );
      // case '/login':
      //   return _createRoute(const LoginScreen());
      // case '/signup':
      //   return _createRoute(const SignupScreen());

      // case '/forgot_password':
      //   return _createRoute(const ForgotPasswordScreen());
      // case '/profile':
      //   return _createRoute(const ProfileScreen());

      default:
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Error: Page not found!'),
            ),
          ),
        );
    }
  }

  Route<dynamic> _createRoute(Widget screen) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPageRoute(builder: (context) => screen);
    } else {
      return MaterialPageRoute(builder: (context) => screen);
    }
  }
}
