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
- [ ] **Diapositives & Punaises & Médias**
  - [ ] À implémenter ensuite.
