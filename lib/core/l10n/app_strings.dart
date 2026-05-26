import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Lightweight localization system supporting EN, AR, ES.
///
/// Uses a simple map-based approach instead of the
/// heavyweight `easy_localization` package.
class AppStrings {
  AppStrings._();

  static Locale _currentLocale = const Locale('en');

  static Locale get currentLocale => _currentLocale;

  static bool get isRtl => _currentLocale.languageCode == 'ar';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('es'),
  ];

  static const Map<String, String> localeNames = {
    'en': 'English',
    'ar': 'العربية',
    'es': 'Español',
  };

  static late SharedPreferences _prefs;

  /// Loads saved locale from preferences.
  ///
  /// Accepts an optional [prefs] instance to avoid
  /// opening SharedPreferences a second time when one
  /// is already available in [main].
  static Future<void> init([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    final code = _prefs.getString(AppConstants.localeKey) ?? 'en';
    _currentLocale = Locale(code);
  }

  /// Changes and persists the locale.
  static Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await _prefs.setString(AppConstants.localeKey, locale.languageCode);
  }

  /// Gets a translated string by key.
  static String tr(String key) {
    final lang = _currentLocale.languageCode;
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// Gets a translated string with parameter
  /// substitution. Replaces `{param}` with value.
  static String trWithParam(String key, String param, String value) {
    return tr(key).replaceAll('{$param}', value);
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': _en,
    'ar': _ar,
    'es': _es,
  };

  static const Map<String, String> _en = {
    'app_name': 'Battery Checker',
    'battery': 'Battery',
    'alerts': 'Alerts',
    'settings': 'Settings',

    // Battery screen
    'battery_power': 'Battery Power',
    'charging': 'Charging',
    'discharging': 'Not Charging',
    'full': 'Fully Charged',
    'not_charging': 'Not Charging',
    'unknown': 'Unknown',

    // Health section
    'battery_health': 'Battery Health',
    'battery_details': 'Battery Details',
    'current_status': 'Current Status',
    'design_capacity': 'Design Capacity',
    'full_charge_capacity': 'Full Charge Capacity',
    'battery_name': 'Name',
    'manufacturer': 'Manufacturer',
    'serial_number': 'Serial Number',
    'chemistry': 'Chemistry',
    'cycle_count': 'Cycle Count',
    'charge_level': 'Charge Level',
    'charging_status': 'Charging Status',
    'health': 'Health',
    'refresh': 'Refresh',
    'battery_report_info': 'Health data from Windows battery report',

    // Alert screen
    'smart_alerts': 'Smart Alerts',
    'low_battery_alert': 'Low Battery Alert',
    'low_battery_desc': 'Notify when charge drops to {value}%',
    'full_charge_alert': 'Full Charge Alert',
    'full_charge_desc': 'Notify when charge reaches {value}%',
    'alert_info':
        'Keeping your battery between 20% and 80% '
        'helps extend battery lifespan.',
    'low_threshold': 'Low',
    'high_threshold': 'Full',
    'system_tray': 'System Tray',
    'minimize_to_tray': 'Minimize to Tray',
    'minimize_to_tray_desc': 'Hide to system tray when closing',
    'start_with_windows': 'Start with Windows',
    'start_with_windows_desc': 'Launch automatically on startup',

    // Settings screen
    'general': 'General',
    'change_language': 'Language',
    'appearance': 'Appearance',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'theme_system': 'System',
    'support': 'Support & Help',
    'visit_website': 'Visit Website',
    'donate': 'Support us',
    'legal': 'Legal',
    'privacy_policy': 'Privacy Policy',
    'about': 'About',
    'version': 'Version {version}',
    'developed_by': 'Developed by',
    'developer_name': '<e/dev> | @lotfi_bkmr',

    // Errors
    'error_title': 'Something went wrong',
    'error_battery': 'Could not retrieve battery information',
    'error_no_battery': 'No battery detected',
    'error_no_battery_desc':
        'This device does not appear to have a battery.\n'
        'Battery Checker requires a laptop battery to '
        'function.',
    'error_virtual_battery': 'Virtual Environment Detected',
    'error_virtual_battery_desc':
        'This device is running inside a virtual machine '
        '(e.g. Hyper-V, VMware).\n'
        'Accurate battery information is not available '
        'in virtual environments.',
    'error_report_failed': 'Failed to generate battery report',
    'retry': 'Retry',
    'check_again': 'Check Again',
    'exit_app': 'Exit App',

    // Notifications
    'low_battery_notification_title': 'Low Battery Warning',
    'low_battery_notification_body':
        'Battery is at {level}%. Please connect your '
        'charger.',
    'full_charge_notification_title': 'Battery Fully Charged',
    'full_charge_notification_body':
        'Battery is at {level}%. You can disconnect your '
        'charger.',

    // Tray
    'tray_show': 'Show',
    'tray_check': 'Check Battery',
    'tray_exit': 'Exit',

    // Health status
    'health_excellent': 'Battery is in excellent condition',
    'health_good': 'Battery is performing well',
    'health_moderate': 'Battery health is moderate',
    'health_warning': 'Battery replacement may be needed soon',
    'health_critical': 'Battery replacement recommended',

    // Updates
    'check_for_updates': 'Check for Updates',
    'update_available': 'Update Available',
    'update_new_version': 'Version {version} is ready to download',
    'update_download': 'Download',
    'update_up_to_date': 'You\'re up to date!',
    'update_up_to_date_desc': 'You are running the latest version.',
    'update_error': 'Could not check for updates',
    'update_error_desc':
        'Please check your internet connection '
        'and try again.',
    'update_checking': 'Checking for updates...',
  };

  static const Map<String, String> _ar = {
    'app_name': 'فاحص البطارية',
    'battery': 'البطارية',
    'alerts': 'التنبيهات',
    'settings': 'الإعدادات',

    'battery_power': 'طاقة البطارية',
    'charging': 'يتم الشحن',
    'discharging': 'لا يتم الشحن',
    'full': 'مشحونة بالكامل',
    'not_charging': 'لا يتم الشحن',
    'unknown': 'غير معروف',

    'battery_health': 'صحة البطارية',
    'battery_details': 'تفاصيل البطارية',
    'current_status': 'الحالة الحالية',
    'design_capacity': 'السعة التصميمية',
    'full_charge_capacity': 'سعة الشحن الكامل',
    'battery_name': 'الاسم',
    'manufacturer': 'الشركة المصنعة',
    'serial_number': 'الرقم التسلسلي',
    'chemistry': 'نوع الكيمياء',
    'cycle_count': 'عدد الدورات',
    'charge_level': 'مستوى الشحن',
    'charging_status': 'حالة الشحن',
    'health': 'الصحة',
    'refresh': 'تحديث',
    'battery_report_info': 'بيانات الصحة من تقرير بطارية ويندوز',

    'smart_alerts': 'التنبيهات الذكية',
    'low_battery_alert': 'تنبيه البطارية المنخفضة',
    'low_battery_desc': 'إشعار عندما ينخفض الشحن إلى {value}%',
    'full_charge_alert': 'تنبيه الشحن الكامل',
    'full_charge_desc': 'إشعار عندما يصل الشحن إلى {value}%',
    'alert_info':
        'الحفاظ على البطارية بين 20% و80% يساعد على '
        'إطالة عمر البطارية.',
    'low_threshold': 'منخفض',
    'high_threshold': 'كامل',
    'system_tray': 'علبة النظام',
    'minimize_to_tray': 'تصغير إلى العلبة',
    'minimize_to_tray_desc': 'إخفاء إلى علبة النظام عند الإغلاق',
    'start_with_windows': 'البدء مع ويندوز',
    'start_with_windows_desc': 'تشغيل تلقائي عند بدء التشغيل',

    'general': 'عام',
    'change_language': 'اللغة',
    'appearance': 'المظهر',
    'theme_light': 'فاتح',
    'theme_dark': 'داكن',
    'theme_system': 'النظام',
    'support': 'المساعدة والدعم',
    'visit_website': 'زيارة الموقع',
    'donate': 'ادعمنا',
    'legal': 'قانوني',
    'privacy_policy': 'سياسة الخصوصية',
    'about': 'حول',
    'version': 'الإصدار {version}',
    'developed_by': 'تطوير بواسطة',
    'developer_name': '<e/dev> | @lotfi_bkmr',

    'error_title': 'حدث خطأ ما',
    'error_battery': 'تعذر الحصول على معلومات البطارية',
    'error_no_battery': 'لم يتم اكتشاف بطارية',
    'error_no_battery_desc':
        'يبدو أن هذا الجهاز لا يحتوي على بطارية.\n'
        'يتطلب فاحص البطارية بطارية لابتوب للعمل.',
    'error_virtual_battery': 'تم اكتشاف بيئة افتراضية',
    'error_virtual_battery_desc':
        'هذا الجهاز يعمل داخل بيئة افتراضية '
        '(مثل Hyper-V أو VMware).\n'
        'لا يمكن الوصول إلى معلومات البطارية الصحيحة '
        'في البيئات الافتراضية.',
    'error_report_failed': 'فشل في إنشاء تقرير البطارية',
    'retry': 'إعادة المحاولة',
    'check_again': 'تحقق مجدداً',
    'exit_app': 'إغلاق التطبيق',

    'low_battery_notification_title': 'تحذير بطارية منخفضة',
    'low_battery_notification_body':
        'البطارية عند {level}%. يرجى توصيل الشاحن.',
    'full_charge_notification_title': 'البطارية مشحونة بالكامل',
    'full_charge_notification_body': 'البطارية عند {level}%. يمكنك فصل الشاحن.',

    'tray_show': 'إظهار',
    'tray_check': 'فحص البطارية',
    'tray_exit': 'خروج',

    // Health status
    'health_excellent': 'البطارية في حالة ممتازة',
    'health_good': 'البطارية تعمل بشكل جيد',
    'health_moderate': 'صحة البطارية متوسطة',
    'health_warning': 'قد تحتاج البطارية للاستبدال قريباً',
    'health_critical': 'يُنصح باستبدال البطارية',

    // Updates
    'check_for_updates': 'التحقق من التحديثات',
    'update_available': 'يوجد تحديث جديد',
    'update_new_version': 'الإصدار {version} جاهز للتحميل',
    'update_download': 'تحميل',
    'update_up_to_date': 'التطبيق محدّث!',
    'update_up_to_date_desc': 'أنت تستخدم أحدث إصدار من التطبيق.',
    'update_error': 'تعذر التحقق من التحديثات',
    'update_error_desc': 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
    'update_checking': 'جارٍ التحقق من التحديثات...',
  };

  static const Map<String, String> _es = {
    'app_name': 'Battery Checker',
    'battery': 'Batería',
    'alerts': 'Alertas',
    'settings': 'Configuración',

    'battery_power': 'Energía de la Batería',
    'charging': 'Cargando',
    'discharging': 'Sin Cargar',
    'full': 'Completamente Cargada',
    'not_charging': 'Sin Cargar',
    'unknown': 'Desconocido',

    'battery_health': 'Salud de la Batería',
    'battery_details': 'Detalles de la Batería',
    'current_status': 'Estado Actual',
    'design_capacity': 'Capacidad de Diseño',
    'full_charge_capacity': 'Capacidad de Carga Completa',
    'battery_name': 'Nombre',
    'manufacturer': 'Fabricante',
    'serial_number': 'Número de Serie',
    'chemistry': 'Química',
    'cycle_count': 'Ciclos de Carga',
    'charge_level': 'Nivel de Carga',
    'charging_status': 'Estado de Carga',
    'health': 'Salud',
    'refresh': 'Actualizar',
    'battery_report_info':
        'Datos de salud del informe de batería '
        'de Windows',

    'smart_alerts': 'Alertas Inteligentes',
    'low_battery_alert': 'Alerta de Batería Baja',
    'low_battery_desc': 'Notificar cuando la carga baje a {value}%',
    'full_charge_alert': 'Alerta de Carga Completa',
    'full_charge_desc': 'Notificar cuando la carga alcance {value}%',
    'alert_info':
        'Mantener la batería entre 20% y 80% ayuda a '
        'prolongar la vida útil.',
    'low_threshold': 'Bajo',
    'high_threshold': 'Lleno',
    'system_tray': 'Bandeja del Sistema',
    'minimize_to_tray': 'Minimizar a la Bandeja',
    'minimize_to_tray_desc': 'Ocultar a la bandeja al cerrar',
    'start_with_windows': 'Iniciar con Windows',
    'start_with_windows_desc': 'Iniciar automáticamente al encender',

    'general': 'General',
    'change_language': 'Idioma',
    'appearance': 'Apariencia',
    'theme_light': 'Claro',
    'theme_dark': 'Oscuro',
    'theme_system': 'Sistema',
    'support': 'Soporte y Ayuda',
    'visit_website': 'Visitar Sitio Web',
    'donate': 'Apóyanos',
    'legal': 'Legal',
    'privacy_policy': 'Política de Privacidad',
    'about': 'Acerca de',
    'version': 'Versión {version}',
    'developed_by': 'Desarrollado por',
    'developer_name': '<e/dev> | @lotfi_bkmr',

    'error_title': 'Algo salió mal',
    'error_battery': 'No se pudo obtener la información de la batería',
    'error_no_battery': 'No se detectó batería',
    'error_no_battery_desc':
        'Este dispositivo no parece tener batería.\n'
        'Battery Checker requiere una batería de '
        'portátil para funcionar.',
    'error_virtual_battery': 'Entorno Virtual Detectado',
    'error_virtual_battery_desc':
        'Este dispositivo se está ejecutando dentro de '
        'una máquina virtual (ej. Hyper-V, VMware).\n'
        'La información precisa de la batería no está '
        'disponible en entornos virtuales.',
    'error_report_failed': 'Error al generar el informe de batería',
    'retry': 'Reintentar',
    'check_again': 'Verificar de Nuevo',
    'exit_app': 'Cerrar Aplicación',

    'low_battery_notification_title': 'Advertencia de Batería Baja',
    'low_battery_notification_body':
        'La batería está al {level}%. Conecte su '
        'cargador.',
    'full_charge_notification_title': 'Batería Completamente Cargada',
    'full_charge_notification_body':
        'La batería está al {level}%. Puede desconectar '
        'su cargador.',

    'tray_show': 'Mostrar',
    'tray_check': 'Verificar Batería',
    'tray_exit': 'Salir',

    // Health status
    'health_excellent': 'La batería está en excelente estado',
    'health_good': 'La batería funciona bien',
    'health_moderate': 'La salud de la batería es moderada',
    'health_warning':
        'Es posible que sea necesario reemplazar '
        'la batería pronto',
    'health_critical': 'Se recomienda reemplazar la batería',

    // Updates
    'check_for_updates': 'Buscar Actualizaciones',
    'update_available': 'Actualización Disponible',
    'update_new_version': 'La versión {version} está lista para descargar',
    'update_download': 'Descargar',
    'update_up_to_date': '¡Estás actualizado!',
    'update_up_to_date_desc': 'Estás usando la última versión.',
    'update_error': 'No se pudo buscar actualizaciones',
    'update_error_desc':
        'Verifique su conexión a Internet e inténtelo de nuevo.',
    'update_checking': 'Buscando actualizaciones...',
  };
}
