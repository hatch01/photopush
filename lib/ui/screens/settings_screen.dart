import 'package:flutter/material.dart';

import '../../controllers/settings_controller.dart';
import '../../models/models.dart';

/// Screen for managing application-wide preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Theme
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Apparence',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Thème'),
                subtitle: const Text('Clair, Sombre ou Système'),
                trailing: DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Système'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Clair'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Sombre'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Storage
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Médias & Stockage',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Sauvegarde automatique'),
                subtitle: const Text(
                  'Enregistrer automatiquement après 1.5s d\'inactivité.',
                ),
                value: controller.autoSaveEnabled,
                onChanged: controller.updateAutoSaveEnabled,
              ),
              ListTile(
                title: const Text('Import des photos (défaut)'),
                subtitle: const Text('Stockage en interne ou simple lien.'),
                trailing: DropdownButton<ImageStorageType>(
                  value: controller.defaultImageStorage,
                  onChanged: controller.updateDefaultImageStorage,
                  items: const [
                    DropdownMenuItem(
                      value: ImageStorageType.internal,
                      child: Text('Copier (Interne)'),
                    ),
                    DropdownMenuItem(
                      value: ImageStorageType.gallery,
                      child: Text('Lien Galerie'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Pins defaults
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Punaises par défaut',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Couleur par défaut'),
                trailing: DropdownButton<PinColor>(
                  value: controller.defaultPinColor,
                  onChanged: controller.updateDefaultPinColor,
                  items: PinColor.values.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(color.colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(color.labelFr),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Taille par défaut'),
                trailing: DropdownButton<double>(
                  value: controller.defaultPinSize,
                  onChanged: controller.updateDefaultPinSize,
                  items: const [
                    DropdownMenuItem(value: 1.0, child: Text('x1.0')),
                    DropdownMenuItem(value: 1.5, child: Text('x1.5')),
                    DropdownMenuItem(value: 2.0, child: Text('x2.0')),
                    DropdownMenuItem(value: 2.5, child: Text('x2.5')),
                    DropdownMenuItem(value: 3.0, child: Text('x3.0')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
