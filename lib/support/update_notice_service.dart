import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateNoticeService {
  UpdateNoticeService({
    FirebaseFirestore? firestore,
    PackageInfoLoader? packageInfoLoader,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  final FirebaseFirestore _firestore;
  final PackageInfoLoader _packageInfoLoader;

  Future<UpdateStatus> loadStatus() async {
    final packageInfo = await _packageInfoLoader();
    final packageName = packageInfo.packageName;
    final currentVersionKey = _buildVersionKey(
      packageInfo.version,
      packageInfo.buildNumber,
    );

    final snapshot = await _firestore
        .collection('app_meta')
        .doc('mobile_update')
        .get();

    final data = snapshot.data();
    if (data == null) {
      return UpdateStatus(
        currentVersionKey: currentVersionKey,
        packageName: packageName,
        notices: const <UpdateNotice>[],
      );
    }

    final latestVersion = _readVersionKey(data, 'latestVersion');
    final minimumSupportedVersion = _readVersionKey(
      data,
      'minimumSupportedVersion',
    );
    final playStoreUrl =
        ((data['playStoreUrl'] as String?)?.trim().isNotEmpty ?? false)
        ? (data['playStoreUrl'] as String).trim()
        : null;
    final title = ((data['title'] as String?)?.trim().isNotEmpty ?? false)
        ? (data['title'] as String).trim()
        : 'A new version is available';
    final message = ((data['message'] as String?)?.trim().isNotEmpty ?? false)
        ? (data['message'] as String).trim()
        : 'Update HanBit from Google Play to get the latest fixes and features.';

    final notices = _parseNotices(
      raw: data['notifications'],
      fallbackTitle: title,
      fallbackMessage: message,
      fallbackVersion: latestVersion,
      fallbackPublishedAt: data['publishedAt'],
      fallbackForce:
          minimumSupportedVersion != null &&
          _compareVersions(currentVersionKey, minimumSupportedVersion) < 0,
    );

    final hasUpdate =
        latestVersion != null &&
        latestVersion.isNotEmpty &&
        _compareVersions(currentVersionKey, latestVersion) < 0;
    final requiresForceUpdate =
        minimumSupportedVersion != null &&
        minimumSupportedVersion.isNotEmpty &&
        _compareVersions(currentVersionKey, minimumSupportedVersion) < 0;

    return UpdateStatus(
      currentVersionKey: currentVersionKey,
      packageName: packageName,
      latestVersion: latestVersion,
      minimumSupportedVersion: minimumSupportedVersion,
      hasUpdate: hasUpdate,
      requiresForceUpdate: requiresForceUpdate,
      title: title,
      message: message,
      playStoreUrl: playStoreUrl,
      notices: notices,
    );
  }

  List<UpdateNotice> _parseNotices({
    required Object? raw,
    required String fallbackTitle,
    required String fallbackMessage,
    required String? fallbackVersion,
    required Object? fallbackPublishedAt,
    required bool fallbackForce,
  }) {
    if (raw is List) {
      final parsed =
          raw
              .whereType<Map>()
              .map(
                (item) => UpdateNotice.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort(
              (a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(
                a.publishedAt ?? DateTime(1970),
              ),
            );
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    if ((fallbackVersion ?? '').isEmpty &&
        fallbackTitle.isEmpty &&
        fallbackMessage.isEmpty) {
      return const <UpdateNotice>[];
    }

    return <UpdateNotice>[
      UpdateNotice(
        version: fallbackVersion,
        title: fallbackTitle,
        message: fallbackMessage,
        force: fallbackForce,
        publishedAt: _dateFromDynamic(fallbackPublishedAt),
      ),
    ];
  }
}

typedef PackageInfoLoader = Future<PackageInfo> Function();

class UpdateStatus {
  const UpdateStatus({
    required this.currentVersionKey,
    required this.packageName,
    required this.notices,
    this.latestVersion,
    this.minimumSupportedVersion,
    this.hasUpdate = false,
    this.requiresForceUpdate = false,
    this.title,
    this.message,
    this.playStoreUrl,
  });

  final String currentVersionKey;
  final String packageName;
  final String? latestVersion;
  final String? minimumSupportedVersion;
  final bool hasUpdate;
  final bool requiresForceUpdate;
  final String? title;
  final String? message;
  final String? playStoreUrl;
  final List<UpdateNotice> notices;

  String get effectivePlayStoreUrl => playStoreUrl?.trim().isNotEmpty == true
      ? playStoreUrl!.trim()
      : 'https://play.google.com/store/apps/details?id=$packageName';
}

class UpdateNotice {
  const UpdateNotice({
    required this.title,
    required this.message,
    this.version,
    this.force = false,
    this.publishedAt,
  });

  factory UpdateNotice.fromMap(Map<String, dynamic> map) {
    return UpdateNotice(
      version: (map['version'] as String?)?.trim(),
      title: ((map['title'] as String?)?.trim().isNotEmpty ?? false)
          ? (map['title'] as String).trim()
          : 'Update available',
      message: ((map['message'] as String?)?.trim().isNotEmpty ?? false)
          ? (map['message'] as String).trim()
          : 'A newer build is ready in Google Play.',
      force: map['force'] == true,
      publishedAt: _dateFromDynamic(map['publishedAt']),
    );
  }

  final String? version;
  final String title;
  final String message;
  final bool force;
  final DateTime? publishedAt;
}

DateTime? _dateFromDynamic(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

int _compareVersions(String left, String right) {
  final leftParts = _normalizeVersion(left);
  final rightParts = _normalizeVersion(right);
  final length = leftParts.length > rightParts.length
      ? leftParts.length
      : rightParts.length;

  for (var index = 0; index < length; index++) {
    final leftValue = index < leftParts.length ? leftParts[index] : 0;
    final rightValue = index < rightParts.length ? rightParts[index] : 0;
    if (leftValue != rightValue) {
      return leftValue.compareTo(rightValue);
    }
  }

  return 0;
}

String? _readVersionKey(Map<String, dynamic> data, String key) {
  final direct = (data[key] as String?)?.trim();
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }

  final name = (data['${key}Name'] as String?)?.trim();
  final buildNumber = (data['${key}BuildNumber'] as String?)?.trim();
  if ((name?.isNotEmpty ?? false) || (buildNumber?.isNotEmpty ?? false)) {
    return _buildVersionKey(name ?? '', buildNumber ?? '');
  }

  return null;
}

String _buildVersionKey(String version, String buildNumber) {
  final normalizedVersion = version.trim().isEmpty ? '0.0.0' : version.trim();
  final normalizedBuildNumber = buildNumber.trim();
  if (normalizedBuildNumber.isEmpty) {
    return normalizedVersion;
  }
  return '$normalizedVersion+$normalizedBuildNumber';
}

List<int> _normalizeVersion(String value) {
  final parts = value.split('+');
  final semanticVersion = parts.first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0);
  final buildNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return <int>[...semanticVersion, buildNumber];
}
