import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

// Very basic state management for the default pin settings.
// In a full implementation, this should be persisted using SharedPreferences or similar (RF-104).
class PinSettings {
  final String color;
  final double sizeScale;

  const PinSettings({this.color = 'black', this.sizeScale = 1.0});

  PinSettings copyWith({String? color, double? sizeScale}) {
    return PinSettings(
      color: color ?? this.color,
      sizeScale: sizeScale ?? this.sizeScale,
    );
  }
}

class PinSettingsNotifier extends Notifier<PinSettings> {
  @override
  PinSettings build() => const PinSettings();

  void updateColor(String color) {
    state = state.copyWith(color: color);
  }

  void updateSizeScale(double sizeScale) {
    state = state.copyWith(sizeScale: sizeScale);
  }
}

final pinSettingsProvider = NotifierProvider<PinSettingsNotifier, PinSettings>(
  PinSettingsNotifier.new,
);

class PinSettingsScreen extends ConsumerWidget {
  const PinSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(pinSettingsProvider);

    final colors = [
      ('black', Colors.black),
      ('white', Colors.white),
      ('green', Colors.green),
      ('yellow', Colors.yellow),
      ('blue', Colors.blue),
      ('purple', Colors.purple),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pinSettingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: colors.map((c) {
                final isSelected = settings.color == c.$1;
                return GestureDetector(
                  onTap: () {
                    ref.read(pinSettingsProvider.notifier).updateColor(c.$1);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.$2,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Size (${settings.sizeScale.toStringAsFixed(1)})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: settings.sizeScale,
              min: 1.0,
              max: 3.0,
              divisions: 4, // 1.0, 1.5, 2.0, 2.5, 3.0
              label: settings.sizeScale.toStringAsFixed(1),
              onChanged: (value) {
                ref.read(pinSettingsProvider.notifier).updateSizeScale(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
