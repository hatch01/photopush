# PhotoPush — Backlog Agile Utilisateur (User Stories Verticales)

Ce document rassemble les **User Stories utilisateur** du projet PhotoPush. Chaque US est découpée de façon **verticale** : chaque livraison produit un changement **directement visible, interactif et testable à l'écran par l'utilisateur**.

---

## Vue d'Ensemble du Backlog Utilisateur

| ID | Titre de la Fonctionnalité Visible | Rôle Principal | Priorité |
| :---: | :--- | :--- | :---: |
| **US-1** | **Écran d'Accueil & Gestion des Albums** (Liste, Création, Renommage, Duplication, Suppression) | Menus & Écrans | **P0** |
| **US-2** | **Ajout & Édition de Diapositives** (Photos Caméra/Galerie & Diapositives Commentaires) | Menus & Écrans | **P0** |
| **US-3** | **Éditeur de Punaises Interactives** (Pose sur photo, Bulles de texte, Liens, 6 Couleurs, Tailles) | Affichage | **P0** |
| **US-4** | **Visionneuse Interactive & Immersion** (Zoom 1x-6x, Pan, Navigation par glissement, Liens & Retour ↩, Plein écran) | Affichage | **P0** |
| **US-5** | **Réorganisation des Diapositives & Menu « Aller à… »** (Grille, Glisser-déposer, Navigation rapide) | Menus & Écrans | **P0** |
| **US-6** | **Gestionnaire de Fichiers & Nettoyage Disque** (Espace occupé, Visualisation des médias, Purge des orphelins) | Modèle & Fichiers | **P0** |
| **US-7** | **Import & Export d'Archives (`.photopush`)** (Partage système Drive/iCloud/OneDrive, Import avec gestion des collisions) | Modèle & Fichiers | **P0** |
| **US-8** | **Paramètres de l'Application & Thème Sombre** (Préférences punaises, Mode de stockage par défaut, Thème sombre/clair) | Menus & Écrans | **P0** |
| **US-9** | **Synchronisation Distante S3 (P1)** (Écran de synchro manuelle, Envoi/Récupération delta, Stockage sécurisé des clés) | Synchronisation / Accès distant | **P1** |

---

## Détail des User Stories

---

### US-1 : Écran d'Accueil & Gestion des Albums
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Bloquant)
- **Ce qui change à l'écran pour l'utilisateur :**
  L'écran d'accueil affiche la grille/liste réelle de ses albums photo avec leur imagette de couverture (`cover.jpg`), leur titre, le nombre de diapositives et la date de dernière mise à jour.
- **Fonctionnalités visibles :**
  1. **Affichage des albums :** Triés par ordre alphabétique insensible à la casse et aux accents.
  2. **Zéro-état :** Si aucun album n'existe, affichage d'un écran d'accueil accueillant avec le logo de l'application invitant à créer un premier album.
  3. **Création d'album :** Un bouton `+` ouvre une boîte de dialogue avec validation en direct du nom (1 à 80 caractères, refus des caractères interdits `/ \ : * ? " < > |`, vérification d'unicité insensible à la casse). Dès validation, l'album apparaît dans la liste.
  4. **Menu d'actions sur chaque album (appui long ou bouton `⋮`) :**
     - **Renommer :** Boîte de dialogue pour changer le nom.
     - **Dupliquer :** Crée immédiatement une copie complète avec suffixe `(copie)` et ses images.
     - **Supprimer :** Boîte de dialogue de confirmation rouge avant suppression physique définitive.
  5. **Résilience visuelle :** Si un album sur le disque est corrompu ou illisible, il est signalé par un badge visuel d'avertissement sans faire planter l'application ni bloquer les autres albums.

---

### US-2 : Ajout & Édition de Diapositives (Photos & Commentaires)
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Bloquant)
- **Ce qui change à l'écran pour l'utilisateur :**
  Dans un album, l'utilisateur peut enrichir son contenu en ajoutant de nouvelles diapositives photo ou texte.
- **Fonctionnalités visibles :**
  1. **Bouton « Ajouter une diapositive » avec choix :**
     - *Prendre une photo :* Ouvre la caméra du téléphone.
     - *Choisir dans la galerie :* Ouvre le sélecteur de photos.
     - *Ajouter un commentaire :* Crée une diapositive textuelle seule.
  2. **Titre de diapositive :** Champ de saisie modifiable en haut de chaque diapositive (jusqu'à 40 caractères max).
  3. **Gestion des photos :** Prise en compte du choix de stockage (copie dans l'application avec redimensionnement automatique fluide $\le 2048$ px ou lien direct galerie).
  4. **Diapositives Commentaires :** Écran de lecture et d'édition textuelle dédié avec centrage vertical soigné et avertissement/compteur dès que le texte dépasse 350 caractères.
  5. **Bascule photo/commentaire :** Si une diapositive possède à la fois une photo et un texte, bascule fluide en un clic entre les deux vues.

---

### US-3 : Éditeur de Punaises Interactives sur Photo
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Ce qui change à l'écran pour l'utilisateur :**
  En mode édition sur une photo, toucher un endroit de l'image plante une punaise visuelle personnalisable.
- **Fonctionnalités visibles :**
  1. **Pose au doigt :** Un appui sur l'image positionne immédiatement une nouvelle punaise exactement sous le doigt.
  2. **Panneau de configuration de la punaise :**
     - **Couleur :** Choix parmi les 6 teintes officielles (Noir, Blanc, Vert, Jaune, Bleu, Violet).
     - **Taille :** Réglage du curseur de taille (1.0x à 3.0x par pas de 0.5).
     - **Texte :** Saisie d'une bulle descriptive multi-lignes (jusqu'à 400 caractères avec compteur).
     - **Lien de saut :** Interrupteur on/off avec sélecteur déroulant de la diapositive cible vers laquelle la punaise doit renvoyer.
     - **Supprimer :** Bouton pour enlever la punaise.
  3. **Précision multi-écrans :** Les punaises restent ancrées au millimètre sur le détail de l'image, même si l'utilisateur pivote l'écran ou change d'appareil.

---

### US-4 : Visionneuse Interactive & Mode Immersion
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Ce qui change à l'écran pour l'utilisateur :**
  Expérience de consultation plein écran fluide et interactive des albums.
- **Fonctionnalités visibles :**
  1. **Zoom et Déplacement :** Pincement pour zoomer de 1x à 6x centré sur le point de contact, double-tap pour zoomer/dézoomer rapidement, panoramique à 60 fps.
  2. **Navigation au balayage (Swipe/Flick) :** Glissement horizontal pour changer de diapositive avec bouclage infini.
  3. **Flèches discrètes :** Flèches de navigation temporaires sur les bords qui s'effacent après 1 seconde d'inactivité.
  4. **Interaction avec les punaises :** Toucher une punaise ouvre sa bulle textuelle ; toucher une punaise avec lien navigue instantanément vers la diapositive cible.
  5. **Historique et retour `↩` :** Un bouton retour s'affiche à l'écran dès qu'un lien a été emprunté pour revenir en arrière dans le fil de visite.
  6. **Mode Immersion :** Toucher la photo masque l'ensemble des barres d'outils et de menus pour une consultation plein écran épurée.
  7. **Masquage des punaises :** Bouton pour cacher ou réafficher d'un coup toutes les punaises.
  8. **Tolérance aux photos manquantes :** Si une photo liée à la galerie a disparu, affichage d'un visuel élégant « Image not found » avec bouton de réassociation pour rétablir l'image sans perdre les punaises existantes.

---

### US-5 : Réorganisation & Navigation Rapide (« Aller à… »)
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Confort)
- **Ce qui change à l'écran pour l'utilisateur :**
  Possibilité de réordonner l'album et de sauter directement à n'importe quelle diapositive.
- **Fonctionnalités visibles :**
  1. **Écran de réorganisation :** Vue en grille des miniatures de toutes les diapositives.
  2. **Réordonnancement :** Support du glisser-déposer tactile direct et du mode « sélectionner puis toucher la cible ».
  3. **Suppression de diapositive :** Confirmation avec alerte si des punaises pointaient vers cette diapositive.
  4. **Menu « Aller à… » :** Feuille modale listant toutes les diapositives avec leurs titres pour sauter directement à la photo désirée.

---

### US-6 : Gestionnaire de Fichiers & Nettoyage
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Robustesse)
- **Ce qui change à l'écran pour l'utilisateur :**
  Écran dédié permettant de contrôler le stockage de chaque album et de purger les fichiers inutiles.
- **Fonctionnalités visibles :**
  1. **Visualisation du stockage :** Liste des albums avec l'espace disque consommé en Mo / Ko.
  2. **Contenu détaillé :** Exploration du dossier d'un album (`album.json`, imagette de couverture, liste des photos présentes avec leur poids).
  3. **Suppression ciblée d'images :** Bouton pour supprimer individuellement une photo du dossier.
  4. **Bouton « Nettoyer » :** Analyse l'album et affiche un récapitulatif avant action (images orphelines non référencées, fichiers temporaires, liens brisés) avec estimation de l'espace libéré, et nettoyage après confirmation.

---

### US-7 : Import & Export d'Archives (`.photopush`)
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Partage)
- **Ce qui change à l'écran pour l'utilisateur :**
  Partage autonome de ses albums avec ses proches ou entre ses appareils sans avoir besoin de compte.
- **Fonctionnalités visibles :**
  1. **Action « Exporter l'album » :** Génère un fichier archive `.photopush` (contenant `album.json` et toutes les images rapatriées) et ouvre la feuille de partage du téléphone (AirDrop, Drive, OneDrive, WhatsApp, Email, etc.).
  2. **Action « Importer un album » :** Ouvre le sélecteur de fichiers du téléphone pour choisir une archive `.photopush`.
  3. **Gestion des collisions de nom :** Si l'album existe déjà, boîte de dialogue proposant de le **Renommer**, de le **Remplacer** (avec avertissement) ou d'**Annuler**.
  4. **Protection :** Si le fichier est corrompu ou invalide, un message d'erreur clair informe l'utilisateur sans altérer ses albums existants.

---

### US-8 : Paramètres de l'Application & Personnalisation
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Préférences)
- **Ce qui change à l'écran pour l'utilisateur :**
  Écran de réglages pour personnaliser l'application selon ses goûts.
- **Fonctionnalités visibles :**
  1. **Préférences des punaises :** Définition de la couleur favorite et de la taille par défaut pour les nouvelles punaises.
  2. **Mode de stockage par défaut des photos :** Choix entre « Copier dans l'application » ou « Lien galerie ».
  3. **Sauvegarde automatique :** Interrupteur pour activer/désactiver la sauvegarde automatique (avec temporisation de 1,5 s d'inactivité) ou préférer une sauvegarde manuelle par bouton.
  4. **Thème visuel :** Thème sombre par défaut (mis en avant pour une application photo), avec option thème clair ou suivi automatique du système.
  5. **Langue :** Anglais par défaut, avec option Français (interface entièrement bilingue).

---

### US-9 (Extension P1) : Synchronisation Distante S3
- **Rôle :** Synchronisation & Accès distant
- **Priorité :** P1 (Optionnel)
- **Ce qui change à l'écran pour l'utilisateur :**
  Écran de synchronisation manuelle pour échanger un album de référence avec un serveur compatible S3 ou MinIO.
- **Fonctionnalités visibles :**
  1. **Configuration du stockage distant :** Formulaire de saisie du serveur S3 (Endpoint, Bucket, Région, Access Key, Secret Key) sécurisé dans le trousseau de l'appareil.
  2. **Écran de synchronisation :** Liste des albums distants avec boutons **« Envoyer (Push) »** et **« Récupérer (Pull) »**.
  3. **Synchronisation intelligente (Delta) :** Barre de progression transférant uniquement les photos manquantes ou modifiées (gain de temps et de données mobiles).
  4. **Gestion des conflits :** Confirmation explicite avant d'écraser un album local avec option de copie de sauvegarde.
