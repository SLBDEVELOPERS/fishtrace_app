enum MeasurementSystem { metric, imperial }

enum MobileLanguage { english, sinhala, tamil }

enum AppThemeMode { system, light, dark }

class MobileSettings {
  const MobileSettings({
    this.compactDashboard = false,
    AppThemeMode? themeMode,
    @Deprecated('Use themeMode instead') bool? useDeviceTheme,
    this.measurementSystem = MeasurementSystem.metric,
    this.language = MobileLanguage.english,
    this.temperatureAlerts = true,
    this.workflowUpdates = true,
    this.systemMessages = true,
  }) : themeMode =
           themeMode ??
           (useDeviceTheme == false ? AppThemeMode.light : AppThemeMode.system);

  final bool compactDashboard;
  final AppThemeMode themeMode;
  bool get useDeviceTheme => themeMode == AppThemeMode.system;
  final MeasurementSystem measurementSystem;
  final MobileLanguage language;
  final bool temperatureAlerts;
  final bool workflowUpdates;
  final bool systemMessages;

  MobileSettings copyWith({
    bool? compactDashboard,
    AppThemeMode? themeMode,
    @Deprecated('Use themeMode instead') bool? useDeviceTheme,
    MeasurementSystem? measurementSystem,
    MobileLanguage? language,
    bool? temperatureAlerts,
    bool? workflowUpdates,
    bool? systemMessages,
  }) => MobileSettings(
    compactDashboard: compactDashboard ?? this.compactDashboard,
    themeMode:
        themeMode ??
        (useDeviceTheme == null
            ? this.themeMode
            : (useDeviceTheme ? AppThemeMode.system : AppThemeMode.light)),
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

  String get themeLabel => switch (themeMode) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };
}
