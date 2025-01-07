import 'dart:math';

int calculateDistance(double lat1, double lon1, double lat2, double lon2, {bool inMiles = false}) {
  const int radiusOfEarthKm = 6371; // Radius of the Earth in kilometers
  const double radiusOfEarthMiles = 3958.8; // Radius of the Earth in miles

  // Convert latitude and longitude from degrees to radians
  double lat1Rad = lat1 * pi / 180;
  double lon1Rad = lon1 * pi / 180;
  double lat2Rad = lat2 * pi / 180;
  double lon2Rad = lon2 * pi / 180;

  // Haversine formula
  double dLat = lat2Rad - lat1Rad;
  double dLon = lon2Rad - lon1Rad;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = inMiles ? radiusOfEarthMiles * c : radiusOfEarthKm * c;

  // Return distance as an integer
  return distance.round();
}
