enum MeasurementSystem { metric, imperial }

enum MobileLanguage { english, sinhala, tamil }

class MobileSettings {
  const MobileSettings({
    this.compactDashboard = false,
    this.useDeviceTheme = true,
    this.measurementSystem = MeasurementSystem.metric,
    this.language = MobileLanguage.english,
    this.temperatureAlerts = true,
    this.workflowUpdates = true,
    this.systemMessages = true,
  });

  final bool compactDashboard;
  final bool useDeviceTheme;
  final MeasurementSystem measurementSystem;
  final MobileLanguage language;
  final bool temperatureAlerts;
  final bool workflowUpdates;
  final bool systemMessages;

  MobileSettings copyWith({
    bool? compactDashboard,
    bool? useDeviceTheme,
    MeasurementSystem? measurementSystem,
    MobileLanguage? language,
    bool? temperatureAlerts,
    bool? workflowUpdates,
    bool? systemMessages,
  }) => MobileSettings(
    compactDashboard: compactDashboard ?? this.compactDashboard,
    useDeviceTheme: useDeviceTheme ?? this.useDeviceTheme,
    measurementSystem: measurementSystem ?? this.measurementSystem,
    language: language ?? this.language,
    temperatureAlerts: temperatureAlerts ?? this.temperatureAlerts,
    workflowUpdates: workflowUpdates ?? this.workflowUpdates,
    systemMessages: systemMessages ?? this.systemMessages,
  );

  String get measurementLabel => switch (measurementSystem) {
    MeasurementSystem.metric => 'Metric',
    MeasurementSystem.imperial => 'Imperial',
  };

  String get languageLabel => switch (language) {
    MobileLanguage.english => 'English',
    MobileLanguage.sinhala => 'සිංහල',
    MobileLanguage.tamil => 'தமிழ்',
  };
}
