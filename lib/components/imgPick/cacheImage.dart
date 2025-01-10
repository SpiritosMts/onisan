import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onisan/assetManager/assetManager.dart';
import 'package:onisan/components/cacheManager/cacheManager.dart';
import 'package:onisan/components/imgPick/shimmer.dart';
import 'package:onisan/components/imgPick/svgImg.dart';

class ContentTypeCache {
  static final Map<String, String> _cache = {};

  // Normalize the URL by removing query parameters
  static String _normalizeUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.replace(query: '').toString(); // Remove query parameters
  }
  static String? get(String url) => _cache[url];

  static void set(String url, String contentType) {
    _cache[url] = contentType;
  }

  static bool contains(String url) => _cache.containsKey(url);

  static void clear() {
    _cache.clear();
    print("## imagesCache cleared.");

  } // Optional: Clear cache if needed
  static Future<void> fetchAndCacheContentType(String url) async {
   // if (url.isEmpty || !(Uri.tryParse(url)?.hasAbsolutePath ?? false)) {
    if (url.isEmpty ) {
      set(url, 'unknown');
      return;
    }
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode != 200) {
        set(url, 'error');
        return;
      }
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('svg')) {
        set(url, 'svg');
      } else if (contentType.startsWith('image/')) {
        set(url, 'raster');
      } else {
        set(url, 'unknown');
      }
    } catch (e) {
      print("## Error fetching Content-Type: $e");
      set(url, 'error');
    }
  }
  // Function to print all cache entries
  static void printAll() {
    if (_cache.isEmpty) {
      print("## imagesCache is empty.");
    } else {
      _cache.forEach((url, contentType) {
        print("## URL: <$url> , Content-Type: $contentType");
      });
    }
  }
}

// Placeholder Logo
Widget blankLogo(size) {
  return Image.asset(
    AssetsManager.blankImagePath!,
    width: size,
    height: size,
    fit: BoxFit.cover,
  );
}

// Error Logo
Widget errLogo(size) {
  return Image.asset(
    AssetsManager.errImagePath!,
    width: size,
    height: size,
    fit: BoxFit.cover,
  );
}

class CacheImage extends StatefulWidget {
  final String logoUrl;
  final double? logoSize;

  const CacheImage({Key? key, required this.logoUrl, this.logoSize}) : super(key: key);

  @override
  _CacheImageState createState() => _CacheImageState();
}

class _CacheImageState extends State<CacheImage> {
  late final double size;
  late Future<String> contentValidationFuture;

  @override
  void initState() {
    super.initState();
    size = widget.logoSize ?? 100.0;
    // Fetch the content type using the global cache
    contentValidationFuture = _fetchContentType(widget.logoUrl);
  }



  // Fetch content type and use the global cache
  Future<String> _fetchContentType(String url) async {
    if (url=="" ) {
   // if (url=="" ||  !(Uri.tryParse(widget.logoUrl)?.hasAbsolutePath ?? false)) {
      ContentTypeCache.set(url, 'unknown');

      return 'unknown';

    }
    if (ContentTypeCache.contains(url)) {
      print("##(CacheImage) Using cached content type for: $url => ${ContentTypeCache.get(url)}");
      return ContentTypeCache.get(url)!;
    }
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode != 200) {
        print("##(CacheImage) Error: Failed to fetch content type. Status code: ${response.statusCode},/// $url => ${ContentTypeCache.get(url)}");
        ContentTypeCache.set(url, 'error');
        return 'error';
      }

      final contentType = response.headers['content-type'] ?? '';
      final responseBody = response.body;

      if (contentType.contains('svg') ) {
      //if (contentType.contains('svg')) {
        ContentTypeCache.set(url, 'svg');
        return 'svg';
      } else if (contentType.startsWith('image/')) {
        ContentTypeCache.set(url, 'raster');
        return 'raster';
      } else {
        ContentTypeCache.set(url, 'unknown');
        return 'unknown';
      }
    } catch (e) {
      print("##(CacheImage) Error fetching Content-Type: $e");
      ContentTypeCache.set(url, 'error');
      return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      key: ValueKey(widget.logoUrl), // Use logoUrl as the key
      future: contentValidationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return shimmerPlaceholder(size); // Shimmer during loading
        }

        if (snapshot.hasData) {
          final type = snapshot.data ?? 'unknown';

          switch (type) {
            case 'svg':
              return ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CustomSvg(
                  url: widget.logoUrl,
                  width: size,
                  height: size,
                  fadeInDuration: const Duration(milliseconds: 0),
                  fadeOutDuration: const Duration(milliseconds: 200),
                  placeholder: shimmerPlaceholder(size),
                ),
              );
            case 'raster':
              return ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: CachedNetworkImage(
                  imageUrl: widget.logoUrl,
                  cacheManager: MyCustomCacheManager(),
                  httpHeaders: const {'Accept': 'image/*'},
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 0),
                  fadeOutDuration: const Duration(milliseconds: 200),
                  placeholder: (context, url) => shimmerPlaceholder(size),
                  errorWidget: (context, url, error) => errLogo(size),
                ),
              );
            case 'error':
              return errLogo(size);
            default:
              return blankLogo(size);
          }
        } else {
          return errLogo(size);
        }
      },
    );
  }
}
