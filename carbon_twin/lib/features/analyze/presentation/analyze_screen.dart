import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/analyze_provider.dart';

class AnalyzeScreen extends ConsumerWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyzeState = ref.watch(analyzeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Carbon Analyzer'),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, analyzeState),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, AnalyzeState analyzeState) {
    switch (analyzeState.status) {
      case 'uploading':
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Analyzing receipt with Gemini AI...'),
              SizedBox(height: 8),
              Text(
                'Calculating emissions for packaging, delivery, and food type...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );

      case 'done':
        return _buildResults(context, ref, analyzeState.results!);

      case 'error':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(analyzeState.error ?? 'An error occurred'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref.read(analyzeProvider.notifier).reset(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );

      default: // idle
        return _buildUploadArea(context, ref);
    }
  }

  Widget _buildUploadArea(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Food Delivery Screenshot',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your Swiggy/Zomato screenshot to estimate carbon footprint.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _pickImage(ref, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 16),
                FilledButton.tonalIcon(
                  onPressed: () => _pickImage(ref, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      ref.read(analyzeProvider.notifier).analyzeImage(image);
    }
  }

  Widget _buildResults(
      BuildContext context, WidgetRef ref, Map<String, dynamic> results) {
    final items = results['items'] as List<dynamic>? ?? [];
    final total = results['total'] ?? '0 kg CO₂';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Score Header
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Total Carbon Score',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '$total',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Items List
        ...items.map((item) {
          final name = item['name'] ?? 'Unknown';
          final packaging = item['packaging'] ?? '0 kg';
          final delivery = item['delivery'] ?? '0 kg';
          final food = item['food'] ?? '0 kg';
          final itemTotal = item['total'] ?? '0 kg';

          return Card(
            child: ExpansionTile(
              title: Text(name),
              trailing: Text(
                '$itemTotal',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _EmissionRow('📦 Packaging', '$packaging'),
                      _EmissionRow('🛵 Delivery', '$delivery'),
                      _EmissionRow('🥩 Food', '$food'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: () => ref.read(analyzeProvider.notifier).reset(),
          child: const Text('Upload Another'),
        ),
      ],
    );
  }
}

class _EmissionRow extends StatelessWidget {
  final String label;
  final String value;
  const _EmissionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
