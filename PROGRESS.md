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
  - [x] Calcul et affichage de la couverture (en attente des médias).
- [x] **Écran 3, 4, 7 : Diapositives**
  - [x] Choix (photo/commentaire) et ajout.
  - [x] Éditeur de commentaire (écran 6 - saisie).
  - [x] Éditeur photo (titre, ajout initial de la diapo).
  - [x] Visionneuse photo (zoom/pan, navigation flick/flèches, masquage UI).
  - [x] Liens avec fil d'Ariane.
  - [ ] Suppression et réorganisation.
- [x] **Écran 4 & 8 : Punaises**
  - [x] Création au doigt, mode édition/lecture.
  - [x] Rendu normalisé indépendant de l'écran avec `InteractiveViewer`.
  - [x] Options étendues (Lien, Texte, Configuration).
- [x] **Transverse : Médias**
  - [x] Import depuis galerie/caméra, copie sandbox, hachage SHA-256, déduplication locale, cache LRU (vignettes de base).
  - [ ] Sauvegarde automatique.
  - [ ] Export / Import d'archive `.photopush`.