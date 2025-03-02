import 'package:get_it/get_it.dart';
import '../../features/authentication/services/auth_service.dart';

/// Global ServiceLocator instance
final sl = GetIt.instance;

/// Initialize all dependencies
void setupServiceLocator() {
  // Services
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // Repositories
  // Add your repositories here

  // Use cases
  // Add your use cases here

  // ViewModels/Blocs
  // Add your view models or blocs here
}
