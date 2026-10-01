# Photo Push — Guide & Checklist de test des fonctionnalités

Ce document recense l'ensemble des fonctionnalités actuellement implémentées dans l'application locale (Phase 0 et Phase 1), ainsi que la procédure pas-à-pas pour les tester sur votre machine ou émulateur.

---

## 📱 1. Format & Ergonomie Smartphone
- [ ] **Taille de fenêtre par défaut (Linux desktop)** : Au lancement, l'application s'ouvre dans un format vertical adapté aux téléphones (412 × 892 px) pour tester l'ergonomie mobile directement sous Linux.
- [ ] **Mode sombre & clair** : L'application s'adapte au thème de votre système d'exploitation.

---

## 🗂 2. Gestion des Albums (Écran 1 & 2)

### Création d'album
- [ ] **État vide initial** : Si aucun album n'existe, le message d'accueil d'origine s'affiche au centre.
- [ ] **Bouton `+`** : Un appui ouvre la modale de saisie du nom de l'album.
- [ ] **Validation du nom** :
  - Un nom vide affiche une erreur (*Le nom ne peut pas être vide*).
  - Les caractères interdits (`/ \ : * ? " < > |`) sont rejetés avec un message explicite.
  - La longueur maximale est limitée à 80 caractères.
  - Deux albums ne peuvent pas porter le même nom (insensible à la casse).
- [ ] **Ouverture automatique** : Une fois créé, l'album s'ouvre directement dans la visionneuse.

### Menu contextuel des albums
- [ ] **Renommer** : Via le menu contextuel (bouton `...` à droite de chaque album), vous pouvez modifier le nom avec les mêmes règles de validation.
- [ ] **Dupliquer** : Duplique l'album dans la liste avec la mention `(Copy)`.
- [ ] **Mettre à la corbeille** : Supprime doucement l'album (soft delete), il disparaît de la liste principale.

### Corbeille & Restauration
- [ ] **Accès à la corbeille** : En haut à droite de l'écran des albums, le menu `...` donne accès à la **Corbeille**.
- [ ] **Restauration** : La corbeille liste les albums supprimés ; un clic sur **Restaurer** remet l'album dans la liste principale.

---

## 🖼 3. Diapositives (Slides) & Visionneuse (Écran 3, 5, 6 & 7)

### Ajout d'une diapositive (Bouton `+`)
- [ ] **Choix du type** : Le bouton `+` dans la visionneuse ouvre une feuille avec 2 choix : **Photo** et **Commentaire**.
- [ ] **Ajout d'un commentaire** :
  - Ouvre l'éditeur plein écran (`CommentEditorScreen`).
  - Saisie d'un titre optionnel (max 40 caractères) et d'un texte de commentaire (max 400 caractères).
  - Enregistrement via le bouton disquette en haut à droite.
- [ ] **Ajout d'une photo** :
  - Ouvre le sélecteur de fichier/galerie.
  - L'image sélectionnée est copiée dans le sandbox local de l'application (`media/`) et hashée en SHA-256 (déduplication automatique).
  - La première photo ajoutée devient automatiquement l'image de couverture de l'album sur la page d'accueil.

### Visionneuse plein écran
- [ ] **Navigation par balayage ("Flick")** : Faites glisser horizontalement (swipe gauche / droite) pour naviguer de diapositive en diapositive.
- [ ] **Zoom & Déplacement (Pan)** : Sur une photo, vous pouvez zoomer (pincer-pour-zoomer ou molette) de 1× à 6× et déplacer l'image à deux doigts.
- [ ] **Mode immersif** : Tapoter sur l'image ou sur le texte d'un commentaire masque la barre supérieure pour une vue 100 % plein écran. Un nouveau tap la réaffiche.
- [ ] **Affichage propre des commentaires** : Le texte des commentaires commence proprement en dessous de la barre supérieure (aucun chevauchement).

---

## 📍 4. Éditeur de photo & Punaises (Pins) (Écran 4 & 8)

### Bascule en mode édition
- [ ] **Bouton Crayon (FAB)** : En bas à droite de la visionneuse photo, appuyez sur le bouton rond avec l'icône de crayon pour passer en **Mode Édition** (le bouton devient rouge avec une croix).

### Pose et déplacement des punaises
- [ ] **Tapoter pour poser** : En mode édition, tapotez n'importe où sur la photo. Une punaise carrée apparaît à l'emplacement exact de votre doigt.
- [ ] **Suivi du zoom/pan** : Zoomez et déplacez l'image : les punaises restent fidèlement ancrées à leurs coordonnées sur la photo sans décalage.
- [ ] **Plafond de punaises** : Impossible de poser plus de 30 punaises par diapositive.

### Menu d'action de la punaise
- [ ] **Appui sur une punaise (en mode édition)** : Ouvre un menu avec 3 options :
  - **Ajouter / Modifier le texte** : Saisie d'un texte de bulle (max 400 caractères).
  - **Ajouter / Modifier le lien** : Ouvre la liste des autres diapositives de l'album pour créer un lien de navigation.
  - **Supprimer** : Supprime la punaise.
- [ ] **Changement visuel d'icône** : La punaise adapte son icône selon son rôle (carré neutre, icône note pour texte, maillon pour lien, double-maillon pour texte + lien).

### Réglages des punaises
- [ ] **Accès aux réglages** : Dans le menu `...` en haut à droite -> **Réglages des punaises**.
- [ ] **Couleur** : Choisissez parmi 6 couleurs (Noir, Blanc, Vert, Jaune, Bleu, Violet).
- [ ] **Taille** : Ajustez le curseur de 1.0 à 3.0.
- [ ] **Application** : Les prochaines punaises créées prendront immédiatement la couleur et la taille choisies.

### Mode lecture des punaises
- [ ] **Repasser en mode lecture** (bouton rouge en bas à droite).
- [ ] **Punaise avec texte** : Tapoter sur la punaise ouvre la bulle contextuelle avec le texte.
- [ ] **Punaise avec lien** : Tapoter sur la punaise (ou sur le bouton dans sa bulle) navigue directement vers la diapositive cible.
- [ ] **Fil d'Ariane / Retour** : La flèche de retour système ou la barre supérieure vous ramène à la diapositive de départ.

---

## 🔀 5. Réorganisation et suppression des diapositives (Écran 9)

- [ ] **Accès** : Dans la visionneuse, menu `...` -> **Réorganiser l'album**.
- [ ] **Vue d'ensemble** : Toutes les diapositives sont listées avec leur numéro d'ordre (1, 2, ...), miniature/icône, titre et décompte des punaises.
- [ ] **Glisser-déposer** : Restez appuyé sur une ligne ou utilisez la poignée à droite pour réorganiser l'ordre des diapositives.
- [ ] **Suppression d'une diapositive** : L'icône de corbeille rouge demande confirmation avant de supprimer la diapositive.
- [ ] **Couverture automatique** : Si vous placez une autre photo en première position ou si vous supprimez la première photo, la couverture de l'album est automatiquement mise à jour sur la page d'accueil.

---

## 📦 7. Export & Import d'archive `.photopush` (Portabilité)
- [ ] **Exporter un album** :
  - Sur la liste des albums, ouvrez le menu contextuel `...` d'un album et choisissez **Exporter l'album (.photopush)**.
  - Sur desktop : choisissez le dossier d'enregistrement du fichier `.photopush`.
  - Sur mobile : la feuille de partage système s'ouvre pour envoyer ou enregistrer le fichier.
  - Le fichier créé est une archive ZIP contenant `album.json` (métadonnées, slides, punaises avec coordonnées) et `media/*` (photos d'origine).
- [ ] **Importer un album** :
  - Dans le menu supérieur `...` de la liste des albums, choisissez **Importer un album (.photopush)**.
  - Sélectionnez un fichier `.photopush` précédemment exporté.
  - L'album, ses diapositives, ses photos (extraites dans le sandbox) et ses punaises sont entièrement recréés dans votre base locale.
  - Si un album du même nom existe déjà, un suffixe numérique est automatiquement ajouté (ex: `Voyage (1)`).

---

## 💾 8. Données & Mode Hors Ligne
- [ ] **100 % local** : L'ensemble de ces fonctionnalités fonctionne sans compte utilisateur, sans connexion internet et sans serveur distant démarré (base SQLite `photopush.db` locale gérée par Serverpod).
- [ ] **Persistance** : Quittez et relancez l'application : l'ensemble des albums, photos, commentaires et punaises sont conservés intacts.
