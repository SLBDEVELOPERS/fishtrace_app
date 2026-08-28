import 'package:fishtrace/core/models/models.dart';
import 'package:fishtrace/features/authentication/presentation/screens/login_screen.dart';
import 'package:fishtrace/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:fishtrace/features/authentication/presentation/screens/recovery_screen.dart';
import 'package:fishtrace/features/authentication/presentation/screens/splash_screen.dart';
import 'package:fishtrace/features/common/presentation/screens/help_support_screen.dart';
import 'package:fishtrace/features/common/presentation/screens/notifications_screen.dart';
import 'package:fishtrace/features/common/presentation/screens/offline_sync_screen.dart';
import 'package:fishtrace/features/common/presentation/screens/profile_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/active_trip_details_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/add_catch_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/batch_details_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/boat_management_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/catch_history_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/create_batch_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/fisher_dashboard_screen.dart';
import 'package:fishtrace/features/fisher/presentation/screens/start_fishing_trip_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/batch_intake_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/processed_batch_details_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/processing_history_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/processing_workflow_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/processor_dashboard_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/quality_inspection_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/scan_batch_screen.dart';
import 'package:fishtrace/features/processor/presentation/screens/split_pack_screen.dart';
import 'package:fishtrace/features/retailer/presentation/screens/inventory_screen.dart';
import 'package:fishtrace/features/retailer/presentation/screens/receive_batch_screens.dart';
import 'package:fishtrace/features/retailer/presentation/screens/retail_alerts_screen.dart';
import 'package:fishtrace/features/retailer/presentation/screens/retailer_dashboard_screen.dart';
import 'package:fishtrace/features/retailer/presentation/screens/sales_reports_screen.dart';
import 'package:fishtrace/features/retailer/presentation/screens/stock_sales_screen.dart';
import 'package:fishtrace/features/transporter/presentation/screens/batch_device_vehicle_screens.dart';
import 'package:fishtrace/features/transporter/presentation/screens/checklist_monitoring_delivery_screens.dart';
import 'package:fishtrace/features/transporter/presentation/screens/transporter_dashboard_screen.dart';
import 'package:fishtrace/features/transporter/presentation/screens/trips_screens.dart';
import 'package:flutter/widgets.dart';

typedef AuditScreen = ({
  String name,
  UserRole? role,
  Widget Function() builder,
});

final auditScreens = <AuditScreen>[
  (name: '01_splash', role: null, builder: SplashScreen.new),
  (name: '02_onboarding', role: null, builder: OnboardingScreen.new),
  (name: '03_login', role: null, builder: LoginScreen.new),
  (name: '04_password_recovery', role: null, builder: RecoveryScreen.new),
  (
    name: '05_notifications',
    role: UserRole.fisher,
    builder: NotificationsScreen.new,
  ),
  (
    name: '06_profile_settings',
    role: UserRole.fisher,
    builder: ProfileScreen.new,
  ),
  (
    name: '07_help_support',
    role: UserRole.fisher,
    builder: HelpSupportScreen.new,
  ),
  (
    name: '08_offline_sync',
    role: UserRole.fisher,
    builder: OfflineSyncScreen.new,
  ),
  (
    name: 'fisher_dashboard',
    role: UserRole.fisher,
    builder: FisherDashboardScreen.new,
  ),
  (
    name: 'fisher_boats',
    role: UserRole.fisher,
    builder: BoatManagementScreen.new,
  ),
  (
    name: 'fisher_start_trip',
    role: UserRole.fisher,
    builder: StartFishingTripScreen.new,
  ),
  (
    name: 'fisher_active_trip',
    role: UserRole.fisher,
    builder: () => ActiveTripDetailsScreen(now: _auditNow),
  ),
  (
    name: 'fisher_add_catch',
    role: UserRole.fisher,
    builder: () => AddCatchScreen(now: _auditNow),
  ),
  (
    name: 'fisher_catch_history',
    role: UserRole.fisher,
    builder: CatchHistoryScreen.new,
  ),
  (
    name: 'fisher_create_batch',
    role: UserRole.fisher,
    builder: () => CreateBatchScreen(now: _auditNow),
  ),
  (
    name: 'fisher_batch_details',
    role: UserRole.fisher,
    builder: BatchDetailsScreen.new,
  ),
  (
    name: 'processor_dashboard',
    role: UserRole.processor,
    builder: ProcessorDashboardScreen.new,
  ),
  (
    name: 'processor_scan_batch',
    role: UserRole.processor,
    builder: ScanBatchScreen.new,
  ),
  (
    name: 'processor_intake',
    role: UserRole.processor,
    builder: BatchIntakeScreen.new,
  ),
  (
    name: 'processor_processing',
    role: UserRole.processor,
    builder: ProcessingWorkflowScreen.new,
  ),
  (
    name: 'processor_inspection',
    role: UserRole.processor,
    builder: QualityInspectionScreen.new,
  ),
  (
    name: 'processor_split_pack',
    role: UserRole.processor,
    builder: SplitPackScreen.new,
  ),
  (
    name: 'processor_processed_details',
    role: UserRole.processor,
    builder: ProcessedBatchDetailsScreen.new,
  ),
  (
    name: 'processor_history',
    role: UserRole.processor,
    builder: ProcessingHistoryScreen.new,
  ),
  (
    name: 'transporter_dashboard',
    role: UserRole.transporter,
    builder: TransporterDashboardScreen.new,
  ),
  (
    name: 'transporter_trips',
    role: UserRole.transporter,
    builder: TripsListScreen.new,
  ),
  (
    name: 'transporter_trip_details',
    role: UserRole.transporter,
    builder: TripDetailsScreen.new,
  ),
  (
    name: 'transporter_add_batch',
    role: UserRole.transporter,
    builder: TransportScanBatchScreen.new,
  ),
  (
    name: 'transporter_devices',
    role: UserRole.transporter,
    builder: DeviceAssignmentScreen.new,
  ),
  (
    name: 'transporter_vehicles',
    role: UserRole.transporter,
    builder: VehicleManagementScreen.new,
  ),
  (
    name: 'transporter_checklist',
    role: UserRole.transporter,
    builder: PreTripChecklistScreen.new,
  ),
  (
    name: 'transporter_monitoring',
    role: UserRole.transporter,
    builder: LiveMonitoringScreen.new,
  ),
  (
    name: 'transporter_delivery',
    role: UserRole.transporter,
    builder: DeliveryConfirmationScreen.new,
  ),
  (
    name: 'retailer_dashboard',
    role: UserRole.retailer,
    builder: RetailerDashboardScreen.new,
  ),
  (
    name: 'retailer_receive',
    role: UserRole.retailer,
    builder: ReceiveBatchScreen.new,
  ),
  (
    name: 'retailer_received_details',
    role: UserRole.retailer,
    builder: ReceivedBatchDetailsScreen.new,
  ),
  (
    name: 'retailer_inventory',
    role: UserRole.retailer,
    builder: InventoryScreen.new,
  ),
  (
    name: 'retailer_sales',
    role: UserRole.retailer,
    builder: StockSalesScreen.new,
  ),
  (
    name: 'retailer_alerts',
    role: UserRole.retailer,
    builder: RetailAlertsScreen.new,
  ),
  (
    name: 'retailer_reports',
    role: UserRole.retailer,
    builder: SalesReportsScreen.new,
  ),
];

DateTime _auditNow() => DateTime(2026, 8, 23, 12, 0);
