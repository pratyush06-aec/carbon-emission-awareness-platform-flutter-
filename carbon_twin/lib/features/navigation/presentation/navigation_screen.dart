import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/navigation_provider.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final _sourceController = TextEditingController();
  final _destController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _sourceController.dispose();
    _destController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);

    // If we have markers, adjust the map bounds to fit them
    ref.listen<NavigationState>(navigationProvider, (prev, next) {
      if (next.sourceMarker != null && next.destMarker != null && next.routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(next.routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(top: 200, bottom: 200, left: 50, right: 50),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map (OSM)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(28.6139, 77.2090), // Default to New Delhi
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.carbontwin.app',
              ),
              PolylineLayer(
                polylines: [
                  if (navState.routePoints.isNotEmpty)
                    Polyline(
                      points: navState.routePoints,
                      color: const Color(0xFF39D353),
                      strokeWidth: 5.0,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (navState.sourceMarker != null)
                    Marker(
                      point: navState.sourceMarker!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                    ),
                  if (navState.destMarker != null)
                    Marker(
                      point: navState.destMarker!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),

          // Search Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Carbon-Aware Navigation (OSM)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (navState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            navState.error!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      TextField(
                        controller: _sourceController,
                        decoration: const InputDecoration(
                          labelText: 'Source (e.g., London)',
                          prefixIcon: Icon(Icons.my_location),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _destController,
                        decoration: const InputDecoration(
                          labelText: 'Destination (e.g., Paris)',
                          prefixIcon: Icon(Icons.location_on),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: navState.isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  ref
                                      .read(navigationProvider.notifier)
                                      .calculateRoute(
                                        _sourceController.text,
                                        _destController.text,
                                      );
                                },
                          child: navState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Calculate Routes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Route Results Sheet
          if (navState.carbonMetrics != null)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.15,
              maxChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Fastest Route
                      _RouteCard(
                        title: 'Fastest (Car/Cab)',
                        mode: 'Driving',
                        distance: navState.distanceKm,
                        carbonKg: navState.carbonMetrics!['cab']!,
                        icon: Icons.directions_car,
                      ),
                      const SizedBox(height: 12),
                      // Greenest Route
                      _RouteCard(
                        title: 'Greenest Alternative',
                        mode: 'Metro / Public Transit',
                        distance: navState.distanceKm,
                        carbonKg: navState.carbonMetrics!['metro']!,
                        icon: Icons.train,
                        isGreen: true,
                      ),
                      const SizedBox(height: 12),
                      // Savings
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You save ${navState.carbonMetrics!['savings']!.toStringAsFixed(2)} kg CO₂',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  '📱 Charging ${(navState.carbonMetrics!['savings']! * 80).round()} smartphones'),
                              Text(
                                  '💡 Keeping a bulb on for ${(navState.carbonMetrics!['savings']! * 30).round()} hours'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String title;
  final String mode;
  final double distance;
  final double carbonKg;
  final IconData icon;
  final bool isGreen;

  const _RouteCard({
    required this.title,
    required this.mode,
    required this.distance,
    required this.carbonKg,
    required this.icon,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isGreen
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isGreen ? Colors.green.withOpacity(0.2) : null,
          child: Icon(icon, color: isGreen ? Colors.green : null),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$mode • ${distance.toStringAsFixed(1)} km'),
        trailing: Text(
          '${carbonKg.toStringAsFixed(2)} kg CO₂',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isGreen ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
