import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class NavigationState {
  final bool isLoading;
  final String? error;
  final double distanceKm;
  final Map<String, double>? carbonMetrics;
  final List<LatLng> routePoints;
  final LatLng? sourceMarker;
  final LatLng? destMarker;
  final String? sourceName;
  final String? destName;

  NavigationState({
    this.isLoading = false,
    this.error,
    this.distanceKm = 0,
    this.carbonMetrics,
    this.routePoints = const [],
    this.sourceMarker,
    this.destMarker,
    this.sourceName,
    this.destName,
  });

  NavigationState copyWith({
    bool? isLoading,
    String? error,
    double? distanceKm,
    Map<String, double>? carbonMetrics,
    List<LatLng>? routePoints,
    LatLng? sourceMarker,
    LatLng? destMarker,
    String? sourceName,
    String? destName,
  }) {
    return NavigationState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullify error if not explicitly passed
      distanceKm: distanceKm ?? this.distanceKm,
      carbonMetrics: carbonMetrics ?? this.carbonMetrics,
      routePoints: routePoints ?? this.routePoints,
      sourceMarker: sourceMarker ?? this.sourceMarker,
      destMarker: destMarker ?? this.destMarker,
      sourceName: sourceName ?? this.sourceName,
      destName: destName ?? this.destName,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  final Dio _dio = Dio();

  NavigationNotifier() : super(NavigationState());

  Future<void> calculateRoute(String sourceQuery, String destQuery) async {
    if (sourceQuery.isEmpty || destQuery.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Geocoding (Nominatim API - Free & Open Source)
      final sourceLatLng = await _geocode(sourceQuery);
      final destLatLng = await _geocode(destQuery);

      if (sourceLatLng == null || destLatLng == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not find one or both locations.',
        );
        return;
      }

      // 2. Routing (OSRM Public API - Free & Open Source)
      // OSRM coordinates are in longitude,latitude format
      final url =
          'https://router.project-osrm.org/route/v1/driving/${sourceLatLng.longitude},${sourceLatLng.latitude};${destLatLng.longitude},${destLatLng.latitude}?overview=full&geometries=geojson';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['code'] == 'Ok') {
        final route = response.data['routes'][0];
        final double distKm = route['distance'] / 1000.0;
        
        // Extract geometry
        final coordinates = route['geometry']['coordinates'] as List<dynamic>;
        final List<LatLng> points = coordinates.map((coord) {
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();

        // Carbon calculations (ported from our Next.js logic)
        final cabCarbon = distKm * 0.21;
        final metroCarbon = distKm * 0.03;
        final savings = cabCarbon - metroCarbon;

        state = state.copyWith(
          isLoading: false,
          distanceKm: distKm,
          carbonMetrics: {
            'cab': cabCarbon,
            'metro': metroCarbon,
            'savings': savings,
          },
          routePoints: points,
          sourceMarker: sourceLatLng,
          destMarker: destLatLng,
          sourceName: sourceQuery,
          destName: destQuery,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not calculate a route between these locations.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error while fetching route data.',
      );
    }
  }

  Future<LatLng?> _geocode(String query) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {
            // Nominatim requires a User-Agent
            'User-Agent': 'CarbonTwin/1.0',
          },
        ),
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final result = response.data[0];
        return LatLng(
          double.parse(result['lat']),
          double.parse(result['lon']),
        );
      }
    } catch (e) {
      // Ignored, will return null
    }
    return null;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
