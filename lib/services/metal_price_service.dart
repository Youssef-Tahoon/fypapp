import 'dart:convert';
import 'package:http/http.dart' as http;

class MetalPrice {
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime lastUpdated;

  MetalPrice(
      {required this.goldPricePerGram,
      required this.silverPricePerGram,
      required this.lastUpdated});
}

class MetalPriceService {
  // Cache the prices
  static MetalPrice? _cachedPrices;
  static DateTime? _lastFetchTime;

  // Check if we should use cached data (cache valid for 1 hour)
  static bool get _shouldUseCachedData {
    if (_cachedPrices == null || _lastFetchTime == null) return false;
    final difference = DateTime.now().difference(_lastFetchTime!);
    return difference.inHours < 1;
  }

  // Fetch current metal prices
  static Future<MetalPrice> getMetalPrices() async {
    // Return cached prices if available and recent
    if (_shouldUseCachedData) {
      return _cachedPrices!;
    }

    try {
      // Using free Metals API
      final response =
          await http.get(Uri.parse('https://api.metals.live/v1/spot'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Find gold and silver in the response
        final goldData = data.firstWhere((item) => item.containsKey('gold'),
            orElse: () => {'gold': 0});
        final silverData = data.firstWhere((item) => item.containsKey('silver'),
            orElse: () => {'silver': 0});

        // Price is in USD per troy ounce, convert to MYR per gram
        // 1 troy ounce = 31.1035 grams
        // USD to MYR conversion rate (approx 4.7 - update as needed)
        const usdToMyr = 4.7;
        const troyOunceToGram = 31.1035;

        final goldPriceUsdPerOunce = goldData['gold'] ?? 0.0;
        final silverPriceUsdPerOunce = silverData['silver'] ?? 0.0;

        // Convert to MYR per gram
        final goldPricePerGram =
            (goldPriceUsdPerOunce / troyOunceToGram) * usdToMyr;
        final silverPricePerGram =
            (silverPriceUsdPerOunce / troyOunceToGram) * usdToMyr;

        // Cache the result
        _cachedPrices = MetalPrice(
            goldPricePerGram: goldPricePerGram,
            silverPricePerGram: silverPricePerGram,
            lastUpdated: DateTime.now());
        _lastFetchTime = DateTime.now();

        return _cachedPrices!;
      } else {
        throw Exception('Failed to load metal prices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching metal prices: $e');
      // Fall back to default values if the API call fails
      return MetalPrice(
          goldPricePerGram: 455.8, // Default values as fallback
          silverPricePerGram: 4.94,
          lastUpdated: DateTime.now());
    }
  }
}
