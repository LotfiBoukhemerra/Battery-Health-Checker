import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Holds information about the latest available release
/// fetched from the GitHub Releases API.
class UpdateInfo {
  /// The version tag (e.g. "1.2.0").
  final String latestVersion;

  /// Direct URL to the GitHub release page.
  final String releaseUrl;

  /// Release notes / changelog body (markdown).
  final String releaseNotes;

  /// Whether the latest version is newer than
  /// the currently installed version.
  final bool isUpdateAvailable;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseUrl,
    required this.releaseNotes,
    required this.isUpdateAvailable,
  });
}

/// Service responsible for checking whether a newer
/// version of the app is available on GitHub.
///
/// Queries the GitHub Releases API for the latest
/// release and compares its `tag_name` against the
/// current [AppConstants.appVersion].
class UpdateService {
  static const String _apiUrl =
      'https://api.github.com/repos/'
      'LotfiBoukhemerra/Battery-Health-Checker/'
      'releases/latest';

  /// Checks for the latest release on GitHub.
  ///
  /// Returns an [UpdateInfo] with the result, or `null`
  /// if the network request fails or the response cannot
  /// be parsed.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;

      final tagName = data['tag_name'] as String? ?? '';
      final htmlUrl = data['html_url'] as String? ?? '';
      final body = data['body'] as String? ?? '';

      // Strip leading 'v' if present (e.g. "v1.2.0" → "1.2.0")
      final latestVersion = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      final isNewer = _isNewerVersion(latestVersion, AppConstants.appVersion);

      return UpdateInfo(
        latestVersion: latestVersion,
        releaseUrl: htmlUrl,
        releaseNotes: body,
        isUpdateAvailable: isNewer,
      );
    } catch (_) {
      return null;
    }
  }

  /// Compares two semantic version strings.
  ///
  /// Returns `true` if [latest] is strictly newer than
  /// [current]. Supports standard major.minor.patch format.
  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final l = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}
