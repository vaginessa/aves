import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MetadataService {
  static const platform = const MethodChannel('deckers.thibault/aves/metadata');

  // return Map<Map<Key, Value>> (map of directories, each directory being a map of metadata label and value description)
  static Future<Map> getAllMetadata(ImageEntry entry) async {
    try {
      final result = await platform.invokeMethod('getAllMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'path': entry.path,
      });
      return result as Map;
    } on PlatformException catch (e) {
      debugPrint('getAllMetadata failed with exception=${e.message}');
    }
    return Map();
  }

  static Future<CatalogMetadata> getCatalogMetadata(ImageEntry entry) async {
    try {
      // return map with:
      // 'dateMillis': date taken in milliseconds since Epoch (long)
      // 'latitude': latitude (double)
      // 'longitude': longitude (double)
      // 'xmpSubjects': space separated XMP subjects (string)
      final result = await platform.invokeMethod('getCatalogMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'path': entry.path,
      }) as Map;
      result['contentId'] = entry.contentId;
      return CatalogMetadata.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getCatalogMetadata failed with exception=${e.message}');
    }
    return null;
  }

  static Future<OverlayMetadata> getOverlayMetadata(ImageEntry entry) async {
    try {
      // return map with string descriptions for: 'aperture' 'exposureTime' 'focalLength' 'iso'
      final result = await platform.invokeMethod('getOverlayMetadata', <String, dynamic>{
        'mimeType': entry.mimeType,
        'path': entry.path,
      }) as Map;
      return OverlayMetadata.fromMap(result);
    } on PlatformException catch (e) {
      debugPrint('getOverlayMetadata failed with exception=${e.message}');
    }
    return null;
  }
}