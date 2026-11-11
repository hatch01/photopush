# PhotoPush

Réécriture Flutter d'une application d'albums photo interactifs, légère et 100 % hors ligne, avec import/export manuel et synchronisation distante optionnelle.

---

## Architecture logicielle

L'application repose sur une **architecture réactive en couches** (séparation Présentation / Contrôleurs / Modèles / Services) conçue selon un paradigme **100 % hors ligne (*offline-first*)** :
- **Aucune base de données SQL** : chaque album est un dossier autonome sur le système de fichiers.
- **Source de vérité unique** : le fichier `album.json` stocké dans chaque dossier d'album.
- **Gestion d'état réactive** : utilisation de `ChangeNotifier` (`ListenableBuilder` / `AnimatedBuilder`) sans surcoût de frameworks tiers.
- **Modèles immuables** : sérialisation JSON stricte et méthodes `copyWith`.
- **Résilience aux pannes** : écritures atomiques sur disque et récupération automatique en cas de crash.

```
lib/
├── controllers/    # Gestion d'état & orchestration métier (ChangeNotifier)
├── models/         # Modèles de domaine immuables & sérialisation JSON
├── services/       # E/S, persistance atomique, traitement d'images & archives
│   ├── media/      # Traitement image, sélection (picker), partage système
│   └── storage/    # Gestion du système de fichiers & archives .photopush
└── ui/             # Couche présentation Flutter (écrans & widgets)
    ├── screens/    # Écrans principaux (liste, détail/slides, réorganisation, paramètres)
    └── widgets/    # Vues de diapositives, overlay de pins, dialogues et panneaux
```

---

### 1. Communication entre les composants

Le diagramme ci-dessous illustre les interactions et flux de communication entre la vue (UI), les contrôleurs d'état, les modèles de données et les services d'infrastructure :

```mermaid
flowchart TD
    subgraph UI["Couche Présentation (lib/ui)"]
        direction TB
        subgraph Screens["Écrans (Screens)"]
            AlbumsListScreen["AlbumsListScreen\n(Galerie des albums & actions)"]
            AlbumDetailScreen["AlbumDetailScreen\n(Visionneuse carrousel & immersion)"]
            FileManagerScreen["FileManagerScreen\n(Gestion espace disque & purge)"]
            SettingsScreen["SettingsScreen\n(Préférences utilisateur)"]
            ReorderSlidesScreen["ReorderSlidesScreen\n(Réorganisation glisser-déposer)"]
        end
        subgraph Widgets["Composants & Widgets (Widgets)"]
            PhotoSlideView["PhotoSlideView\n(InteractiveViewer, zoom & overlay)"]
            CommentSlideView["CommentSlideView\n(Diapositive de texte pur)"]
            PinView["PinView & PinEditorDialog\n(Création, édition & liens)"]
            BottomSheets["AddSlide / GotoSlide BottomSheet"]
            AlbumCard["AlbumCard & Dialogs\n(Création, renommage, suppression)"]
        end
    end

    subgraph Controllers["Couche Contrôleurs & État (lib/controllers)"]
        AlbumsController["AlbumsController\n(ChangeNotifier)\n- Liste des albums & recherche\n- Création / Renommer / Supprimer\n- Duplication & couvertures"]
        AlbumDetailController["AlbumDetailController\n(ChangeNotifier)\n- Slide courante & navigation\n- Historique de navigation par pins\n- Ajout photos/commentaires\n- Auto-save détemporisé (1.5s)"]
        SettingsController["SettingsController\n(ChangeNotifier)\n- Thème sombre / clair\n- Couleur & taille des pins par défaut\n- Mode stockage & auto-save"]
    end

    subgraph Models["Couche Modèles de Données (lib/models)"]
        Album["Album\n(id, name, coverPath, version, dates)"]
        Slide["Slide\n(id, type: photo|comment, title, comment)"]
        Pin["Pin\n(id, x, y normalisés [0..1], color, targetSlide)"]
        ImageSource["ImageSource\n(internal | gallery, path, originalFileName, size)"]
        DiskSpaceInfo["DiskSpaceInfo\n(usedBytes, freeBytes, totalBytes)"]
    end

    subgraph Services["Couche Services & Métier (lib/services)"]
        AlbumStorageService["AlbumStorageService\n- Écritures atomiques .tmp -> rename\n- Récupération sur fichier corrompu\n- Calcul espace & purge orphelines"]
        ArchiveService["ArchiveService\n- Export ZIP .photopush (avec staging)\n- Import sécurisé (anti-Zip Slip)"]
        ImageProcessorService["ImageProcessorService\n- Redimensionnement (bord long <= 2048 px)\n- Génération vignette cover.jpg (400 px)"]
        ImagePickerService["ImagePickerService\n- Prise de vue (caméra) ou galerie"]
        ShareService["ShareService\n- Feuille de partage système (share_plus)"]
    end

    subgraph StorageOS["Persistance Locale & Périphériques"]
        DiskFileSystem[("Documents /albums/\n<AlbumName>/album.json\n<AlbumName>/images/\n<AlbumName>/cover.jpg")]
        PrefsStorage[("SharedPreferences\n(Clés paramètres)")]
        DeviceMedia["Caméra & Galerie Photos Système"]
    end

    %% Communication UI <-> Controllers
    Screens -->|"Écoute l'état (AnimatedBuilder / addListener)"| Controllers
    Widgets -->|"Déclenche actions & modifications"| Controllers
    Controllers -.->|"Notifie les changements (notifyListeners)"| UI

    %% Controllers <-> Models
    Controllers -->|"Lit & met à jour (copyWith immuable)"| Models
    Album -->|"Contient 0..*"| Slide
    Slide -->|"Possède 0..*"| Pin
    Slide -->|"Référence"| ImageSource

    %% Controllers <-> Services
    AlbumsController -->|"CRUD & scan des dossiers"| AlbumStorageService
    AlbumsController -->|"Archive / Décompresse"| ArchiveService
    AlbumsController -->|"Partage de fichier"| ShareService

    AlbumDetailController -->|"Sauvegarde JSON & lecture"| AlbumStorageService
    AlbumDetailController -->|"Traitement & vignettes"| ImageProcessorService
    AlbumDetailController -->|"Sélection photo"| ImagePickerService

    FileManagerScreen -->|"Calcul espace & nettoyage"| AlbumStorageService
    SettingsController -->|"Persistance synchrone / asynchrone"| PrefsStorage

    %% Services <-> Hardware / Disque
    AlbumStorageService -->|"I/O atomiques avec disk flush"| DiskFileSystem
    ArchiveService -->|"Extraction / Compression ZIP"| DiskFileSystem
    ImageProcessorService -->|"Écriture JPEG optimisé (qualité 85)"| DiskFileSystem
    ImagePickerService -->|"Capture / Sélection"| DeviceMedia
    ArchiveService -.->|"Fichier archive .photopush"| ShareService
```

---

### 2. Gestion des données et persistance sur disque

Chaque album est entièrement encapsulé dans un sous-répertoire sous le dossier des documents de l'application (`<app_documents>/albums/<AlbumName>/`).

```mermaid
flowchart TD
    subgraph DiskLayout["Arborescence sur le Système de Fichiers (/albums/)"]
        direction TB
        subgraph AlbumDir["Dossier d'Album : /albums/&lt;AlbumName&gt;/"]
            direction TB
            AlbumJson["album.json\n(Source de vérité unique, JSON indenté)"]
            AlbumTmp["album.json.tmp\n(Écriture temporaire avec flush: true)"]
            CoverJpg["cover.jpg\n(Vignette de couverture carrée max 400px)"]
            
            subgraph ImagesSubdir["Sous-dossier : images/"]
                ImgA["img_uuid1.jpg (max 2048px)"]
                ImgB["img_uuid2.jpg (max 2048px)"]
            end
        end
    end

    subgraph StorageModes["Modes de Stockage des Photos (ImageStorageType)"]
        direction TB
        InternalMode["Mode Interne (internal)\n- Copie optimisée et redimensionnée dans images/\n- 100 % autonome, pérenne et portable\n- Supprimable via FileManagerScreen"]
        GalleryMode["Mode Galerie (gallery)\n- Référence directe par chemin absolu système\n- Zéro duplication de stockage\n- Réassociation guidée si le fichier source disparaît"]
    end

    subgraph AtomicWrite["Protocole de Sauvegarde Atomique (Anti-corruption)"]
        direction TB
        Step1["1. Sérialisation du modèle Album en chaîne JSON"]
        Step2["2. Écriture disque dans 'album.json.tmp' (flush: true)"]
        Step3["3. Renommage atomique : album.json.tmp -> album.json"]
        StepRecovery["Tolérance aux pannes :\nSi album.json est absent/vide après crash,\nrestauration automatique depuis .tmp"]

        Step1 --> Step2 --> Step3
        Step2 -.->|"Coupure / crash pendant l'opération"| StepRecovery
    end

    subgraph Portability["Portabilité & Partage (.photopush)"]
        direction TB
        ExportZip["Export Archive :\n1. Copie en zone de staging\n2. Rapatriement temporaire des images galerie\n3. Compression ZIP (.photopush)"]
        ImportZip["Import Archive :\n1. Décompression en répertoire temporaire\n2. Validation anti-Zip Slip (chemins '..')\n3. Contrôle d'intégrité de album.json\n4. Déplacement atomique vers /albums/"]
    end

    AlbumJson -.->|"Référence les images internes"| ImagesSubdir
    AlbumJson -.->|"Définit la miniature"| CoverJpg
    AlbumDir <-->|"Persisté via"| AtomicWrite
    AlbumDir <-->|"Exporté / Importé via"| Portability
    ImagesSubdir --- InternalMode
```

---

### 3. Flux de données et cycle de vie des interactions

Ce diagramme de séquence détaille le cycle complet lors de l'ajout d'une photo, du placement d'une épingle (*pin*) interactive et de la sauvegarde automatique détemporisée (*debounced auto-save*) :

```mermaid
sequenceDiagram
    autonumber
    actor User as Utilisateur
    participant UI as AlbumDetailScreen / PhotoSlideView
    participant Ctrl as AlbumDetailController
    participant Picker as ImagePickerService
    participant Proc as ImageProcessorService
    participant Store as AlbumStorageService
    participant FS as Disque Local (Documents/albums)

    Note over User,UI: 1. Ajout d'une diapositive photo
    User->>UI: Appuie sur "+ Photo" (choix Caméra ou Galerie)
    UI->>Ctrl: addPhotoSlideFromPicker(fromCamera, storeInApp)
    Ctrl->>Picker: pickFromCamera() ou pickFromGallery()
    Picker-->>Ctrl: Fichier brut File

    alt Stockage Interne (storeInApp == true)
        Ctrl->>Proc: processAndSaveImage(source, targetImagesDir)
        Proc->>FS: Redimensionnement proportionnel (<= 2048px) & Écriture JPEG
        Proc-->>Ctrl: Fichier traité img_uuid.jpg
        opt Première photo ou couverture manquante
            Ctrl->>Proc: generateCoverThumbnail(photo, albumDir)
            Proc->>FS: Écriture cover.jpg (<= 400px)
        end
    else Référence Galerie
        Ctrl->>Ctrl: Crée ImageSource(gallery, chemin absolu)
    end

    Ctrl->>Ctrl: Instancie Slide(photo, imageSource) & insère dans l'Album
    Ctrl->>Store: saveAlbum(_album)
    Store->>FS: Écriture album.json.tmp (flush: true)
    Store->>FS: renameSync('album.json.tmp' -> 'album.json')
    Ctrl-->>UI: notifyListeners() (Affichage immédiat de la nouvelle slide)

    Note over User,UI: 2. Création d'une épingle (Pin) interactive
    User->>UI: Clic prolongé sur l'image (coordonnées écran)
    UI->>UI: Normalisation des coordonnées (x, y ∈ [0.0, 1.0])
    UI->>UI: Ouvre PinEditorDialog (titre, commentaire, couleur, slide liée)
    User->>UI: Valide la création de l'épingle
    UI->>Ctrl: addPin(newPin)
    Ctrl->>Ctrl: _replaceCurrentSlide(updatedSlide avec nouveau Pin)
    Ctrl-->>UI: notifyListeners() (Le Pin apparaît instantanément sur l'image)
    Ctrl->>Ctrl: Déclenche _triggerAutoSave() (Timer debounce 1500 ms)

    Note over Ctrl,Store: 3. Sauvegarde automatique en arrière-plan
    Ctrl->>Ctrl: Expiration du Timer (1.5 seconde d'inactivité)
    Ctrl->>Store: forceSaveAlbum()
    Ctrl-->>UI: notifyListeners() (isSaving: true)
    Store->>FS: Écriture atomique sécurisée dans album.json
    Store-->>Ctrl: Succès
    Ctrl-->>UI: notifyListeners() (isSaving: false)

    Note over User,UI: 4. Navigation interactive par épingle
    User->>UI: Touche une épingle liée à une autre diapositive
    UI->>Ctrl: navigateToSlideViaLink(targetSlideIndex)
    Ctrl->>Ctrl: Empile l'index courant dans _navigationHistory
    Ctrl->>Ctrl: Définit currentIndex = targetSlideIndex
    Ctrl-->>UI: notifyListeners() (Transition fluide vers la diapositive cible)
    User->>UI: Touche le bouton "Retour" de la barre d'action
    UI->>Ctrl: goBackInHistory()
    Ctrl->>Ctrl: Dépile le dernier index et restaure la diapositive d'origine
    Ctrl-->>UI: notifyListeners()
```

---

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
