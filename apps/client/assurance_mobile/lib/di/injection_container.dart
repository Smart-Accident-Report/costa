import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/network/network_info.dart';
import '../features/create_insurance/data/data_souce/create_insurance_remote_data_source.dart';
import '../features/create_insurance/data/repositories/create_insurance_repository_impl.dart';
import '../features/create_insurance/domain/repositories/create_insurance_repository.dart';
import '../features/create_insurance/domain/usecases/create_insurance_usecase.dart';
import '../features/create_insurance/presentation/bloc/create_insurance_bloc.dart';
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/domain/usecases/get_onboarding_seen.dart';
import '../features/onboarding/domain/usecases/save_onboarding_seen.dart';
import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../features/splash/domain/is_user_loged_in.dart';
import '../features/splash/presentation/bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await sl.reset();

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl<Connectivity>(),
      connectionChecker: sl<InternetConnection>(),
    ),
  );

  // Onboarding Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl<SharedPreferences>()),
  );

  // Onboarding Use Cases
  sl.registerLazySingleton<GetOnboardingSeen>(
      () => GetOnboardingSeen(sl<OnboardingRepository>()));
  sl.registerLazySingleton<SaveOnboardingSeen>(
      () => SaveOnboardingSeen(sl<OnboardingRepository>()));

  // Splash Use Cases
  sl.registerLazySingleton<IsUserLoggedIn>(
    () => IsUserLoggedIn(),
  );

  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      getSeen: sl<GetOnboardingSeen>(),
      saveSeen: sl<SaveOnboardingSeen>(),
    ),
  );

  sl.registerFactory<SplashBloc>(
    () => SplashBloc(
      getOnboardingSeen: sl<GetOnboardingSeen>(),
      isUserLoggedIn: sl<IsUserLoggedIn>(),
    ),
  );
  sl.registerLazySingleton<CreateInsuranceRemoteDataSource>(
    () => CreateInsuranceRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<CreateInsuranceRepository>(
    () => CreateInsuranceRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Case
  sl.registerLazySingleton<CreateInsuranceAccountUseCase>(
    () => CreateInsuranceAccountUseCase(sl()),
  );

  // BLoC
  sl.registerFactory<CreateInsuranceBloc>(
    () => CreateInsuranceBloc(createInsuranceAccount: sl()),
  );
}
