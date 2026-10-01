# État d'avancement du projet Photo Push

## Phase 0 — Socle hors ligne (Terminée)
- [x] Monorepo, squelette d'app, CI.
- [x] Modèles de base Serverpod (Album, Slide, Pin, Asset).
- [x] Base de données locale (SQLite via Serverpod ClientDatabaseSession).
- [x] Thème basique, i18n (français/anglais).
- [x] Drapeau de compilation PP_ONLINE géré pour le mode local-only.
- [x] Jalon : L'application démarre et affiche une liste d'albums vide depuis SQLite, 100% hors ligne.

## Phase 1 — Fonctionnel local (En cours)
- [x] **Écran 1 & 2 : Albums**
  - [x] Création (validation, unicité du nom, UUID interne).
  - [x] Renommage.
  - [x] Corbeille et restauration.
  - [ ] Calcul et affichage de la couverture (en attente des médias).
- [ ] **Écran 3, 4, 7 : Diapositives**
  - [x] Choix (photo/commentaire) et ajout.
  - [x] Éditeur de commentaire (écran 6 - saisie).
  - [ ] Éditeur photo (titre, ajout de punaises).
  - [ ] Visionneuse photo (zoom/pan, navigation flick/flèches, liens avec fil d'Ariane, masquage UI).
  - [ ] Suppression et réorganisation.
- [ ] **Écran 4 & 8 : Punaises**
  - [ ] À implémenter.
- [ ] **Transverse : Médias**
  - [ ] À implémenter.
