import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:i18next/i18next.dart';

class RemoteBundleDataSource implements LocalizationDataSource {
  RemoteBundleDataSource({
    required this.url,
    required this.fallback,
  }) : super();

  final String url;

  final AssetBundleLocalizationDataSource fallback;

  @override
  Future<Map<String, dynamic>> load(
    Locale locale, {
    String manifest = 'AssetManifest.json',
  }) async {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return fallback.load(
        locale,
        manifest: manifest,
      );
    }
    final response = await http.get(uri);
    if (response.statusCode <= 205 && response.statusCode >= 200) {
      return loadFromResponse(response.body as Map<String, dynamic>);
    }
    return fallback.load(
      locale,
      manifest: manifest,
    );
  }

  Map<String, dynamic> loadFromResponse(Map<String, dynamic> response) {
    final namespaces = HashMap<String, dynamic>();
    for (final entity in response.entries) {
      namespaces[entity.key] = jsonDecode(entity.value);
    }
    return namespaces;
  }
}
