import 'package:flutter/material.dart';

enum AddSlideAction { camera, gallery, comment }

class AddSlideResult {
  const AddSlideResult({required this.action, required this.storeInApp});

  final AddSlideAction action;
  final bool storeInApp;
}

/// Modal bottom sheet allowing the user to select the type of slide to add.
class AddSlideBottomSheet extends StatefulWidget {
  const AddSlideBottomSheet({super.key, required this.defaultStoreInApp});

  final bool defaultStoreInApp;

  @override
  State<AddSlideBottomSheet> createState() => _AddSlideBottomSheetState();
}

class _AddSlideBottomSheetState extends State<AddSlideBottomSheet> {
  late bool _storeInApp;

  @override
  void initState() {
    super.initState();
    _storeInApp = widget.defaultStoreInApp;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Ajouter une diapositive',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.camera_alt_outlined),
              ),
              title: const Text('Prendre une photo'),
              subtitle: const Text(
                'Utiliser l\'appareil photo de votre téléphone',
              ),
              onTap: () {
                Navigator.of(context).pop(
                  AddSlideResult(
                    action: AddSlideAction.camera,
                    storeInApp: _storeInApp,
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.photo_library_outlined),
              ),
              title: const Text('Choisir dans la galerie'),
              subtitle: const Text('Sélectionner une photo existante'),
              onTap: () {
                Navigator.of(context).pop(
                  AddSlideResult(
                    action: AddSlideAction.gallery,
                    storeInApp: _storeInApp,
                  ),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.notes_outlined)),
              title: const Text('Ajouter un commentaire'),
              subtitle: const Text('Diapositive textuelle sans image'),
              onTap: () {
                Navigator.of(context).pop(
                  AddSlideResult(
                    action: AddSlideAction.comment,
                    storeInApp: _storeInApp,
                  ),
                );
              },
            ),
            const Divider(height: 24),
            SwitchListTile(
              value: _storeInApp,
              title: const Text('Copier l\'image dans l\'application'),
              subtitle: const Text(
                'Recommandé pour la portabilité et le mode hors-ligne (max 2048px)',
              ),
              onChanged: (val) => setState(() => _storeInApp = val),
            ),
          ],
        ),
      ),
    );
  }
}
