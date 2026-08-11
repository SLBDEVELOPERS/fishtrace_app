import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../core/models/models.dart';
import '../../core/data/repositories.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/recovery_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/common/presentation/screens/help_support_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/common/presentation/screens/offline_sync_screen.dart';
import '../../features/common/presentation/screens/profile_screen.dart';
import '../../features/fisher/presentation/screens/boat_management_screen.dart';
import '../../features/fisher/presentation/screens/active_trip_details_screen.dart';
import '../../features/fisher/presentation/screens/add_catch_screen.dart';
import '../../features/fisher/presentation/screens/batch_details_screen.dart';
import '../../features/fisher/presentation/screens/batch_list_screen.dart';
import '../../features/fisher/presentation/screens/catch_history_screen.dart';
import '../../features/fisher/presentation/screens/create_batch_screen.dart';
import '../../features/fisher/presentation/screens/fisher_dashboard_screen.dart';
import '../../features/fisher/presentation/screens/start_fishing_trip_screen.dart';
import '../../features/processor/presentation/screens/batch_intake_screen.dart';
import '../../features/processor/presentation/screens/processed_batch_details_screen.dart';
import '../../features/processor/presentation/screens/processing_history_screen.dart';
import '../../features/processor/presentation/screens/processing_workflow_screen.dart';
import '../../features/processor/presentation/screens/processor_dashboard_screen.dart';
import '../../features/processor/presentation/screens/quality_inspection_screen.dart';
import '../../features/processor/presentation/screens/scan_batch_screen.dart';
import '../../features/processor/presentation/screens/split_pack_screen.dart';
import '../../features/transporter/presentation/screens/batch_device_vehicle_screens.dart';
import '../../features/transporter/presentation/screens/checklist_monitoring_delivery_screens.dart';
import '../../features/transporter/presentation/screens/transporter_dashboard_screen.dart';
import '../../features/transporter/presentation/screens/trips_screens.dart';
import '../../features/transporter/presentation/screens/transport_trip_form_screen.dart';
import '../../features/retailer/presentation/screens/inventory_screen.dart';
import '../../features/retailer/presentation/screens/receive_batch_screens.dart';
import '../../features/retailer/presentation/screens/retail_alerts_screen.dart';
import '../../features/retailer/presentation/screens/retailer_dashboard_screen.dart';
import '../../features/retailer/presentation/screens/sales_reports_screen.dart';
import '../../features/retailer/presentation/screens/stock_sales_screen.dart';

abstract final class AppRoute {
  static const splash = '/splash',
      onboarding = '/onboarding',
      login = '/login',
      recovery = '/recovery',
      notifications = '/notifications',
      profile = '/profile',
      support = '/support',
      sync = '/sync';
  static const fisher = '/fisher',
      processor = '/processor',
      transporter = '/transporter',
      retailer = '/retailer';
  static const fisherBoats = '$fisher/boats',
      fisherStartTrip = '$fisher/start-trip',
      fisherActiveTrip = '$fisher/active-trip',
      fisherAddCatch = '$fisher/add-catch',
      fisherCatchHistory = '$fisher/catch-history',
      fisherCreateBatch = '$fisher/create-batch',
      fisherBatchList = '$fisher/batch-list',
      fisherBatchDetails = '$fisher/batch-details';
  static const processorScanBatch = '$processor/scan-batch',
      processorIntake = '$processor/intake',
      processorProcessing = '$processor/processing',
      processorInspection = '$processor/inspection',
      processorSplitPack = '$processor/split-pack',
      processorProcessedDetails = '$processor/processed-details',
      processorHistory = '$processor/history';
  static const transporterTrips = '$transporter/trips',
      transporterTripDetails = '$transporter/trip-details',
      transporterAddBatch = '$transporter/add-batch',
      transporterDevices = '$transporter/devices',
      transporterVehicles = '$transporter/vehicles',
      transporterChecklist = '$transporter/checklist',
      transporterMonitoring = '$transporter/monitoring',
      transporterDelivery = '$transporter/delivery';
  static const transporterCreateTrip = '$transporter/create-trip',
      transporterEditTrip = '$transporter/edit-trip';
  static const retailerReceive = '$retailer/receive',
      retailerReceivedDetails = '$retailer/received-details',
      retailerInventory = '$retailer/inventory',
      retailerSales = '$retailer/sales',
      retailerAlerts = '$retailer/alerts',
      retailerReports = '$retailer/reports';
}

GoRouter buildRouter() => GoRouter(
  initialLocation: AppRoute.splash,
  redirect: (_, state) {
    final path = state.uri.path;
    final publicPaths = <String>{
      AppRoute.splash,
      AppRoute.onboarding,
      AppRoute.login,
      AppRoute.recovery,
    };
    final controller = Get.find<AppController>();
    final current = controller.user.value;
    final role = UserRole.values
        .where((r) => path == '/${r.name}' || path.startsWith('/${r.name}/'))
        .firstOrNull;
    if (role != null) {
      if (current == null) return AppRoute.login;
      if (current.role != role) return '/${current.role.name}';
    }
    if (current != null &&
        (path == AppRoute.splash ||
            path == AppRoute.login ||
            path == AppRoute.onboarding)) {
      return '/${current.role.name}';
    }
    if (current == null && !publicPaths.contains(path)) {
      return AppRoute.login;
    }
    return null;
  },
  routes: [
    GoRoute(path: AppRoute.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(
      path: AppRoute.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(path: AppRoute.login, builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: AppRoute.recovery,
      builder: (_, __) => const RecoveryScreen(),
    ),
    GoRoute(
      path: AppRoute.notifications,
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(path: AppRoute.profile, builder: (_, __) => const ProfileScreen()),
    GoRoute(
      path: AppRoute.support,
      builder: (_, __) => const HelpSupportScreen(),
    ),
    GoRoute(path: AppRoute.sync, builder: (_, __) => const OfflineSyncScreen()),
    ...workflowRoutes(UserRole.fisher, AppRoute.fisher),
    ...workflowRoutes(UserRole.processor, AppRoute.processor),
    ...workflowRoutes(UserRole.transporter, AppRoute.transporter),
    ...workflowRoutes(UserRole.retailer, AppRoute.retailer),
  ],
);

List<GoRoute> workflowRoutes(UserRole role, String root) {
  final slugs = switch (role) {
    UserRole.fisher => const [
      'boats',
      'start-trip',
      'active-trip',
      'add-catch',
      'catch-history',
      'create-batch',
      'batch-list',
      'batch-details',
    ],
    UserRole.processor => const [
      'scan-batch',
      'intake',
      'processing',
      'inspection',
      'split-pack',
      'processed-details',
      'history',
    ],
    UserRole.transporter => const [
      'trips',
      'trip-details',
      'add-batch',
      'devices',
      'vehicles',
      'checklist',
      'monitoring',
      'delivery',
      'create-trip',
      'edit-trip',
    ],
    UserRole.retailer => const [
      'receive',
      'received-details',
      'inventory',
      'sales',
      'alerts',
      'reports',
    ],
  };
  return [
    GoRoute(
      path: root,
      builder: (_, __) => role == UserRole.fisher
          ? const FisherDashboardScreen()
          : role == UserRole.processor
          ? const ProcessorDashboardScreen()
          : role == UserRole.transporter
          ? const TransporterDashboardScreen()
          : const RetailerDashboardScreen(),
      routes: [
        for (final slug in slugs)
          GoRoute(
            path: slug,
            builder: (_, __) => switch ((role, slug)) {
              (UserRole.fisher, 'boats') => const BoatManagementScreen(),
              (UserRole.fisher, 'start-trip') => const StartFishingTripScreen(),
              (UserRole.fisher, 'active-trip') =>
                const ActiveTripDetailsScreen(),
              (UserRole.fisher, 'add-catch') => const AddCatchScreen(),
              (UserRole.fisher, 'catch-history') => const CatchHistoryScreen(),
              (UserRole.fisher, 'create-batch') => const CreateBatchScreen(),
              (UserRole.fisher, 'batch-list') => const BatchListScreen(),
              (UserRole.fisher, 'batch-details') => BatchDetailsScreen(
                batchId: __.extra as String?,
              ),
              (UserRole.processor, 'scan-batch') => const ScanBatchScreen(),
              (UserRole.processor, 'intake') => const BatchIntakeScreen(),
              (UserRole.processor, 'processing') =>
                const ProcessingWorkflowScreen(),
              (UserRole.processor, 'inspection') =>
                const QualityInspectionScreen(),
              (UserRole.processor, 'split-pack') => const SplitPackScreen(),
              (UserRole.processor, 'processed-details') =>
                ProcessedBatchDetailsScreen(batchId: __.extra as String?),
              (UserRole.processor, 'history') =>
                const ProcessingHistoryScreen(),
              (UserRole.transporter, 'trips') => const TripsListScreen(),
              (UserRole.transporter, 'trip-details') =>
                const TripDetailsScreen(),
              (UserRole.transporter, 'add-batch') =>
                const TransportScanBatchScreen(),
              (UserRole.transporter, 'devices') =>
                const DeviceAssignmentScreen(),
              (UserRole.transporter, 'vehicles') =>
                const VehicleManagementScreen(),
              (UserRole.transporter, 'checklist') =>
                const PreTripChecklistScreen(),
              (UserRole.transporter, 'monitoring') =>
                const LiveMonitoringScreen(),
              (UserRole.transporter, 'delivery') =>
                const DeliveryConfirmationScreen(),
              (UserRole.transporter, 'create-trip') =>
                const TransportTripFormScreen(),
              (UserRole.transporter, 'edit-trip') =>
                const TransportTripFormScreen(editing: true),
              (UserRole.retailer, 'receive') => const ReceiveBatchScreen(),
              (UserRole.retailer, 'received-details') =>
                const ReceivedBatchDetailsScreen(),
              (UserRole.retailer, 'inventory') => const InventoryScreen(),
              (UserRole.retailer, 'sales') => const StockSalesScreen(),
              (UserRole.retailer, 'alerts') => const RetailAlertsScreen(),
              (UserRole.retailer, 'reports') => const SalesReportsScreen(),
              _ => throw StateError('Unregistered role route: $role/$slug'),
            },
          ),
      ],
    ),
  ];
}
