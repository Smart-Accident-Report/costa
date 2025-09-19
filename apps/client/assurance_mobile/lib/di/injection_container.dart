import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/network_info.dart';

import '../features/constat/data/datasources/constat_remote_data.dart';
import '../features/constat/data/datasources/driver_remote_data.dart';
import '../features/constat/data/datasources/insurance_remote_data.dart';
import '../features/constat/data/datasources/vehicule_remote_data.dart';
import '../features/constat/presentation/bloc/constat_bloc.dart';
import '../features/constat/presentation/bloc/driver_bloc.dart';
import '../features/constat/presentation/bloc/insurance_bloc.dart';
import '../features/constat/presentation/bloc/scan_bloc.dart';
import '../features/constat/presentation/bloc/vehicule_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
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

  sl.registerFactory(() => DriverBloc(driverRepository: sl()));
  sl.registerFactory(() => VehicleBloc(vehicleRepository: sl()));
  sl.registerFactory(() => InsuranceBloc(insuranceRepository: sl()));
  sl.registerFactory(() => ConstatBloc(constatRepository: sl()));
  sl.registerFactory(() => ScanBloc(constatRepository: sl()));

  // sl.registerLazySingleton<DriverRepository>(
  //   () => DriverRepositoryImpl(remoteDataSource: sl()),
  // );
  // sl.registerLazySingleton<VehicleRepository>(
  //   () => VehicleRepositoryImpl(remoteDataSource: sl()),
  // );

  sl.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<InsuranceRemoteDataSource>(
    () => InsuranceRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ConstatRemoteDataSource>(
    () => ConstatRemoteDataSourceImpl(),
  );
}
