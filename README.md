# PhotoPush

Réécriture Flutter d'une application d'albums photo interactifs, légère et 100 % hors ligne, avec import/export manuel et synchronisation distante optionnelle.

## Documentation

- [Cahier des charges v1.1 (`doc/cdc2.typ`)](doc/cdc2.typ)
- [Spécifications fonctionnelles & Backlog Agile User Stories (`doc/USER_STORIES.md`)](doc/USER_STORIES.md)

## Développement

Le projet est configuré avec un environnement Nix (`flake.nix` et `direnv`) fournissant Flutter, Dart et le SDK Android.

```bash
# Vérification du code
flutter analyze

# Formatage
dart format .

# Tests unitaires et d'intégration
flutter test

# Lancer l'application
flutter run
```
