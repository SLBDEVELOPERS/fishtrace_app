import 'package:fishtrace/core/data/repositories.dart';
import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/authentication/domain/repositories/onboarding_repository.dart';
import 'package:fishtrace/features/authentication/presentation/controllers/authentication_controller.dart';
import 'package:fishtrace/features/common/data/repositories/mock_common_repository.dart';
import 'package:fishtrace/features/common/data/repositories/profile_repositories.dart';
import 'package:fishtrace/features/common/domain/entities/mobile_settings.dart';
import 'package:fishtrace/features/common/domain/repositories/mobile_settings_repository.dart';
import 'package:fishtrace/features/common/domain/repositories/profile_repository.dart';
import 'package:fishtrace/features/common/presentation/controllers/common_controller.dart';
import 'package:fishtrace/features/common/presentation/controllers/mobile_settings_controller.dart';
import 'package:fishtrace/features/fisher/data/repositories/mock_fisher_repository.dart';
import 'package:fishtrace/features/fisher/presentation/controllers/fisher_controller.dart';
import 'package:fishtrace/features/processor/data/repositories/mock_processor_repository.dart';
import 'package:fishtrace/features/processor/presentation/controllers/processor_controller.dart';
import 'package:fishtrace/features/retailer/data/repositories/mock_retailer_repository.dart';
import 'package:fishtrace/features/retailer/presentation/controllers/retailer_controller.dart';
import 'package:fishtrace/features/retailer/presentation/controllers/retail_reports_controller.dart';
import 'package:fishtrace/features/transporter/data/repositories/sensor_repositories.dart';
import 'package:fishtrace/features/transporter/data/repositories/mock_transporter_repository.dart';
import 'package:fishtrace/features/transporter/presentation/controllers/live_monitoring_controller.dart';
import 'package:fishtrace/features/transporter/presentation/controllers/transporter_controller.dart';
import 'package:get/get.dart';

import 'package:fishtrace/core/network/sensor_stream.dart';

class MemoryOnboardingRepository implements OnboardingRepository {
  bool complete = false;
  @override
  Future<bool> isComplete() async => complete;
  @override
  Future<void> markComplete() async => complete = true;
}

class MemoryMobileSettingsRepository implements MobileSettingsRepository {
  MobileSettings value = const MobileSettings();

  @override
  Future<MobileSettings> load() async => value;

  @override
  Future<void> save(MobileSettings settings) async => value = settings;
}

AppController registerTestDependencies({UserRole? role}) {
  Get.reset();
  final session = AppController(auth: MockAuthRepository());
  if (role != null) {
    session.user.value = User(
      name: 'Alex Johnson',
      email: '${role.name}@fishtrace.demo',
      role: role,
    );
  }
  Get.put(session, permanent: true);
  Get.put(
    MobileSettingsController(MemoryMobileSettingsRepository()),
    permanent: true,
  );
  Get.put(
    AuthenticationController(
      session: session,
      onboarding: MemoryOnboardingRepository(),
    ),
    permanent: true,
  );
  Get.put(CommonController(MockCommonRepository()), permanent: true);
  Get.put<ProfileRepository>(MockProfileRepository(), permanent: true);
  Get.put(
    FisherController(repository: MockFisherRepository(), session: session),
    permanent: true,
  );
  Get.put(
    ProcessorController(
      repository: MockProcessorRepository(),
      session: session,
    ),
    permanent: true,
  );
  Get.put(
    TransporterController(
      repository: MockTransporterRepository(),
      session: session,
    ),
    permanent: true,
  );
  Get.put(
    RetailerController(repository: MockRetailerRepository(), session: session),
    permanent: true,
  );
  Get.put(
    RetailReportsController(repository: MockRetailerRepository()),
    permanent: true,
  );
  final sensorStream = MockSensorStream();
  Get.put(
    LiveMonitoringController(
      liveSensorRepository: MockLiveSensorRepository(sensorStream),
      sensorRepository: MockSensorRepository(sensorStream),
      session: session,
    ),
    permanent: true,
  );
  return session;
}
