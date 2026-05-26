import 'dart:io';

/// Service for managing Windows startup (auto-start).
///
/// Uses the Windows Registry to add/remove the app
/// from the Run key at:
/// `HKEY_CURRENT_USER\Software\Microsoft\Windows\
///   CurrentVersion\Run`
class StartupService {
  static const _registryKey =
      r'HKEY_CURRENT_USER\Software\Microsoft\Windows'
      r'\CurrentVersion\Run';
  static const _valueName = 'BatteryChecker';

  /// Enables auto-start by adding a registry entry.
  static Future<bool> enableStartup() async {
    try {
      final exePath = Platform.resolvedExecutable;
      final result = await Process.run('reg', [
        'add',
        _registryKey,
        '/v',
        _valueName,
        '/t',
        'REG_SZ',
        '/d',
        '"$exePath" --minimized',
        '/f',
      ], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Disables auto-start by removing the registry entry.
  static Future<bool> disableStartup() async {
    try {
      final result = await Process.run('reg', [
        'delete',
        _registryKey,
        '/v',
        _valueName,
        '/f',
      ], runInShell: true);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Checks if auto-start is currently enabled.
  static Future<bool> isStartupEnabled() async {
    try {
      final result = await Process.run('reg', [
        'query',
        _registryKey,
        '/v',
        _valueName,
      ], runInShell: true);
      return result.exitCode == 0 &&
          result.stdout.toString().contains(_valueName);
    } catch (_) {
      return false;
    }
  }
}
