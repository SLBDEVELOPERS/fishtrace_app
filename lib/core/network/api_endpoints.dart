/// Single source of truth for the Laravel `/api/v1` contract.
///
/// Paths are relative to [AppConfig.apiBaseUrl]; no feature repository embeds a
/// host name or API version.
abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const me = '/auth/me';
  static const profile = '/auth/profile';
  static const logout = '/auth/logout';
  static const logoutAll = '/auth/logout-all';
  static const supportIssues = '/support/issues';
  static const forgotPassword = '/auth/forgot-password';
  static const verifyOtp = '/auth/verify-otp';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';
  static const firebaseSession = '/firebase/session';

  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const files = '/files';

  static const fisherDashboard = '/fisher/dashboard';
  static const fisherReferenceData = '/fisher/reference-data';
  static const boats = '/boats';
  static String boat(String id) => '/boats/$id';
  static const fishingTrips = '/fishing-trips';
  static String fishingTrip(String id) => '/fishing-trips/$id';
  static String fishingTripStart(String id) => '/fishing-trips/$id/start';
  static String fishingTripComplete(String id) => '/fishing-trips/$id/complete';
  static String fishingTripCancel(String id) => '/fishing-trips/$id/cancel';
  static const catches = '/catches';
  static String catchRecord(String id) => '/catches/$id';
  static const batches = '/batches';
  static String batch(String id) => '/batches/$id';
  static String batchQr(String id) => '/batches/$id/qr';
  static String batchTimeline(String id) => '/batches/$id/timeline';
  static String batchDocuments(String id) => '/batches/$id/documents';
  static String batchSplit(String id) => '/batches/$id/split';
  static String batchChildren(String id) => '/batches/$id/children';

  static const processorDashboard = '/processor/dashboard';
  static const processorReferenceData = '/processor/reference-data';
  static const processorIncomingBatches = '/processor/incoming-batches';
  static const processorResolveBatch = '/processor/resolve-batch';
  static const processorHistory = '/processor/history';
  static String processorBatch(String id) => '/processor/batches/$id';
  static String processorAccept(String id) => '/processor/batches/$id/accept';
  static String processorReject(String id) => '/processor/batches/$id/reject';
  static const processingRecords = '/processing-records';
  static String processingRecord(String id) => '/processing-records/$id';
  static String processingStepStart(String id, String step) =>
      '/processing-records/$id/steps/$step/start';
  static String processingStepComplete(String id, String step) =>
      '/processing-records/$id/steps/$step/complete';
  static const qualityInspections = '/quality-inspections';
  static String qualityInspection(String id) => '/quality-inspections/$id';

  static const transporterDashboard = '/transporter/dashboard';
  static const vehicles = '/vehicles';
  static String vehicle(String id) => '/vehicles/$id';
  static const transportTrips = '/transport-trips';
  static String transportTrip(String id) => '/transport-trips/$id';
  static String transportTripBatches(String id) =>
      '/transport-trips/$id/batches';
  static String transportTripBatch(String id, String batchId) =>
      '/transport-trips/$id/batches/$batchId';
  static String transportTripDevice(String id) => '/transport-trips/$id/device';
  static String transportTripChecklist(String id) =>
      '/transport-trips/$id/checklist';
  static String transportTripStart(String id) => '/transport-trips/$id/start';
  static String transportTripComplete(String id) =>
      '/transport-trips/$id/complete';
  static String transportTripCancel(String id) => '/transport-trips/$id/cancel';
  static String transportTripArrival(String id) =>
      '/transport-trips/$id/arrive';
  static String sensorReadings(String id) =>
      '/transport-trips/$id/sensor-readings';
  static String latestSensorReading(String id) =>
      '/transport-trips/$id/sensor-readings/latest';
  static String sensorSummary(String id) =>
      '/transport-trips/$id/sensor-summary';
  static String transportAlerts(String id) => '/transport-trips/$id/alerts';
  static String acknowledgeTransportAlert(String id) =>
      '/alerts/$id/acknowledge';
  static String transportTripIncident(String id) =>
      '/transport-trips/$id/incidents';
  static String liveAccess(String id) => '/transport-trips/$id/live-access';
  static String incidents(String id) => '/transport-trips/$id/incidents';
  static String deliveryConfirmation(String id) =>
      '/transport-trips/$id/delivery-confirmation';
  static const iotDevices = '/iot/devices';
  // Laravel exposes available traceable batches through the shared batch
  // directory; there is no separate handover-batches route.
  static const handoverBatches = '/transporter/available-batches';
  static const transporterResolveBatch = '/transporter/resolve-batch';

  static const retailerDashboard = '/retailer/dashboard';
  static const retailIncomingLabels = '/retail/incoming-labels';
  static const retailerResolveLabel = '/retailer/resolve-label';
  static const receipts = '/retailer/receipts';
  static String receipt(String id) => '/retailer/receipts/$id';
  static const inventory = '/retailer/inventory';
  static String inventoryItem(String id) => '/retailer/inventory/$id';
  static const stockAdjustments = '/retailer/stock-adjustments';
  static const sales = '/retailer/sales';
  static String sale(String id) => '/retailer/sales/$id';
  static const retailAlerts = '/retailer/alerts';
  static String quarantineRecall(String id) =>
      '/retailer/recalls/$id/quarantine';
  static String resolveRetailAlert(String id) => '/retailer/alerts/$id/resolve';
  static const reportSummary = '/retailer/reports/summary';
  static const reportSales = '/retailer/reports/sales';
  static const reportInventory = '/retailer/reports/inventory';
}
