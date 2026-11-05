# PhotoPush — Spécifications Fonctionnelles & Backlog Agile (User Stories)

Ce document constitue le référentiel Agile complet pour le développement du projet **PhotoPush**. Il traduit le cahier des charges validé (`cdc2.typ`), les contraintes architecturales et les retours d'orientation du client / gestionnaire de projet (Thomas Gervaise).

---

## 1. Vision Produit & Principes Directeurs

PhotoPush est une réécriture moderne en **Flutter** d'une application initialement conçue pour Windows Phone 8.1 (Silverlight). L'application permet de créer, consulter et partager des albums photos interactifs enrichis de commentaires et de **punaises** (points d'intérêt cliquables affichant une bulle descriptive ou créant un lien de navigation vers une autre diapositive).

### 1.1 Principes Fondamentaux (Validés par le Client)
1. **100 % Hors-ligne par défaut (Offline-first) :** Le cœur de l'application (P0) fonctionne sans compte utilisateur, sans backend applicatif et sans connexion internet (compatible mode avion).
2. **L'unité, c'est l'album :** Pas de base de données relationnelle ni SQLite. Chaque album est matérialisé par un dossier du système de fichiers local comprenant un fichier `album.json` (source de vérité unique) et un dossier `images/`.
3. **Robustesse et intégrité :** Écritures atomiques (`.tmp` puis renommage atomique) pour empêcher toute corruption en cas d'interruption abrupte de l'application ; validation stricte au chargement avec tolérance aux pannes (un album corrompu ne bloque pas les autres) ; détection et nettoyage des fichiers et liens orphelins.
4. **Choix du stockage des photos :** L'utilisateur conserve le contrôle total :
   - *Lien direct avec la galerie* (zéro duplication d'espace, mais vulnérable à la suppression externe avec gestion d'un état « Image not found »).
   - *Copie dans l'application* (autonome, avec redimensionnement automatique à 2048 px maximum sur le bord le plus long).
5. **Simplicité et Ergonomie :**
   - Thème sombre mis en avant (adapté à une application photographique).
   - Coordonnées normalisées ($x, y \in [0.0, 1.0]$) pour garantir la portabilité des punaises quelle que soit la résolution ou l'orientation de l'écran.
   - Import/export manuel via une archive compressée autonome `.photopush`.
   - Sauvegarde automatique débouncée (ou désactivable) pour ménager les écritures disque.
6. **Extension Réseau (P1 - Optionnelle) :** Synchronisation manuelle d'un album de référence via un stockage compatible S3 / MinIO avec identifiants stockés dans le trousseau sécurisé de l'appareil.

---

## 2. Organisation de l'Équipe & Rôles

Conformément à la répartition validée dans le cahier des charges, chaque US est rattachée à l'un des 5 rôles :

| Rôle | Périmètre technique principal | Priorité |
| :--- | :--- | :---: |
| **Affichage** | Visionneuse, ergonomie des gestes (zoom, pan, flick), affichage et ancrage des punaises, mode immersion. | **P0** |
| **Menus & Écrans** | Navigation générale, écrans d'accueil/liste, ergonomie IHM, formulaires de création/réglages, onboarding. | **P0** |
| **Modèle & Fichiers** | Modèle JSON, persistance atomique sur disque, gestion des médias (redimensionnement, cache), écran de gestion des fichiers, import/export `.photopush`, nettoyage. | **P0** |
| **Synchronisation** | Écran de synchronisation manuelle, logique de comparaison delta (nom + taille), gestion des conflits locaux/distants. | **P1** |
| **Accès distant** | Connecteur S3 / MinIO, sécurisation des identifiants (Keystore/Keychain), validation et sécurité des flux réseau. | **P1** |

---

## 3. Architecture Technique des Données Locales

### 3.1 Structure du Système de Fichiers
```text
<app_documents_directory>/albums/
  ├── Mon Voyage/
  │   ├── album.json           # Modèle et métadonnées de l'album (source de vérité)
  │   ├── cover.jpg            # Imagette de couverture générée
  │   └── images/              # Photos stockées en local dans l'application
  │       ├── img_001.jpg
  │       └── img_002.jpg
  └── Anniversaire/
      ├── album.json
      └── cover.jpg
```

### 3.2 Modèle de Données `album.json` (Schéma Conceptuel)
```json
{
  "version": 1,
  "id": "uuid-v4",
  "name": "Mon Voyage",
  "createdAt": "2026-10-15T12:00:00.000Z",
  "updatedAt": "2026-10-15T14:30:00.000Z",
  "slides": [
    {
      "id": "slide-1",
      "type": "photo",
      "title": "Panorama Montagne",
      "image": {
        "storageType": "internal",
        "path": "images/img_001.jpg",
        "originalFileName": "PXL_20261015.jpg"
      },
      "comment": "Vue imprenable depuis le sommet.",
      "pins": [
        {
          "id": "pin-1",
          "x": 0.452,
          "y": 0.618,
          "size": 1.5,
          "color": "#FFCC00",
          "text": "Refuge du glacier où nous avons déjeuné",
          "targetSlideId": "slide-2"
        }
      ]
    },
    {
      "id": "slide-2",
      "type": "comment",
      "title": "Notes de séjour",
      "comment": "Randonnée difficile de 6 heures, météo parfaite.",
      "pins": []
    }
  ]
}
```

---

## 4. Matrice des User Stories

| ID | Épic | Titre | Rôle | Prio |
| :--- | :--- | :--- | :--- | :---: |
| **US-01** | Modèle & Fichiers | Définition des modèles de données et sérialisation JSON | Modèle & Fichiers | P0 |
| **US-02** | Modèle & Fichiers | Persistance atomique sur disque et lecture tolérante aux pannes | Modèle & Fichiers | P0 |
| **US-03** | Modèle & Fichiers | Traitement et redimensionnement des images locales (≤ 2048 px) | Modèle & Fichiers | P0 |
| **US-04** | Modèle & Fichiers | Gestion des photos liées à la galerie et gestion des orphelins | Modèle & Fichiers | P0 |
| **US-05** | Menus & Écrans | Liste des albums avec imagettes et groupement alphabétique | Menus & Écrans | P0 |
| **US-06** | Menus & Écrans | Création d'album avec validation stricte du nom | Menus & Écrans | P0 |
| **US-07** | Menus & Écrans | Renommage, duplication et suppression d'album | Menus & Écrans | P0 |
| **US-08** | Menus & Écrans | Écran d'accueil vide, onboarding et animation explicative | Menus & Écrans | P0 |
| **US-09** | Affichage | Visionneuse photo avec zoom et pan fluides (1x à 6x) | Affichage | P0 |
| **US-10** | Affichage | Navigation par glissement (flick) et flèches transitoires | Affichage | P0 |
| **US-11** | Affichage | Affichage des punaises ancrées et bulles de texte | Affichage | P0 |
| **US-12** | Affichage | Navigation via punaises de lien et pile de retour (↩) | Affichage | P0 |
| **US-13** | Affichage | Masquage des punaises et mode immersion | Affichage | P0 |
| **US-14** | Affichage | État « Image not found » et réassociation d'image | Affichage | P0 |
| **US-15** | Affichage | Éditeur photo : pose de punaise et positionnement normalisé | Affichage | P0 |
| **US-16** | Affichage | Éditeur photo : configuration de la punaise (texte, lien, style) | Affichage | P0 |
| **US-17** | Menus & Écrans | Ajout d'une diapositive (Photo ou Commentaire) | Menus & Écrans | P0 |
| **US-18** | Affichage | Visionneuse et éditeur dédié pour les diapositives de commentaire | Affichage | P0 |
| **US-19** | Menus & Écrans | Réorganisation des diapositives (Glisser-déposer / Cible) | Menus & Écrans | P0 |
| **US-20** | Menus & Écrans | Navigation directe « Aller à… » | Menus & Écrans | P0 |
| **US-21** | Modèle & Fichiers | Sauvegarde automatique paramétrable et sauvegarde manuelle | Modèle & Fichiers | P0 |
| **US-22** | Modèle & Fichiers | Écran de gestion des fichiers et espace de stockage | Modèle & Fichiers | P0 |
| **US-23** | Modèle & Fichiers | Diagnostic et nettoyage de l'album (fichiers et liens orphelins) | Modèle & Fichiers | P0 |
| **US-24** | Modèle & Fichiers | Export d'un album au format archive `.photopush` | Modèle & Fichiers | P0 |
| **US-25** | Modèle & Fichiers | Import d'une archive `.photopush` avec gestion des collisions | Modèle & Fichiers | P0 |
| **US-26** | Menus & Écrans | Paramètres généraux (préférences punaises, stockage par défaut) | Menus & Écrans | P0 |
| **US-27** | Menus & Écrans | Thème sombre par défaut et adaptation de l'interface | Menus & Écrans | P0 |
| **US-28** | Menus & Écrans | Internationalisation (Anglais / Français) et Accessibilité | Menus & Écrans | P0 |
| **US-29** | Synchronisation | Écran de synchronisation manuelle et comparaison delta (P1) | Synchronisation | P1 |
| **US-30** | Accès distant | Connecteur distant S3/MinIO et stockage sécurisé des clés (P1) | Accès distant | P1 |

---

## 5. Spécification Détaillée des User Stories

---

### Epic 1 : Modèle de Données, Persistance & Fichiers (P0)

#### US-01 : Modèle de données et sérialisation JSON
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Bloquant)
- **Description :** En tant que développeur, je veux disposer de modèles de données immuables et typés en Dart (`Album`, `Slide`, `Pin`, `ImageSource`) avec sérialisation/désérialisation JSON stricte afin de manipuler les données métier de façon fiable.
- **Critères d'acceptation :**
  1. Les modèles `Album`, `Slide`, `Pin` sont sérialisables et désérialisables via des méthodes `toJson()` et `fromJson()`.
  2. Le champ `version` est présent au niveau racine de l'album (actuellement `1`).
  3. `Pin` utilise des coordonnées flottantes `x` et `y` normalisées entre `0.0` et `1.0`. Une exception ou un clamp sécurisé est appliqué si les valeurs sortent de cet intervalle.
  4. `Slide` supporte les types `photo` et `comment`.
  5. Une suite de tests unitaires valide la conformité bidirectionnelle (`fromJson(toJson()) == original`).

#### US-02 : Persistance atomique sur disque et lecture tolérante aux pannes
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur, je veux que la sauvegarde de mes albums soit sécurisée contre toute corruption (ex: coupure de batterie, fermeture forcée de l'application) et qu'un album corrompu ne m'empêche pas d'accéder à mes autres albums.
- **Critères d'acceptation :**
  1. Toute écriture du fichier `album.json` s'effectue d'abord dans un fichier temporaire `album.json.tmp` dans le dossier de l'album.
  2. Une fois l'écriture terminée et vérifiée, le fichier `.tmp` est renommé atomiquement en `album.json`.
  3. Lors de la lecture de la liste des albums au démarrage :
     - Si un fichier `album.json` est invalide ou corrompu, une erreur est journalisée et l'album est marqué comme "Illisible" dans l'UI sans bloquer l'affichage des autres albums.
     - Si un fichier `.tmp` traîne lors du démarrage sans `album.json` valide, un mécanisme de récupération tente de restaurer l'état le plus récent.
  4. Des tests unitaires simulent des écritures interrompues et valident l'intégrité du stockage.

#### US-03 : Traitement et redimensionnement des images locales
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur choisissant de stocker mes photos dans l'application, je veux que les photos soient copiées dans le dossier de l'album et automatiquement optimisées (long bord $\le 2048$ px) afin de préserver l'espace de stockage et maintenir la fluidité de consultation.
- **Critères d'acceptation :**
  1. Lorsqu'une image est importée en mode "Stockage dans l'app", elle est copiée dans `<album_dir>/images/<uuid_ou_nom>.jpg`.
  2. Si la résolution maximale (largeur ou hauteur) dépasse 2048 px, l'image est redimensionnée en conservant son ratio d'aspect avant d'être sauvegardée.
  3. Le décodage et redimensionnement sont exécutés dans un `Isolate` séparé pour ne pas provoquer de saccades sur le thread principal de l'UI.
  4. L'imagette de couverture `cover.jpg` de l'album est générée (ex: 400x400 max) à partir de la première photo de l'album.

#### US-04 : Gestion des photos liées à la galerie et gestion des orphelins
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur choisissant le mode "Lien galerie", je veux référencer mes photos sans les dupliquer dans l'application, tout en ayant un comportement dégradé propre si la photo source venait à être supprimée du téléphone.
- **Critères d'acceptation :**
  1. L'entité `ImageSource` stocke l'URI ou identifiant natif de la galerie (ex: `content://...` sur Android ou identifiant local d'actif iOS).
  2. Aucun fichier n'est copié dans `images/` lorsque ce mode est sélectionné.
  3. Au moment de l'affichage, l'application vérifie l'accessibilité du fichier. Si la photo est inaccessible ou supprimée, l'UI bascule immédiatement sur l'état « Image not found » sans crasher.

---

### Epic 2 : Gestion des Albums & Navigation Principale (P0)

#### US-05 : Liste des albums avec imagettes et groupement alphabétique
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur, je veux visualiser l'ensemble de mes albums classés par ordre alphabétique avec leur couverture visuelle pour les retrouver instantanément.
- **Critères d'acceptation :**
  1. La liste des albums est triée par ordre alphabétique insensible à la casse et aux accents (`A-Z`).
  2. Chaque élément de la liste affiche :
     - L'imagette de couverture `cover.jpg`. Si inexistante, un placeholder élégant avec le titre de la première diapositive ou une icône neutre.
     - Le titre de l'album.
     - Le nombre total de diapositives.
     - La date de dernière modification.
  3. Un champ de recherche textuel permet de filtrer dynamiquement les albums par nom.
  4. Les cibles tactiles respectent les recommandations d'accessibilité ($\ge 48$ dp).

#### US-06 : Création d'un album avec validation stricte
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur, je veux pouvoir créer un nouvel album avec un nom propre et valide pour commencer à ajouter mes diapositives.
- **Critères d'acceptation :**
  1. Un bouton d'action flottant (FAB) ou bouton d'ajout en en-tête ouvre une boîte de dialogue de création.
  2. Le nom saisi est nettoyé (trim des espaces superflus).
  3. La longueur du nom doit être comprise entre 1 et 80 caractères.
  4. Les caractères interdits pour les dossiers du système de fichiers (`/`, `\`, `:`, `*`, `?`, `"`, `<`, `>`, `|`) sont rejetés avec un message explicatif clair.
  5. L'unicité du nom est vérifiée (insensible à la casse) parmi les albums existants.
  6. À la validation, le dossier physique de l'album et un fichier `album.json` initial sont créés, et l'application redirige automatiquement l'utilisateur vers l'éditeur de l'album.

#### US-07 : Renommage, duplication et suppression d'un album
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux gérer le cycle de vie de mes albums via un menu contextuel (renommer, dupliquer, supprimer avec confirmation).
- **Critères d'acceptation :**
  1. Un appui long ou un bouton d'options (trois points) sur un album ouvre un menu contextuel :
     - **Renommer :** Boîte de dialogue validant les mêmes règles que la création. Le dossier est renommé sur disque et le fichier `album.json` mis à jour.
     - **Dupliquer :** Crée une copie physique complète du dossier d'album avec le suffixe ` (copie)` (ou ` (copie n)`). L'album copié possède un nouvel identifiant unique.
     - **Supprimer :** Affiche une boîte de dialogue d'alerte rouge demandant confirmation explicite. À la confirmation, le dossier de l'album et tous ses fichiers locaux sont supprimés du disque.
  2. La liste se met à jour immédiatement après chaque action.

#### US-08 : Écran d'accueil vide, onboarding et animation explicative
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Ergonomie)
- **Description :** En tant que nouvel utilisateur ouvrant l'application pour la première fois, je veux être guidé par un écran d'accueil chaleureux comprenant une courte animation ou vidéo explicative illustrant les concepts clés de l'application (photos + punaises + liens).
- **Critères d'acceptation :**
  1. Si aucun album n'existe sur le téléphone, un écran d'accueil "Zéro état" s'affiche avec une illustration soignée et un message d'invitation à créer son premier album.
  2. Un encart ou un bouton permet de lancer une courte animation/vidéo d'introduction démontrant visuellement l'utilisation des punaises et la navigation interactive.
  3. L'animation ne bloque pas l'utilisateur et peut être passée ou rejouée depuis les paramètres.

---

### Epic 3 : Visionneuse Photo & Navigation Interactive (P0)

#### US-09 : Visionneuse photo avec zoom et pan fluides (1x à 6x)
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur consultant un album, je veux pouvoir zoomer (de 1x à 6x) et me déplacer librement dans l'image avec une fluidité maximale ($\ge 60$ fps) pour explorer les détails.
- **Critères d'acceptation :**
  1. Le geste de pincement (pinch-to-zoom) zoome dans l'image, centré exactement sur le point de contact des doigts.
  2. Le facteur de zoom est borné entre `1.0x` (taille ajustée à l'écran) et `6.0x`.
  3. Un double-tap rapide alterne intelligemment entre zoom normal (`1.0x`) et zoom intermédiaire (`2.5x` ou `3.0x`).
  4. Lorsque l'image est zoomée, le panoramique (pan) permet de naviguer dans les limites de l'image sans déborder arbitrairement.
  5. Les performances d'affichage garantissent 60 fps constants sans blocage d'interface.

#### US-10 : Navigation par glissement (flick) et flèches transitoires
- **Rôle :** Affichage
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur en visionneuse, je veux passer d'une diapositive à l'autre par un balayage du doigt (swipe/flick) avec boucle infinie et voir des flèches temporaires pour m'orienter.
- **Critères d'acceptation :**
  1. Lorsque le zoom est à `1.0x`, un balayage horizontal vers la gauche passe à la diapositive suivante ; vers la droite, à la précédente.
  2. La navigation fonctionne en boucle continue (la suivante de la dernière diapositive est la première, et inversement).
  3. Deux flèches de navigation discrètes s'affichent sur les côtés gauche et droit de l'écran lors du changement de diapositive, puis disparaissent automatiquement après 1 seconde d'inactivité.
  4. Si l'image est zoomée ($> 1.0x$), le geste de pan déplace l'image et ne déclenche pas le changement de diapositive, sauf en cas d'overscroll intentionnel en bordure d'image.

#### US-11 : Affichage des punaises ancrées et bulles de texte
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur, je veux voir les punaises positionnées sur la photo et pouvoir toucher une punaise pour lire sa bulle de texte descriptive.
- **Critères d'acceptation :**
  1. Chaque punaise est dessinée à sa position normalisée $(x \times \text{largeur\_image}, y \times \text{hauteur\_image})$ par rapport à l'image affichée (et suit fidèlement les zooms et déplacements de l'image sans décalage).
  2. La punaise arbore sa couleur et sa taille configurées.
  3. Toucher une punaise ouvre une bulle d'information au-dessus (ou en dessous si bord supérieur) de celle-ci avec une transition douce.
  4. La bulle affiche le texte (jusqu'à 400 caractères, multi-lignes).
  5. Toucher en dehors de la bulle ou sur une autre punaise referme la bulle active.

#### US-12 : Navigation via punaises de lien et pile de retour (↩)
- **Rôle :** Affichage
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, lorsqu'une punaise pointe vers une autre diapositive, je veux pouvoir l'activer pour sauter vers cette diapositive et disposer d'un bouton retour pour revenir sur mes pas dans l'historique des liens.
- **Critères d'acceptation :**
  1. Une punaise de lien affiche un indicateur visuel distinctif (ex: icône de lien ou flèche discrète).
  2. L'activation d'un lien (directement ou depuis sa bulle) effectue une transition fluide vers la diapositive cible.
  3. L'identifiant de la diapositive d'origine est empilé dans une pile d'historique de navigation de liens.
  4. Un bouton d'action retour `↩` apparaît à l'écran dès que la pile d'historique contient au moins un élément.
  5. Toucher `↩` dépile la dernière diapositive visitée et y ramène l'utilisateur.
  6. Si l'utilisateur utilise le menu "Aller à..." ou swipe manuellement, la pile de retour est réinitialisée.

#### US-13 : Masquage des punaises et mode immersion
- **Rôle :** Affichage
- **Priorité :** P0 (Confort)
- **Description :** En tant qu'utilisateur admirant une photo, je veux pouvoir masquer temporairement toutes les punaises et basculer en plein écran immersif sans barres système ni menus.
- **Critères d'acceptation :**
  1. Un bouton bascule (icône œil ou punaise barrée) permet de cacher/afficher instantanément toutes les punaises et bulles de l'écran.
  2. Un simple tap sur une zone libre de la photo masque la barre d'application (AppBar) et la barre de commandes pour basculer en mode plein écran immersif (System UI masquée).
  3. Un nouveau tap réaffiche les commandes d'interface.

#### US-14 : État « Image not found » et réassociation d'image
- **Rôle :** Affichage
- **Priorité :** P0 (Robustesse)
- **Description :** En tant qu'utilisateur, si une image de ma galerie a été déplacée ou supprimée, je veux que l'application m'indique clairement « Image not found » et me propose de réparer le lien sans casser l'album.
- **Critères d'acceptation :**
  1. Si le fichier image est introuvable au moment du rendu, un écran de substitution élégant s'affiche avec la mention « Image not found ».
  2. Un bouton « Réassocier une image » permet d'ouvrir le sélecteur de fichiers ou la galerie pour désigner la nouvelle image.
  3. Une fois sélectionnée, le lien ou la copie est rétabli et les punaises existantes de la diapositive restent conservées à leurs coordonnées normalisées.

---

### Epic 4 : Édition des Photos, Punaises & Diapositives (P0)

#### US-15 : Éditeur photo : pose de punaise et positionnement normalisé
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Description :** En tant que créateur d'album en mode édition, je veux pouvoir toucher n'importe quel point d'une photo pour y déposer immédiatement une nouvelle punaise.
- **Critères d'acceptation :**
  1. En mode édition photo, un appui court sur l'image dépose une punaise à l'endroit cliqué.
  2. Les coordonnées de l'écran sont immédiatement converties en ratio normalisé $x, y \in [0.0, 1.0]$ relatif à la taille réelle de l'image source, indépendamment du niveau de zoom actuel.
  3. La nouvelle punaise adopte les réglages par défaut définis dans les paramètres (taille et couleur favorites).
  4. La boîte de dialogue ou le panneau de configuration de la punaise s'ouvre aussitôt.

#### US-16 : Éditeur photo : configuration de la punaise (texte, lien, style)
- **Rôle :** Affichage
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur éditant une punaise, je veux définir son texte descriptif, son éventuel lien vers une autre diapositive, sa couleur, sa taille, ou la supprimer.
- **Critères d'acceptation :**
  1. Formulaire d'édition de la punaise :
     - **Texte :** Champ de saisie multi-lignes, limité à 400 caractères avec affichage d'un compteur.
     - **Lien vers diapositive :** Interrupteur on/off. Si activé, affiche la liste déroulante ou le sélecteur visuel des diapositives disponibles dans l'album.
     - **Couleur :** Choix parmi les 6 teintes prédéfinies (Noir, Blanc, Vert, Jaune, Bleu, Violet).
     - **Taille :** Sélecteur de taille allant de 1.0 à 3.0 par incréments de 0.5.
     - **Supprimer :** Bouton pour supprimer la punaise sélectionnée.
  2. La validation met à jour le modèle en mémoire et déclenche le cycle de persistance.

#### US-17 : Ajout d'une diapositive (Photo ou Commentaire)
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Bloquant)
- **Description :** En tant qu'utilisateur, je veux pouvoir insérer une nouvelle diapositive (prise de photo via caméra, sélection galerie, ou écran de commentaire) juste après la diapositive courante.
- **Critères d'acceptation :**
  1. Un bouton « Ajouter une diapositive » propose les options :
     - *Prendre une photo* (déclenche la caméra du téléphone).
     - *Choisir dans la galerie* (ouvre le sélecteur de photos).
     - *Ajouter un commentaire seul*.
  2. La nouvelle diapositive est insérée immédiatement après la diapositive actuellement affichée (ou à la fin si l'album est vide).
  3. Un titre par défaut « Titre n » est attribué automatiquement (éditable jusqu'à 40 caractères max).
  4. Pour les photos, le mode de stockage appliqué par défaut est celui configuré dans les réglages (copie locale ou lien galerie), avec possibilité de le modifier au moment de l'ajout.

#### US-18 : Diapositives Commentaires : visionneuse et éditeur dédié
- **Rôle :** Affichage
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux pouvoir consulter et éditer des diapositives textuelles de commentaire (sans image obligatoire) pour raconter une anecdote ou introduire un chapitre.
- **Critères d'acceptation :**
  1. Une diapositive de type `comment` propose une mise en page typographique soignée avec centrage vertical, police lisible et fond contrasté.
  2. L'éditeur de commentaire permet la saisie de texte libre avec un avertissement / compteur de caractères dès que le texte dépasse 350 caractères.
  3. Si une diapositive photo possède également un commentaire, l'utilisateur peut basculer facilement entre la vue photo et la vue texte.
  4. Si une diapositive de commentaire n'a pas de texte, l'application bascule automatiquement vers la vue photo si une photo existe.

#### US-19 : Réorganisation des diapositives et suppression
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux réordonner l'enchaînement de mes diapositives par glisser-déposer et pouvoir supprimer une diapositive tout en étant averti des liens orphelins.
- **Critères d'acceptation :**
  1. Un écran « Réorganiser » affiche les diapositives sous forme de grille de vignettes réordonnables.
  2. Deux modes d'interaction sont supportés :
     - *Glisser-déposer tactile* direct (ReorderableListView / Grid).
     - *Sélection puis cible* (toucher la source, puis toucher la destination pour accessibilité et précision).
  3. La suppression d'une diapositive requiert une confirmation modale.
  4. Si la diapositive supprimée était la cible de punaises dans d'autres diapositives, l'utilisateur est averti et ces liens sont marqués comme orphelins ou supprimés proprement.

#### US-20 : Navigation directe « Aller à… »
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Confort)
- **Description :** En tant qu'utilisateur parcourant un album volumineux, je veux pouvoir sauter directement à une diapositive donnée via un menu « Aller à… ».
- **Critères d'acceptation :**
  1. L'action « Aller à… » ouvre une feuille modale inférieure (Bottom Sheet) présentant :
     - Les raccourcis « Suivant » et « Précédent ».
     - La liste complète des diapositives triées par numéro et groupées par titre.
  2. La sélection d'une diapositive navigue directement dessus.
  3. Cette sélection volontaire réinitialise la pile d'historique de retour des liens de punaises (`↩`).

---

### Epic 5 : Robustesse, Gestion des Fichiers & Import/Export (P0)

#### US-21 : Sauvegarde automatique paramétrable et sauvegarde manuelle
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux pouvoir activer ou désactiver la sauvegarde automatique, et bénéficier d'une temporisation de 1,5 seconde (débounce) ou d'une sauvegarde lors des transitions pour éviter d'user le stockage par des écritures répétitives.
- **Critères d'acceptation :**
  1. Les paramètres de l'application proposent un interrupteur « Sauvegarde automatique » (activé par défaut).
  2. Lorsqu'il est activé, après toute modification dans l'éditeur (texte, déplacement de punaise, etc.), un décompte de 1,5 seconde d'inactivité (debounce) déclenche l'écriture atomique sur disque.
  3. La sauvegarde est également systématiquement déclenchée lors de la sortie de l'éditeur ou mise en arrière-plan de l'application.
  4. Si la sauvegarde automatique est désactivée, un bouton d'action explicite « Enregistrer » est toujours présent dans la barre supérieure de l'éditeur.

#### US-22 : Écran de gestion des fichiers et espace de stockage
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux disposer d'un écran dédié pour visualiser l'espace disque consommé par chaque album et examiner le détail des fichiers stockés.
- **Critères d'acceptation :**
  1. L'écran « Gestion des fichiers » liste tous les albums avec leur taille totale calculée en Mo / Ko.
  2. En sélectionnant un album, l'utilisateur peut explorer l'arborescence :
     - Le fichier `album.json` (taille, date).
     - La liste de toutes les images contenues dans le sous-dossier `images/` avec leur poids individuel.
  3. L'utilisateur peut supprimer manuellement une image spécifique depuis cet écran (avec confirmation).

#### US-23 : Diagnostic et nettoyage de l'album
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux lancer un nettoyage automatique sur un album pour supprimer les images orphelines (fichiers présents dans `images/` mais non référencés dans `album.json`), les fichiers temporaires résiduels et détecter les liens cassés.
- **Critères d'acceptation :**
  1. Un bouton « Nettoyer » déclenche une analyse de l'album sélectionné.
  2. L'analyse recense :
     - Les fichiers d'images non référencés dans `album.json`.
     - Les fichiers temporaires `.tmp`.
     - Les punaises pointant vers des identifiants de diapositives inexistants.
  3. Une boîte de dialogue de récapitulatif affiche le détail des éléments détectés et l'espace disque qui sera libéré avant toute action.
  4. À la confirmation de l'utilisateur, les fichiers orphelins sont purgés et les liens invalides sont nettoyés.

#### US-24 : Export d'un album au format archive `.photopush`
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux exporter un album complet sous la forme d'un fichier archive `.photopush` (archive ZIP contenant `album.json` et toutes les images) et le partager via les applications de mon téléphone (Drive, iCloud, OneDrive, messagerie).
- **Critères d'acceptation :**
  1. L'action « Exporter » compresse l'intégralité du dossier de l'album en un fichier `<Nom_Album>.photopush` (format ZIP standard).
  2. Si l'album contient des photos liées à la galerie externe, le processus d'export rapatrie une copie de ces photos dans l'archive pour garantir que le fichier exporté soit 100 % autonome et portable sur n'importe quel autre appareil.
  3. L'archive générée est transmise à la feuille de partage native du système d'exploitation (iOS Share Sheet / Android Intent Share).
  4. Une barre de progression informe l'utilisateur pendant la compression.

#### US-25 : Import d'une archive `.photopush` avec gestion des collisions
- **Rôle :** Modèle & Fichiers
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux pouvoir importer un fichier `.photopush` depuis le sélecteur de fichiers de mon téléphone ou lorsqu'on m'envoie le fichier par email/messagerie, avec un contrôle strict de sécurité.
- **Critères d'acceptation :**
  1. L'application est enregistrée auprès du système comme gestionnaire des fichiers `.photopush` et propose un bouton « Importer » dans l'écran de gestion des fichiers.
  2. Sécurité de décompression :
     - Vérification contre les attaques par traversée de répertoires (*Zip Slip* : interdiction des chemins contenant `../`).
     - Vérification de la présence et de la validité du format de `album.json`.
     - Si l'archive est invalide ou corrompue, l'import est refusé immédiatement avec un message d'erreur sans affecter les albums existants.
  3. Gestion des conflits de nom :
     - Si un album du même nom existe déjà localement, une boîte de dialogue propose trois choix : **Renommer** (saisie d'un nouveau nom), **Remplacer** (écrase l'existant après confirmation explicite), ou **Annuler**.
  4. Une fois décompressé dans le dossier `albums/<Nom>/`, l'album apparaît instantanément dans la liste des albums.

---

### Epic 6 : Réglages, Thème, Accessibilité & Internationalisation (P0)

#### US-26 : Paramètres généraux et personnalisation des punaises
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Must-have)
- **Description :** En tant qu'utilisateur, je veux configurer mes préférences par défaut (couleur favorite de punaise, taille par défaut, mode de stockage par défaut des photos) afin de gagner du temps lors de la création.
- **Critères d'acceptation :**
  1. Écran de paramètres permettant de choisir :
     - La couleur par défaut des nouvelles punaises (parmi les 6 teintes).
     - La taille par défaut des nouvelles punaises (1.0 à 3.0).
     - Le mode de stockage des photos par défaut (« Stockage dans l'app » vs « Lien galerie »).
     - L'activation ou désactivation de la sauvegarde automatique.
  2. Les réglages sont persistés dans les préférences de l'application (`SharedPreferences`).
  3. Les modifications s'appliquent immédiatement à toutes les prochaines créations (sans altérer rétroactivement les punaises existantes).

#### US-27 : Thème sombre par défaut et adaptation visuelle
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Design)
- **Description :** En tant qu'utilisateur d'une application photo, je veux bénéficier d'un thème sombre élégant et contrasté par défaut pour mettre en valeur les clichés et limiter la fatigue visuelle.
- **Critères d'acceptation :**
  1. L'application propose un thème sombre par défaut avec des noirs profonds (`#121212` / surfaces sombres) et des accents visuels soignés.
  2. L'utilisateur peut choisir dans les réglages : « Thème sombre » (recommandé/défaut), « Thème clair », ou « Suivre le système ».
  3. Toutes les boîtes de dialogue, bulles de punaises et fiches d'édition s'adaptent avec un contraste rigoureux.

#### US-28 : Internationalisation (Anglais / Français) et Accessibilité
- **Rôle :** Menus & Écrans
- **Priorité :** P0 (Qualité)
- **Description :** En tant qu'utilisateur international ou francophone, je veux que l'application soit disponible en anglais et en français, et qu'elle soit pleinement accessible (contrastes, tailles de cibles tactiles, lecteurs d'écran).
- **Critères d'acceptation :**
  1. L'ensemble des chaînes de caractères de l'application est externalisé via `flutter_localizations` et des fichiers `.arb` (`app_en.arb`, `app_fr.arb`).
  2. L'anglais est la langue par défaut, avec détection automatique de la langue du système (si système en français $\rightarrow$ affichage en français).
  3. Les cibles tactiles interactives font au minimum $48 \times 48$ dp.
  4. Le ratio de contraste texte/fond respecte la norme WCAG AA ($\ge 4,5:1$).
  5. L'interface s'adapte sans débordement (overflow) lorsque la taille de police système est augmentée jusqu'à 200 %.
  6. Tous les boutons et éléments interactifs disposent de labels `Semantics` pour TalkBack (Android) et VoiceOver (iOS).

---

### Epic 7 : Extension Synchronisation Distante & Stockage S3 (P1)

#### US-29 : Écran de synchronisation manuelle et comparaison delta
- **Rôle :** Synchronisation
- **Priorité :** P1 (Extension)
- **Description :** En tant qu'utilisateur souhaitant synchroniser un album de référence avec mon équipe ou un serveur distant, je veux disposer d'un écran dédié pour comparer l'état local et distant et déclencher manuellement l'envoi ou la récupération.
- **Critères d'acceptation :**
  1. Un écran « Synchronisation distante » liste les albums disponibles sur l'espace de stockage distant.
  2. Deux actions principales sont proposées :
     - **Envoyer (Push) :** Pousse l'album local sélectionné sur le stockage distant.
     - **Récupérer (Pull) :** Télécharge l'album distant vers le stockage local.
  3. Comparaison delta intelligente : seules les images absentes ou modifiées sont transférées (comparaison basée sur le nom de fichier et la taille en octets), évitant de re-télécharger l'ensemble des médias.
  4. Si un album local existe déjà lors d'une récupération, l'application demande confirmation explicite avant d'écraser la version locale (avec option de créer une copie locale de sauvegarde).
  5. En cas de coupure réseau ou d'erreur, aucune modification partielle corrompue n'est appliquée et un message clair informe l'utilisateur.

#### US-30 : Connecteur S3 / MinIO et stockage sécurisé des identifiants
- **Rôle :** Accès distant
- **Priorité :** P1 (Extension)
- **Description :** En tant qu'utilisateur configurant la synchronisation distante, je veux renseigner mes accès à un bucket compatible S3 (AWS, MinIO, Wasabi, etc.) avec la garantie que mes identifiants sont chiffrés dans le trousseau sécurisé de l'appareil.
- **Critères d'acceptation :**
  1. Dans les paramètres avancés de synchronisation, l'utilisateur peut renseigner :
     - Endpoint URL (ex: `https://s3.eu-west-3.amazonaws.com` ou endpoint MinIO personnalisé).
     - Nom du Bucket.
     - Région.
     - Access Key ID et Secret Access Key.
  2. Les clés secrètes sont enregistrées dans le trousseau sécurisé de l'OS via `flutter_secure_storage` (Android Keystore / iOS Keychain).
  3. L'ensemble des communications réseau transite impérativement en HTTPS.
  4. L'accès au stockage distant est isolé derrière une interface d'abstraction Dart (`RemoteStorageService`) pour permettre l'ajout futur d'autres backends sans impacter la logique de synchronisation.

---

## 6. Définition de Terminé (DoD - Definition of Done)

Chaque User Story n'est considérée comme **Terminée (Done)** que si les critères suivants sont satisfaits :
1. **Implémentation :** Le code est rédigé en Dart/Flutter idiomatique, typé, et sans avertissement (`flutter analyze` sans erreur ni warning).
2. **Architecture :** Respect strict de la séparation en trois couches (Interface UI $\leftrightarrow$ Modèle métier $\leftrightarrow$ Services de stockage sur disque). L'UI n'accède jamais directement au système de fichiers.
3. **Tests :** Des tests unitaires ou de widgets vérifient la fonctionnalité et les cas limites (fichiers absents, entrées invalides, interruption d'écriture).
4. **Offline First :** L'exécution a été validée sans aucune connexion réseau active pour toutes les US de priorité P0.
5. **Ergonomie :** Les gestes tactiles sont fluides, réactifs et le thème sombre est correctement honoré.
