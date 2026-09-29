# Photo Push — Cahier des charges
## Réécriture Flutter — application 100 % hors ligne, + synchronisation multi-appareils en option

| Champ | Valeur |
|---|---|
| Projet source | `PhoneAppPhoto` (Windows Phone 8.1 / Silverlight, C# + XAML) — **référence documentaire uniquement** |
| Cible | Application Flutter (Android + iOS), **offline-first** |
| Extension majeure | Serveur de synchronisation, sauvegarde des médias, multi-appareils — **optionnel, jamais requis** |
| Compatibilité avec le format de données WP8 (XML) | **Aucune.** Aucun XML, aucun `XmlSerializer`, aucun parseur legacy dans l'application |
| Version du document | 1.1 |
| Statut | Spécification fonctionnelle et technique — à valider |

---

# 0. Principes directeurs et conventions

## 0.1 Principes directeurs (non négociables, priment sur tout le reste du document)

1. **L'application est hors ligne par défaut.** Toutes les fonctionnalités des chapitres 3 et 4 doivent être utilisables **intégralement, sans réseau et sans compte**. Une exigence qui ne serait pas satisfaite en mode avion est hors sujet.
2. **Le mode en ligne est un ajout, jamais un prérequis.** Aucune fonctionnalité du cœur n'est conditionnée à l'existence d'un compte ou d'un serveur. Le serveur peut être indisponible 100 % du temps sans perte de fonctionnalité.
3. **Pas de compatibilité avec le format WP8, et rien à récupérer.** La nouvelle application ne lit pas, n'écrit pas et n'imite pas le format XML existant, et **ne prévoit aucun moyen de récupérer les albums de l'ancienne version** (ni dans l'app, ni par un outil externe — décision D-7). On garde une **trace documentaire** de l'ancien format (chapitres 1 et 11) pour comprendre l'historique et ne pas reproduire ses défauts ; il n'y a **aucune obligation de lire ou d'écrire ce format**.
4. **Conservation des usages, pas des défauts.** On reproduit les *comportements* appréciés (couleurs, tailles, navigation, fil d'Ariane, textes), jamais les bugs, les limites arbitraires ni les choix de stockage.
5. **La base locale est la source de vérité.** L'UI n'accède jamais directement au réseau (cf. § 6.2).

## 0.2 Conventions

- **CDC** : le présent document.
- Les identifiants `RF-xx` (exigence fonctionnelle), `R-xx` (règle métier), `LIM-xx` (limite), `RT-xx` (technique), `RNF-xx` (non fonctionnelle), `SEC-xx` (sécurité), `SYNC-xx` (synchronisation) sont normatifs et doivent être couverts par au moins un test.
- Priorités : **M** = MUST (obligatoire v1), **S** = SHOULD (v1 si possible), **C** = COULD (post-v1).
- Toute exigence non couverte par un critère d'acceptation est considérée non terminée.
- Chapitres à statut documentaire (non normatifs) : **1** (analyse de l'existant) et **11** (format legacy). Ils décrivent le passé et ne prescrivent rien.

---

# 1. Analyse de l'existant

> **Statut de ce chapitre : documentaire.** Il sert de mémoire du fonctionnement historique et de justification des corrections du chapitre 5. Aucune exigence de ce chapitre n'est contraignante en tant que telle.

## 1.1 Synthèse

L'application existante est un **livre/album photo interactif** pour Windows Phone 8.1.

- L'utilisateur crée des **albums**.
- Chaque album contient une **liste ordonnée de diapositives** (« slides »).
- Une diapositive contient soit une **photo** (référence à la photothèque du téléphone), soit un **commentaire texte**, soit les deux.
- Sur une diapositive photo, l'utilisateur place des **punaises carrées** (« ouvertures » / *push pins*). Chaque punaise peut porter un **texte** (bulle contextuelle), pointer vers **une autre diapositive** (lien de navigation), ou les deux.
- La navigation entre diapositives se fait par *flick* horizontal, par flèches, ou en suivant les liens de punaises (avec un fil d'Ariane « retour vers la diapositive parente »).
- Tout est **local au téléphone** : aucun réseau, aucun compte, aucune sauvegarde.

## 1.2 Stack technique existante

| Élément | Valeur |
|---|---|
| Framework | Silverlight for Windows Phone 8.1 (`TargetPlatformVersion` 8.1) |
| UI | XAML, `PhoneApplicationPage`, `ApplicationBar` (barre système WP) |
| Bibliothèques | `Windows Phone Controls Toolkit 4.2013.08.16`, `Microsoft.Xna.Framework.Media` (accès photothèque), `Microsoft.Phone.Tasks.PhotoChooserTask` |
| Persistance | `System.Xml.Serialization.XmlSerializer` → `ApplicationData.Current.LocalFolder` |
| Photos | Accès **par chemin** via `MediaLibrary.Pictures` / `Picture.GetPath()` |
| State | Classes statiques globales mutables |
| Tests | **Aucun** |
| CI | **Aucune** |

## 1.3 Arborescence et cartographie des fichiers

```
PhoneAppPhoto/
├── App.xaml(.cs)                  Amorçage, Frame racine, localisation
├── MainPage.xaml(.cs)             Écran 1 — Liste des albums
├── AjoutAlbum.xaml(.cs)           Écran 2 — Création d'album
├── PhotoVisualisationPage.*       Écran 3 — Visionneuse photo (lecture)
├── PhotoEditPage.*                Écran 4 — Éditeur photo (création de punaises)
├── CommentVisualisationPage.*     Écran 5 — Visionneuse commentaire (lecture)
├── CommentEditPage.*              Écran 6 — Éditeur commentaire
├── AjoutDiapo.xaml(.cs)           Écran 7 — Choix « Photo » ou « Commentaire »
├── ChoisirDiapoLink.xaml(.cs)     Écran 8 — Sélection de la diapo cible d'un lien
├── AllerADiapo.xaml(.cs)          Écran 9 — Aller à : Suivant / Précédent / Liste
├── AllerADiapoList.xaml(.cs)      Écran 10 — Liste de toutes les diapositives
├── ReorganizeAlbum.xaml(.cs)      Écran 11 — Réorganisation de l'ordre des diapositives
├── OverturesSettings.xaml(.cs)    Écran 12 — Réglages punaises (couleur, taille)
├── AlphaKeyGroup.cs               Groupement alphabétique A-Z (LongListSelector)
├── Modele/                        AlbumModele, DiapoModele, Ouverture(+3 sous-types)
├── ModeleVue/                     État global, sérialisation, utilitaires
├── Converteurs/                   3 IValueConverter
├── Images/, Toolkit.Content/      Assets (punaises, icônes de barre, tuiles)
└── Package.appxmanifest           Identité `22074thomas.gervaise.PhotoPushFree`
```

## 1.4 Modèle de données existant

```csharp
AlbumModele {
  string NomAlbum;
  List<DiapoModele> ListeDiapos;      // ORDRE = ordre d'affichage
  bool[50] IdDiapoDispoTab;            // table d'alloc d'ids (sérialisée !)
}

DiapoModele {
  int IdDiapo;                        // id LOCAL 0..49
  string TitreDiapo;                  // max 40 caractères
  string CheminImage;                 // CHEMIN FICHIER LOCAL de la photothèque
  string Commentaire;                 // texte libre, max 400
  List<Ouverture> ListeOuvertures;    // punaises
}

Ouverture {                            //.polymorphe via [XmlInclude]
  double PourcentageX, PourcentageY;  // ⚠ en PIXELS de l'écran, pas en %
  double TailleCarre;                 // 1..3 (slider)
  double LargeurPhotoInitiale;        // largeur RENDUE au moment du dépôt
  double HauteurPhotoInitiale;        // hauteur RENDUE au moment du dépôt
  string UriImageCarre;               // "carreNoir.png" … "carreViolet.png"
}
  ├── OuvertureTexte      { string TexteCible; }
  ├── OuvertureDiapo      { int IdDiapoCible; }
  └── OuvertureTexteDiapo { string TexteCible; int IdDiapoCible; }
```

### Formule de repositionnement des punaises (lisible dans le code)

Au rechargement d'une punaise (`PhotoEditPage.afficherLesCarres()`, ligne 246) :

```
taille  = 20 × zoomCourant × TailleCarre
marge.X = (offsetImageVersParent.X)
        + PourcentageX × zoomCourant × image.ActualWidth / LargeurPhotoInitiale
        − taille / 2
```

Deux conséquences majeures :

1. `PourcentageX` est en réalité **exprimé en pixels de l'écran** au moment du dépôt (`e.GetPosition(imageEnCours)`, ligne 447 de `PhotoEditPage.xaml.cs`).
2. Le repère dépend de la **taille d'écran du terminal, de l'état de la barre d'application et du zoom courant**.

> **Conséquence directe : la donnée n'est pas portable.** Elle ne peut pas être synchronisée entre appareils. C'est le correctif structurant n°1 de la réécriture (cf. § 5.2).

## 1.5 Persistance existante

| Élément | Emplacement | Format |
|---|---|---|
| Un album = un fichier | `LocalFolder/albumsPhoto/<NomAlbum>` (le **nom de fichier est le nom de l'album**) | XML `XmlSerializer` |
| Index des albums | `LocalFolder/listeAlbumsPhoto` | XML `List<DataItem>` (clé = nom d'album, valeur = `[cheminPhotoDeCouverture, titreDiapo1]`) |
| Photos | **Hors application** — photothèque du téléphone | référencées par `Picture.GetPath()` |

Flux d'écriture : `SerialisationUtilitaires.sauvegarderAlbumDiapo()` sérialise l'`AlbumModele` courant, puis, si `ChangementPremiereImage`, met à jour `listeAlbumsPhoto`.

Flux de lecture : `MainPage.ouvertureAlbum()` désérialise puis positionne les singletons `GestionAlbumModele` / `GestionVueDiapo`.

## 1.6 Mécanique de navigation (à l'identique)

Le livre est piloté par des **singletons statiques** mutables :

| Classe | Rôle |
|---|---|
| `GestionAlbumModele.albumModele` | Album courant |
| `GestionVueDiapo.DiapoCourante` | Diapositive courante |
| `GestionVueDiapo.CheminOuvertureDiapoLink` | Pile des diapositives parentes (fil d'Ariane) |
| `GestionVueDiapo.ASauvegarder` | Drapeau « album modifié » (icône de sauvegarde qui change) |
| `GestionVueDiapo.CacherPins` | Punaises masquées |
| `GestionVueDiapo.EditMode` | Édition vs lecture (redirige `AllerADiapo*`) |
| `GestionVueDiapo.EffectuerActionsChangementEtatBarre` | Verrou anti-rebond de la barre d'application |
| `GestionVueDiapo.TotallyDeployedApplicationBar` | Barre masquée / en mode compact |
| `GestionVueDiapo.UriImageCarres` / `TailleCarres` | Réglages punaises (**non persistés**) |
| `GestionVueDiapo.IdDiapoDispoTab` via `AlbumModele` | Allocation d'id |
| `Bridage` | Limites : 8 albums, 12 diapos, 5 punaises/diapo |

## 1.7 Table des orientations des `ApplicationBar` (comportement à reproduire)

| Écran | Boutons (icônes) | Menu |
|---|---|---|
| `MainPage` | `+` Ajouter un album | — |
| `PhotoVisualisationPage` | `✎` Éditer · `⊙` Recentrer · `◻` Masquer/Afficher les punaises | Show comment · Go to slide · Add slide |
| `PhotoEditPage` | `+` Ajouter une diapo · `👁` Visualiser · `⊙` Recentrer · `💾` Sauver | Delete photo slide · Add/Edit comment · Reorganize album · Push pins settings |
| `CommentVisualisationPage` | `✎` Éditer | Show photo · Go to slide · Add slide |
| `CommentEditPage` | `+` Ajouter une diapo · `👁` Visualiser · `💾` Sauver | Delete comment slide · Add/Edit photo · Reorganize album |

Quand la barre est masquée (paysage, ou appui sur le bouton `⋯`), des **boutons flottants** rotationnels apparaissent : `⋯` (rouvrir le menu), `💬` (commentaire), `🖼` (photo), `↩` (punaise de retour diapo parente).

## 1.8 Limites « bridage » existantes

`Bridage.cs` : `nbMaxAlbum = 8`, `nbMaxDiapo = 12`, `nbMaxOuverture = 5`.
Ces limites sont des vestiges de la version *Free* de l'application et sont affichées via `MessageBox`.

## 1.9 Défauts et dettes techniques relevés (à traiter)

| # | Défaut | Impact | Décision v1 |
|---|---|---|---|
| D1 | Singleton statique global pour tout l'état applicatif | Non testable, pas d'isolément, coroutine/navigation fragile | **Corrigé** — état par album dans un `AlbumController`/`ChangeNotifier` scopé |
| D2 | Coordonnées de punaises en pixels écran | **Bloquant pour la synchro** | **Corrigé** — coordonnées normalisées 0..1 sur l'image intrinsèque (§ 5.2) |
| D3 | `CheminImage` = chemin photothèque | L'album casse si l'utilisateur supprime la photo (d'où l'écran « Image not found ») | **Corrigé** — copie des médias dans le sandbox applicatif |
| D4 | `bool[50] IdDiapoDispoTab` sérialisé, non reconstruit au chargement | Collision d'`IdDiapo`, plafond à 50 diapos | **Corrigé** — UUID |
| D5 | Polymorphisme XML `[XmlInclude]` fragile ; `catch (InvalidOperationException)` avec le commentaire *« bug incompris »* dans `SerialisationUtilitaires:40` | **Perte de données d'album** lors de désérialisation | **Éliminé** — aucun XML dans la nouvelle application : schéma plat, typage explicite, transactions SQLite (cf. § 5.1) |
| D6 | `sauvegarderAlbumDiapo(ApplicationBarIconButton)` | Couche de persistance dépendante de la vue | **Corrigé** |
| D7 | `rafraichirEcran()` = `Task.Delay(500 ms)` puis recréation des `Image` | Perte de fluidité, clignotement des punaises | **Corrigé** — widgets persistants + `Matrix4` |
| D8 | `ApplicationBar.Buttons[2]`, `RemoveAt(0)` sans garde | `ArgumentOutOfRangeException` dès que l'état dérive | **Corrigé** — barre déclarative |
| D9 | `bouton.Click += handler` ajouté à chaque bascule image trouvée/pertinue | Fuite de handlers, clic déclenche N fois | **Corrigé** |
| D10 | Réglages punaises en statique, jamais persistés | Perdus au redémarrage | **Corrigé** |
| D11 | `MainPage.BackKeyPress` ne pose pas `e.Cancel = true` | Comportement de retour non conforme | **Corrigé** |
| D12 | `CheminToImageConverter` : cache de 8 bitmaps dans un tableau fixe, `nettoyerTab…` en cours d'itération | Fuite mémoire, images manquantes | **Corrigé** — cache LRU + `cached_network_image` |
| D13 | Chaînes en dur en anglais, `LocalizedStrings` inutilisé, `AppResources.resx` vide | Pas d'i18n | **Corrigé** — fr + en via ARB |
| D14 | Aucun test, aucune CI | — | **Corrigé** |
| D15 | `nbMaxDiapo=12` contredit `IdDiapoDispoTab[50]` | Incohérence | Limites **configurables**, voir § 4.7 |

---

# 2. Objectifs et périmètre

## 2.1 Objectifs du projet

| ID | Priorité | Objectif |
|---|---|---|
| **OBJ-1** | P0 | **Fonctionner intégralement hors ligne**, sans compte ni serveur — toutes les fonctions des chapitres 3 et 4 |
| **OBJ-2** | P0 | Réécrire l'application en Flutter (Android + iOS) en conservant l'intégralité des **usages** de la version WP8 |
| **OBJ-3** | P0 | Supprimer les défauts structurants D1→D15 |
| **OBJ-4** | P0 | Rendre les albums **persistants et portables** (les médias sont stockés par l'application, pas référencés) |
| **OBJ-5** | P0 | Supprimer les limites artificielles ou les rendre configurables |
| **OBJ-6** | P0 | Fournir une base testable et maintenable (tests, CI, architecture en couches) |
| **OBJ-7** | P1 | Ajouter, **en option**, un mode compte + serveur permettant sauvegarde, restauration et synchronisation entre appareils |
| **OBJ-8** | P1 | Ne **pas** être compatible avec le format de données WP8 : l'application définit son propre format, sans XML |

> Hiérarchie de livraison : **P0 = l'application hors ligne, livrable seule et complète**. Le P1 (serveur + synchro) est un complément greffable ; l'application P0 doit être publiable en l'état, et le serveur déployable indépendamment, ou pas du tout.

## 2.2 Périmètre — cœur (P0, hors ligne, obligatoire)

- Albums : création, renommage, suppression (corbeille + restauration), réorganisation.
- Diapositives : ajout (photo / commentaire), modification, suppression, réorganisation, affichage en grille.
- Punaises : création par appui, déplacement par zoom/pan, édition du texte, création/modification/suppression de liens, réglages couleur et taille, masquage global.
- Visionneuse : zoom/pan, navigation par liens avec fil d'Ariane, plein écran, masquage de la barre.
- Import de photos depuis la galerie / l'appareil photo, avec copie dans le sandbox applicatif.
- Export / import d'une archive `.photopush` (portabilité, sans réseau).

**Aucune de ces lignes ne dépend du réseau.** Elles constituent la recette de la Phase 1 (§ 12).

## 2.3 Périmètre — extension (P1, en ligne, optionnel)

- Comptes, serveur de synchronisation, sauvegarde/restauration cloud, multi-appareils.
- Fonctionne **en plus** du cœur ; si l'utilisateur ne crée jamais de compte, il ne perd rien (§ 7.1).

## 2.4 Hors périmètre (exclu, y compris de la v1)

- **Compatibilité de format avec le WP8** : lecture, écriture, import de XML legacy dans l'application (cf. § 11, purement documentaire).
- Partage d'albums en lecture seule via lien public.
- Annotation/dessin sur les photos.
- Export PDF / vidéo.
- Chiffrement de bout en bout des médias (cf. § 9.4 pour la trajectoire).
- Version tablette/PC optimisée (le *layout* tablette est prévu mais non exigé en v1).
- Prise de photo via l'appareil photo intégrée de l'OS (v1 utilise le sélecteur système + import de la photothèque, avec l'appareil photo **S**).

---

# 3. Périmètre fonctionnel détaillé

## 3.1 Écran 1 — Liste des albums (`AlbumListScreen`)

| ID | Exigence | Priorité |
|---|---|---|
| RF-01 | Afficher la liste des albums de l'utilisateur, **groupés par initiale** (A→Z, regroupement alphabétique, tri insensible à la casse et aux accents) | M |
| RF-02 | Chaque vignette affiche : **photo de couverture** (première diapositive possédant une image) ou le **titre de la diapositive 1** à défaut, + nom de l'album | M |
| RF-03 | La vignette de couverture est une **miniature 60×60** décodée à partir d'un cache local ; jamais de décodage du fichier plein résolution sur le fil principal | M |
| RF-04 | Le nom affiché est le nom réel ; le nom de fichier interne est un UUID (§ 5.3) | M |
| RF-05 | Si la liste est vide, afficher le texte d'accueil d'origine : *« Tap on **+** button to create a slides album including photos and comments. / Note that you can add pins on photos to create pop-up comments or slide links. »* | M |
| RF-06 | Appui sur un album → ouvrir la 1ʳᵉ diapositive en visionneuse ; si l'album est vide → ouvrir l'éditeur | M |
| RF-07 | Menu contextuel par appui long sur la vignette : **Renommer**, **Dupliquer**, **Corbeille** | M |
| RF-08 | Suppression → move to trash avec confirmation ; restauration depuis la corbeille ; purge après 30 jours | M |
| RF-09 | Barre d'application : `+` (nouvel album), `↻` (synchroniser), `⚙` (réglages) | M |
| RF-10 | Indicateur d'état de synchronisation par album : `—` (à synchroniser) / `⟳` (en cours) / `✓` (à jour) / `⚠` (erreur, avec détail au tap) | S |
| RF-11 | Champ de recherche sur le nom d'album | S |
| RF-12 | Badge « à jour » global dans l'en-tête si aucun élément en attente | C |

## 3.2 Écran 2 — Création / renommage d'album

| ID | Exigence | Priorité |
|---|---|---|
| RF-13 | Saisie du nom ; validation par « Entrée » ou bouton ; focus automatique à l'ouverture | M |
| RF-14 | Le nom est **trimé** ; longueur 1..80 caractères ; caractères de contrôle et séparateurs de chemin interdits (`/ \ : * ? " < > \|`) | M |
| RF-15 | Si un album porte déjà ce nom (insensible à la casse) → message *« An album with the same name already exists. »* et création annulée | M |
| RF-16 | Deux albums peuvent avoir des noms différents se normalisant vers le même UUID interne ; l'unicité porte sur le nom au sein du compte | M |
| RF-17 | Le clavier virtuel propose le type `FileName` (équivalent du `InputScope` existant) | S |
| RF-18 | À la création, on enchaîne directement sur l'éditeur de diapositives | M |

## 3.3 Écran 3 — Visionneuse photo (`SlideViewerScreen`, mode photo)

| ID | Exigence | Priorité |
|---|---|---|
| RF-20 | Afficher la diapositive courante (image plein écran) + titre + pagination `n/total` cliquable | M |
| RF-21 | **Zoom au pincement** (1×..max 6×) et **pan** à deux doigts ; convention : le zoom est ancré au centre de pincement | M |
| RF-22 | **Flick horizontal** → diapositive suivante / précédente avec **bouclage** (dernière → première) | M |
| RF-23 | **Boutons fléchés** semi-transparents affichés en bas à gauche/droite pendant 1 s après un pan, masqués ensuite ; absents si l'album ne contient qu'une diapositive | M |
| RF-24 | **Appui sur la punaise** : si la punaise porte un texte → afficher la bulle ; si elle pointe vers une diapositive sans texte → naviguer ; si elle porte les deux → afficher la bulle et armer la navigation | M |
| RF-25 | **Appui sur la bulle** : si la punaise a une cible → naviguer vers la diapositive cible ; sinon fermer la bulle | M |
| RF-26 | **Appui hors bulle** : fermer la bulle (avec aller-retour au tap suivant sur la punaise) | M |
| RF-27 | Bouton `↩` (punaise « diapositive parente ») visible si et seulement si la pile de liens n'est pas vide ; retour à la diapositive parente | M |
| RF-28 | Le bouton `↩` est masqué après tout changement de diapositive par flick/flèche | M |
| RF-29 | Bouton `◻` / `👁` : masquer / afficher toutes les punaises de la diapositive courante ; l'état est conservé en navigation | M |
| RF-30 | Si la diapositive n'a ni punaises ni commentaire, le bouton masquer/afficher n'est pas affiché | M |
| RF-31 | Les punaises sont **repositionnées** selon le zoom/pan/transformation courante à chaque frame, sans latence perçue | M |
| RF-32 | Barre d'application masquable (`. . .` / appui sur l'espace vide) → mode immersion, titre masqué, boutons flottants | M |
| RF-33 | En **portrait** l'image est ajustée à l'écran (letterbox) ; en **paysage** elle passe en plein écran et la barre système disparaît | M |
| RF-34 | La rotation de l'appareil est supportée à chaud ; punaises, boutons flottants et barre se repositionnent sans rechargement de l'image | M |
| RF-35 | `↺` **Recentrer** : remet le zoom à 1× et la translation à zéro | M |
| RF-36 | Si le média est absent du sandbox local (fichier supprimé hors application) → afficher l'état **« Image not found »** et transformer le bouton `↺` en `📷` **Ajouter une photo** | M |
| RF-37 | Barre : `✎` Éditer · `↺` Recentrer · `◻` Punaises · menu *Afficher le commentaire* / *Aller à la diapositive* / *Ajouter une diapositive* | M |
| RF-38 | Retour arrière : si l'album est modifié → boîte de dialogue *« The album has been modified / Do you want to save changes ? »* (Oui / Non / Annuler) | M |

## 3.4 Écran 4 — Éditeur photo (`SlideEditorScreen`, mode édition)

| ID | Exigence | Priorité |
|---|---|---|
| RF-40 | Titre de diapositive éditable ; longueur max **40** ; mise à jour immédiate de la liste | M |
| RF-41 | **Appui sur l'image** → crée une punaise à l'endroit exact du doigt (coordonnée normalisée) et ouvre le menu contextuel de la punaise | M |
| RF-42 | Menu contextuel de punaise : **Ajouter une zone de texte**, **Ajouter un lien de diapositive**, **Supprimer** | M |
| RF-43 | Le libellé devient *« Modifier… »* quand la punaise est déjà du bon type | M |
| RF-44 | **Ajouter une zone de texte** : la punaise devient une `textPin` ; une zone de saisie multi-lignes apparaît à sa position, max **400 caractères**, liaison bi-directionnelle immédiate | M |
| RF-45 | La zone de texte ouverte masque les 3 premiers boutons de la barre et les remplace par un bouton `🗑 Supprimer le texte` | M |
| RF-46 | À la fermeture, la punaise texte passe **au-dessus** des autres (dernier de la liste) | M |
| RF-47 | **Supprimer le texte** : la punaise redevient une punaise neutre (le texte est perdu, la position est conservée) | M |
| RF-48 | **Ajouter un lien de diapositive** : ouvre le sélecteur de cible, qui **exclut la diapositive courante** | M |
| RF-49 | Le sélecteur de cible affiche les autres diapositives groupées par ordre, avec **miniature + numéro + titre** | M |
| RF-50 | Appuyer sur la diapositive **déjà ciblée** **retire le lien** (bascule on/off) | M |
| RF-51 | Un appui sur l'image **alors que la zone de texte est ouverte** ferme la zone de texte sans créer de punaise | M |
| RF-52 | Plafond de punaises configurable (§ 4.7) ; au-delà, message explicite | M |
| RF-53 | Les punaises suivent le zoom/pan en temps réel ; elles restent cliquables à l'échelle réduite | M |
| RF-54 | `+` Ajouter une diapositive (surchargé si album plein) | M |
| RF-55 | `👁` Visualiser → bascule en visionneuse | M |
| RF-56 | `↺` Recentrer / `📷` Ajouter une photo si média absent | M |
| RF-57 | `💾` Sauver : **l'icône change** (disponible → « à sauvegarder ») dès la première modification, et revient après sauvegarde | M |
| RF-58 | Menu : *Supprimer la photo* · *Ajouter/Modifier le commentaire* · *Réorganiser l'album* · *Réglages des punaises* | M |
| RF-59 | **Supprimer la photo** : efface l'image **et toutes les punaises** ; si la diapositive porte un commentaire elle est conservée, sinon elle est supprimée et la sélection passe à la diapositive suivante | M |
| RF-60 | Barre masquable, boutons flottants `⋯`, `💬`, rotation gérée comme en visionneuse | M |
| RF-61 | Si l'album n'a aucune diapositive : barre réduite au bouton `+` et affichage du texte d'aide *« Tap on + button to create a slide: photo or comment. / Push photos to create pop-up comments or slide links. »* | M |

## 3.5 Écran 5 — Visionneuse commentaire (`SlideViewerScreen`, mode commentaire)

| ID | Exigence | Priorité |
|---|---|---|
| RF-70 | Afficher le titre (police 32 en barre visible, 28 en mode immersion) et le texte du commentaire en Integral/Big scrollable | M |
| RF-71 | Flick horizontal → diapositive suivante/précédente avec bouclage | M |
| RF-72 | Boutons fléchés transitoires (1 s) au défilement ; absents si album à 1 diapositive | M |
| RF-73 | Bouton flottant `🖼` **Afficher la photo** : visible seulement si la diapositive possède une image ; navigue vers la visionneuse photo | M |
| RF-74 | Bouton flottant `↩` de retour diapo parente, même règle que RF-27 | M |
| RF-75 | Au changement de diapositive vers une diapositive **sans commentaire**, basculer automatiquement vers la visionneuse photo (ou l'éditeur si l'on était en édition) | M |
| RF-76 | Barre : `✎` Éditer · menu *Afficher la photo* / *Aller à la diapositive* / *Ajouter une diapositive* | M |

## 3.6 Écran 6 — Éditeur commentaire (`CommentEditorScreen`)

| ID | Exigence | Priorité |
|---|---|---|
| RF-80 | Zone de saisie multi-lignes, max 400 caractères, focus automatique à l'ouverture | M |
| RF-81 | Titre de diapositive éditable (max 40) | M |
| RF-82 | Flick horizontal pour changer de diapositive en restant en édition | M |
| RF-83 | Barre : `+` Ajouter une diapositive · `👁` Visualiser · `💾` Sauver | M |
| RF-84 | Menu : *Supprimer le commentaire* · *Ajouter/Modifier la photo* · *Réorganiser l'album* | M |
| RF-85 | *Supprimer le commentaire* : si la diapositive a une photo elle est conservée, sinon elle est supprimée | M |
| RF-86 | *Ajouter la photo* sur une diapositive sans image ouvre directement le sélecteur de média | M |
| RF-87 | Le compteur de caractères restants est affiché au-delà de 350 | S |

## 3.7 Écran 7 — Ajouter une diapositive

| ID | Exigence | Priorité |
|---|---|---|
| RF-90 | Deux choix : **Photo** ou **Commentaire** | M |
| RF-91 | *Photo* → ouvre le sélecteur système avec la **caméra activée** (équivalent de `ShowCamera = true`) | M |
| RF-92 | La nouvelle diapositive est **insérée après la diapositive courante** | M |
| RF-93 | Titre par défaut : `"Title " + (index + 1)` (index 1-based dans l'album) | M |
| RF-94 | *Commentaire* → crée une diapositive vide, bascule immédiatement vers l'éditeur de commentaire | M |
| RF-95 | Après ajout, retour en édition ; si la diapositive insérée devient la première, la **couverture de l'album** est recalculée | M |
| RF-96 | L'import depuis la galerie doit être **copié** dans le sandbox applicatif (§ 5.4) | M |

## 3.8 Écran 8 — Réglages des punaises

| ID | Exigence | Priorité |
|---|---|---|
| RF-100 | 6 couleurs : **noir, blanc, vert, jaune, bleu, violet** (équivalent de `carreNoir/Blanc/Vert/Jaune/Bleu/Violet.png`) | M |
| RF-101 | Taille : curseur **1..3**, par pas de 0.5, valeur par défaut 1 | M |
| RF-102 | La sélection d'une couleur se fait au **tap** (le `MouseEnter` de l'existant est un défaut tactile) | M |
| RF-103 | Aperçu du réglage appliqué | S |
| RF-104 | **Les réglages sont persistés** (device-local) et restaurés au redémarrage — corrige D10 | M |
| RF-105 | Réglages s'appliquent aux punaises **créées ensuite** ; les punaises existantes conservent leur couleur/taille | M |
| RF-106 | Bouton « appliquer à la diapositive courante » | C |

## 3.9 Écran 9 — Réorganiser l'album

| ID | Exigence | Priorité |
|---|---|---|
| RF-110 | Liste ordonnée de toutes les diapositives : **numéro**, vignette, type (photo/commentaire), titre, nb de punaises | M |
| RF-111 | **Réordonner par glisser-déposer** (l'existant utilisait un « sélectionner puis taper la cible », peu utilisable au doigt) — le mode séquentiel « sélectionner puis cible » est conservé en alternative | M |
| RF-112 | Supprimer une diapositive (menu contextuel) avec confirmation ; les liens de punaises pointant vers cette diapositive deviennent **dangling** (voir RF-113) | M |
| RF-113 | Un lien vers une diapositive supprimée est conservé en base mais signalé à l'utilisateur ; au rendu, l'appui affiche « Cette diapositive n'existe plus » | M |
| RF-114 | Si la diapositive déplacée est la première, recalculer la couverture d'album | M |
| RF-115 | La liste est **plate ordonnée** (pas de regroupement alphabétique, contrairement à l'existant qui groupait par *index* converti en chaîne) | M |

## 3.10 Écran 10 — Aller à la diapositive

| ID | Exigence | Priorité |
|---|---|---|
| RF-120 | Menu : **Suivant** · **Précédent** · **Liste des diapositives** | M |
| RF-121 | L'écran *Liste* affiche toutes les diapositives groupées alphabétiquement par **titre**, avec numéro et vignette | M |
| RF-122 | Après sélection, retour vers l'écran correspondant au **mode courant** (édition → éditeur ; lecture → visionneuse) et diapositive de même nature (photo/commentaire) | M |
| RF-123 | Depuis la visionneuse, la sélection depuis la liste **remet la pile de liens à zéro** | M |

## 3.11 Fonctionnalités transverses

| ID | Exigence | Priorité |
|---|---|---|
| RF-130 | Sauvegarde automatique de l'album courant 1,5 s après la dernière modification, en plus de la sauvegarde manuelle | M |
| RF-131 | Sauvegarde manuelle disponible **uniquement** s'il y a des modifications non sauvegardées | M |
| RF-136 | État « album modifié » tracké par diapositive (et non globalement) | M |
| RF-137 | **Corbeille** : albums et diapositives supprimés récupérables 30 jours ; la corbeille est **synchronisée** | M |
| RF-138 | Thème sombre (fidèle à l'existant, fond noir) ; thème clair **S** | S |
| RF-139 | **Internationalisation** : `fr` (par défaut) et `en`, via ARB + `gen-l10n` | M |
| RF-140 | Support d/accessibilité : cibles tactiles ≥ 48 dp, contraste ≥ 4.5:1, libellés VoiceOver/TalkBack, aucune information transmise par la couleur seule | M |
| RF-141 | Zoom système (taille de police) respecté jusqu'à 200 % sans troncage critique | M |
| RF-142 | **Export** d'un album en archive `.photopush` (ZIP : `album.json` + `media/*`) — socle de la portabilité et du partage | S |
| RF-143 | **Import** d'une archive `.photopush` | S |
| RF-144 | Thème de l'application, réglages punaises et position de lecture sont **device-local** (non synchronisés) | M |

---

# 4. Règles métier à formaliser

## 4.1 Types de diapositive

```
SlideKind = photo | comment
```

Règles :

- `photo` : `assetId` non nul.
- `comment` : `commentText` non vide après trim.
- Une diapositive **doit** satisfaire au moins une des deux, sinon elle est **invalide** et ne peut être enregistrée.
- `photo + comment` est autorisé (cas le plus courant).

> Règle de routage (remplace les `if (CheminImage == null)` de l'existant) :
> à l'ouverture d'une diapositive, on route vers la **visionneuse photo si `assetId != null`**, sinon vers la **visionneuse commentaire**. L'éditeur est routé de même.

## 4.2 Types de punaise

Remplacement de l'héritage C# par une **union discriminée** (casse switchable Dart) :

```
PinKind = neutral | text | link | textLink
```

| `kind` | `text` | `targetSlideId` | ÉquivalentWP8 |
|---|---|---|---|
| `neutral` | — | — | `Ouverture` |
| `text` | oui | — | `OuvertureTexte` |
| `link` | — | oui | `OuvertureDiapo` |
| `textLink` | oui | oui | `OuvertureTexteDiapo` |

Transitions autorisées (matrice de conversion) :

| Depuis \ Vers | `neutral` | `text` | `link` | `textLink` |
|---|---|---|---|---|
| `neutral` | — | conserve pos. | conserve pos. | conserve pos. |
| `text` | efface le texte | — | conserve texte + pos. | conserve texte + pos. |
| `link` | retire la cible | conserve pos. | — | conserve pos. |
| `textLink` | retire cible | retire cible + texte | retire texte | — |

> Toute conversion **préserve la position, la taille et la couleur**. C'est une correction du comportement actuel, où la suppression du texte reconstruisait un objet et perdait silencieusement des champs.

## 4.3 Punaises — règles de placement

| ID | Règle |
|---|---|
| R-01 | La position est stockée **normalisée** dans l'espace de l'image intrinsèque : `x ∈ [0,1]`, `y ∈ [0,1]`, origine = coin haut-gauche du cadre **contenu** de l'image. |
| R-02 | Au dépôt, `x = (pointeur.x - imageDisplayRect.left) / imageDisplayRect.width`, borné à `[0,1]`. Idem pour `y` avec la hauteur. |
| R-03 | Le point d'ancrage de la punaise est son **centre**. |
| R-04 | `sizeScale ∈ [1.0, 3.0]`, pas de 0.5. Taille rendue = `20 × sizeScale × scaleCourant` (en dp logiques). |
| R-05 | Les punaises suivent le zoom et le pan en temps réel, y compris lorsque l'image est rognée par les bords de l'écran. |
| R-06 | `zIndex` entier croissant ; une punaise texte ouverte est déplacée en dernier. |
| R-07 | Deux punaises peuvent se superposer ; la dernière `zIndex` intercepte le tactile. |
| R-08 | Les coordonnées sont **indépendantes de l'appareil** : un album synchronisé affiche les punaises au même endroit relatif sur tout écran. |

## 4.4 Navigation dans l'album

| ID | Règle |
|---|---|
| R-10 | L'ordre des diapositives est **total et stable** : `(position, id)`. |
| R-11 | Le parcours par flick/flèches **boucle** (dernière → première). |
| R-12 | Suivre un lien `link`/`textLink` empile la diapositive courante sur `navigationStack` et navigue. |
| R-13 | Le bouton `↩` dépile ; il disparaît quand la pile est vide. |
| R-14 | Toute navigation **hors lien** (flick, flèche, liste) réinitialise `navigationStack`. |
| R-15 | Les cycles de liens sont autorisés (A→B→A) ; la pile peut donc croître. Protection : détection d'un lien vers la diapositive de sommet de pile → animation de retour automatique. |

## 4.5 Couverture d'album

| ID | Règle |
|---|---|
| R-20 | La couverture = `cheminImage` de la **première diapositive** dont l'image est disponible. |
| R-21 | Si aucune diapositive n'a d'image, la vignette affiche le **titre de la diapositive 1** ; si l'album est vide, un pictogramme. |
| R-22 | La couverture est recalculée quand la 1ʳᵉ diapositive change, quand elle perd son image, ou au réordonnancement. |
| R-23 | La couverture est **persistée** (champ `coverAssetId`) et **synchronisée**, afin de ne pas charger toutes les vignettes à l'ouverture de la liste. |

## 4.6 Sauvegarde et état « modifié »

| ID | Règle |
|---|---|
| R-30 | Le drapeau « à sauvegarder » est **par diapositive** + un drapeau `album` (nom modifié, ordre modifié, diapo supprimée). |
| R-31 | Sauvegarde automatique 1,5 s après la dernière modification (debounce) — *améliore l'existant, qui perdait tout si l'app était tuée*. |
| R-32 | Le retour arrière depuis un album modifié propose *Enregistrer / Ne pas enregistrer / Annuler*. |
| R-33 | En l'absence de modification, le retour arrière va directement à la liste des albums. |
| R-34 | La position de lecture courante n'est **pas** sauvegardée (choix produit). |

## 4.7 Limites configurables (`AppLimits`)

Les limites « Free » de l'existant (8 albums, 12 diapos, 5 punaises) sont **supprimées** (D15). Les plafonds ci-dessous ne servent qu'à protéger l'utilisateur d'une erreur de saisie et les performances ; ce sont des constantes de compilation, largement au-dessus des usages réels.

| ID | Exigence | Défaut | Priorité |
|---|---|---|---|
| R-40 | Limites **enlevées de l'existant** (versions « Free ») | — | M |
| LIM-01 | `maxAlbumsPerUser` | 500 | M |
| LIM-02 | `maxSlidesPerAlbum` | 200 | M |
| LIM-03 | `maxPinsPerSlide` | 30 | M |
| LIM-04 | `maxCommentLength` | 400 | M |
| LIM-05 | `maxSlideTitleLength` | 40 | M |
| LIM-06 | `maxAlbumNameLength` | 80 | M |
| LIM-07 | `maxAlbumNameLength` (serveur, aligné) | 80 | M |

Ces valeurs sont des constantes de compilation ; la section « Réglages » expose les 3 premières pour information. **Hors ligne, aucune de ces limites n'est renforcée par un serveur.** En mode connecté, le compte serveur peut imposer des valeurs **plus basses** (quota) — voir § 7.12.

---

# 5. Corrections structurantes du modèle de données

## 5.1 Vue d'ensemble

> Ce tableau est un **mapping de concepts** (pour comprendre l'historique et justifier les corrections), pas une compatibilité de format. Le modèle de droite est entièrement nouveau et n'a aucun lien de structure avec celui de gauche.

```
AVANT (WP8) — pour mémoire                APRÈS (Flutter) — nouveau modèle
─────────────────────────────         ─────────────────────────────────
AlbumModele                          Album
  NomAlbum (string)                    id: Uuid
  ListeDiapos (liste ordonnée)          name: String
  bool[50] IdDiapoDispoTab              coverAssetId: Uuid?
                                       order: OrderKey        ← fractionnaire
DiapoModele                             hlc: Hlc              ← horloge logique
  IdDiapo (int local 0..49)             deletedAt: DateTime?
  TitreDiapo (string)                 Slide
  CheminImage (chemin local)            id: Uuid
  Commentaire (string)                  albumId: Uuid
  ListeOuvertures                       kind: SlideKind
                                       title: String
                                       commentText: String?
  Ouverture (3 sous-classes)            assetId: Uuid?
  Ouverture.PourcentageX (px écran)     order: OrderKey
  Ouverture.PourcentageY (px écran)     hlc: Hlc
  Ouverture.TailleCarre (1..3)          deletedAt: DateTime?
  Ouverture.LargeurPhotoInitiale      Pin
  Ouverture.HauteurPhotoInitiale        id: Uuid
  Ouverture.UriImageCarre (fichier)     slideId: Uuid
                                         x: double (0..1)     ← NORMALISÉ
  OuvertureTexte.TexteCible             y: double (0..1)     ← NORMALISÉ
  OuvertureDiapo.IdDiapoCible (int)     sizeScale: double (1..3)
                                         color: PinColor
                                         kind: PinKind
                                         text: String?
                                         targetSlideId: Uuid?
                                         zIndex: int
                                         hlc: Hlc
                                         deletedAt: DateTime?

Media (inexistant)                   Asset
                                       id: Uuid
                                       sha256: String       ← DÉDUPLICATION
                                       mimeType: String
                                       byteSize: int
                                       width, height: int
                                       capturedAt: DateTime?
                                       originalName: String?
                                       createdAt: DateTime
                                       (octets → stockage objet)
```

## 5.2 Correction D2 — Coordonnées de punaises (impact critique)

**Règle** : une punaise ne connaît que des ratios.

**Dépôt** (`x`, `y` en 0..1) :

```
dx = toucheX - imageDisplayRect.left
dy = toucheY - imageDisplayRect.top
x  = clamp(dx / imageDisplayRect.width , 0, 1)
y  = clamp(dy / imageDisplayRect.height, 0, 1)
```

**Restitution** :

```
pinSize = 20 * pin.sizeScale * currentScale
left    = imageDisplayRect.left + pin.x * imageDisplayRect.width  - pinSize / 2
top     = imageDisplayRect.top  + pin.y * imageDisplayRect.height - pinSize / 2
```

Le `imageDisplayRect` est calculé par `BoxFit`-equivalent (contain) à partir de la taille intrinsèque de l'image et de la boîte d'affichage. Le rendu passe par un `Stack` + `Transform` (`Matrix4` de translation/échelle) : une seule transformation, les punaises sont positionnées relativement, aucun recalcul par frame côté métier.

**Test d'acceptation** : un album créé sur un écran 480×800 puis synchronisé sur un écran 1080×2400 doit afficher les punaises aux **mêmes positions relatives** (± 1 %).

## 5.3 Identifiants

- `id`, `albumId`, `slideId`, `pinId`, `assetId` : **UUID v7** (tri par temps, donc indexables et lisibles en tri).
- `OrderKey` : **indexation fractionnaire** (voir § 6.3).
- Suppression des `IdDiapo` entiers : plus de collision, plus de `bool[50]`.

## 5.4 Médias — copie dans le sandbox (correction D3)

À l'import d'une photo :

1. Copier le fichier source dans `{appDocuments}/media/{assetId}` (extension d'origine conservée).
2. Calculer `sha256` des octets **avant** la copie (streaming, 1 Mio de buffer).
3. Générer à la demande et **mettre en cache** :
   - `thumb` 120×120 (couverture d'album) ;
   - `preview` au côté long 2048 px (visionneuse plein écran) ;
   - l'original est utilisé pour l'export.
4. Si le même `sha256` existe déjà localement → **réutiliser le fichier existant** (pas de doublon).

Conséquences :

- L'album survit à la suppression de la photo dans la photothèque.
- L'import initial allonge le temps de réponse (copie) → afficher une progression ; l'original WP8 référençait sans copier.
- Un média absent du sandbox déclenche l'état « Image not found » (RF-36) — cas résiduel : purge du cache par l'OS, fichier corrompu, ou disque plein au moment de l'import.

## 5.5 Ce qui est conservé de l'existant

> On conserve les **usages**, pas le format de stockage : aucun fichier XML, aucun nom de fichier = nom d'album, aucun chemin photothèque.

| Élément | Conservation |
|---|---|
| 6 couleurs de punaises | ✓ RF-100 |
| Tailles 1..3, base 20 px | ✓ R-04 |
| Max 400 caractères de commentaire | ✓ LIM-04 |
| Max 40 caractères de titre de diapo | ✓ LIM-05 |
| Bouclage de la navigation par flick | ✓ R-11 |
| Fil d'Ariane « retour diapo parente » | ✓ R-12/13 |
| Masquage de la barre + boutons flottants rotatifs | ✓ RF-32, RF-60 |
| Textes d'accueil et messages d'erreur d'origine | ✓ RF-05, RF-15, RF-38 |
| Appels d'outils fluorés d'origine | ✓ RF-138 |

---

# 6. Architecture cible

## 6.1 Organisation du dépôt (monorepo)

```
photo_push/
├── apps/
│   ├── mobile/                       Application Flutter
│   │   ├── lib/
│   │   │   ├── app/                  MaterialApp, routes, thème, i18n
│   │   │   ├── features/
│   │   │   │   ├── albums/           écran liste + création + corbeille
│   │   │   │   ├── slides/           viewer, editor, add, reorder, goto
│   │   │   │   ├── pins/             pin_settings, pin_target_picker
│   │   │   │   ├── settings/         réglages, compte, à propos
│   │   │   │   └── auth/             onboarding, login, register
│   │   │   ├── l10n/                 .arb (fr, en)
│   │   │   └── bootstrap.dart
│   │   ├── test/  integration_test/  golden/  assets/
│   │   ├── pubspec.yaml
│   │   └── android/  ios/
│   └── (optionnel) admin_web/        console d'administration (post-v1)
│
├── packages/
│   ├── pp_domain/                    Modèles purs, règles, maths punaises
│   │                                 (aucune dépendance I/O)
│   ├── pp_data/                      Drift/SQLite, DAOs, migrations
│   ├── pp_media/                     Import, hachage, vignettes, cache LRU
│   ├── pp_ui/                        Design system, widgets partagés
│   │
│   ├── pp_sync/                      Moteur de synchro, outbox, HLC, LWW
│   ├── pp_api/                       Client OpenAPI généré + intercepteurs
│   └── pp_auth/                      Stockage de jetons, refresh
│                                   └── optionnels : absents du build local
├── services/
│   ├── api/                          Serveur (cf. § 7)
│   └── deploy/                       docker-compose, migrations, CI
│
├── docs/                             Ce cahier des charges, ADR, schéma,
│                                     + docs/legacy/ (trace du format WP8)
├── tool/                             scripts de génération, outils
```

> **Le noyau P0 est `pp_domain` + `pp_data` + `pp_media` + `pp_ui` + `apps/mobile`.** Il doit compiler, être testé et être publiable **sans** `pp_sync`, `pp_api`, `pp_auth` ni `services/`. Ces derniers ne sont introduits qu'à partir de la Phase serveur (§ 12) et n'importent jamais les couches locales : la flèche va dans un seul sens.

**Règles de dépendance** (vérifiables par `dependency_graph` lint) :

```
pp_domain   → (rien)
pp_media    → pp_domain
pp_ui       → pp_domain
pp_data     → pp_domain
pp_api      → pp_domain
pp_auth     → pp_api, pp_domain
pp_sync     → pp_domain, pp_data, pp_api, pp_media
apps/mobile → pp_domain, pp_data, pp_media, pp_ui
             + pp_sync, pp_api, pp_auth   (uniquement si le mode connecté est activé)
```

## 6.2 Couches

```
┌──────────────────────────────────────────────────────┐
│  Présentation (Flutter widgets)                      │
│  AlbumListScreen · SlideViewerScreen · EditorScreen  │
└───────────────┬──────────────────────────────────────┘
                │  Riverpod (Provider / AsyncNotifier)
┌───────────────▼──────────────────────────────────────┐
│  Domaine (pp_domain)                                 │
│  Album · Slide · Pin · Asset                         │
│  PinGeometry · SlideRouter · CoverCalculator         │
│  AppLimits · PinEditor · ArchiveCodec (.photopush)   │
└───────┬───────────────────────┬──────────────────────┘
        │                       │
┌───────▼───────────────────────▼──────────────────────┐
│  P0 — COEUR HORS LIGNE (toujours présent)            │
│  pp_data (SQLite/Drift) · pp_media (import/cache)    │
│  pp_ui (widgets)                                      │
│  → source de vérité locale, aucune dépendance réseau │
└──────────────────────────────────────────────────────┘
        ▲                                    │
        │ écriture différée (outbox)        │ remplissage
┌───────┴───────────────┐          ┌─────────▼──────────┐
│  P1 — OPTION EN LIGNE │          │  SERVEUR (optionnel)│
│  pp_sync · pp_api     │─────────▶│  API + Postgres + S3 │
│  pp_auth              │◀─────────│                     │
└───────────────────────┘          └─────────────────────┘
```

**Principe directeur : la base locale est la seule source de vérité pour l'UI.** Aucune requête réseau dans un `build()`. Le réseau ne fait que remplir une *outbox* et alimenter la base.

**Deuxième principe directeur : le bloc P1 estإضافة, pas une dépendance.** Un build « local-only » (drapeau de compilation `PP_ONLINE=false`) exclut `pp_sync`, `pp_api`, `pp_auth` : les écrans de compte disparaissent, la couche réseau disparaît du graphe, et **toutes** les fonctionnalités du chapitre 3 restent identiques. Ce build est le mode de recette obligatoire des phases 0 à 1 (§ 10.2, § 12).

## 6.3 Ordonnancement des diapositives — `OrderKey`

Indexation fractionnaire (type Figma/Notion) : une `String` encodant un flottant en base 62, telle que l'insertion entre `A` et `B` produise une clé strictement comprise entre les deux **sans jamais toucher aux voisins**.

```
OrderKey("a", "b")  → "aU"          (milieu stable)
OrderKey("a", "aU") → "aV"
OrderKey(min, "X")  → incrémente la dernière lettre
```

Règles :

- Tri = **ordre lexicographique** sur la `String` (pas de parsing numérique).
- Deux clés **égales** (insertion concurrente entre les mêmes voisins depuis deux appareils) sont départagées par `slideId` → total et convergent.
- Pas de réécriture massive en cas d'insertion (contrairement à un index entier).

Paquet : port Dart de `fractional-indexing` (disponible en Dart), ou implémentation locale de ~80 lignes avec suite de tests property-based.

## 6.4 Horloge hybride (`Hlc`) et résolution de conflits

```dart
class Hlc implements Comparable<Hlc> {
  final int wallTimeMs;   // ms epoch
  final int counter;     // compteur local
  final String deviceId; // UUID de l'appareil — départage
}
```

Règle d'observation : à réception d'une horloge distante `(t, c, d)`,
`local = max(local, remote)` puis `+1` au compteur si `wallTimeMs` identique.

Comparaison lexicographique `(wallTimeMs, counter, deviceId)`.

**Fusion LWW par champ** : chaque champ modifié porte son propre `Hlc`. À la réception d'une opération concurrente, on applique champ par champ :

```
if (incomingHlc > storedHlc)  → accepter la valeur entrante
else                          → conserver la valeur locale
```

Résultat : **convergence déterministe**, aucune intervention utilisateur nécessaire dans le cas courant, pas de serveur « arbitre » complexe.

### Politiques par type d'opération

| Cas | Politique | Justification |
|---|---|---|
| Champ texte / titre / couleur / taille / position | LWW par champ | Fusion simple, le dernier écrivain gagne, intuitif |
| **Suppression** d'une diapositive / punaise / album | **La suppression l'emporte** (tombstone) | Évite les résurrections ; réversible via la corbeille pendant 30 jours |
| Ordre des diapositives | `OrderKey` fractionnaire (CRDT) | Fusion sans conflit |
| Création d'un album | Union : deux albums créés indépendamment coexistent | Pas d'écrasement |
| Renommage d'un album | LWW sur `name` | — |
| `assetId` d'une diapositive | LWW, **mais** si le média associé n'est pas encore uploadé côté serveur, le push est mis en attente (dépendance) | Voir § 7.6 |
| Changement de média d'une diapositive | LWW + **garde-fou** : si les deux médias sont présents, le plus récent gagne | Évite la perte de média |

> Toutes les politiques sont **paramétrables côté serveur** (`conflictPolicy`) afin de pouvoir durcir (`deleteWins`, `askUser`) sans redéploiement du client.

## 6.5 Base locale (Drift / SQLite)

```sql
CREATE TABLE assets (
  id           TEXT PRIMARY KEY,
  sha256       TEXT NOT NULL,
  local_path   TEXT,                 -- NULL si média distant uniquement
  remote_url   TEXT,
  mime_type    TEXT NOT NULL,
  byte_size    INTEGER NOT NULL,
  width        INTEGER,
  height       INTEGER,
  captured_at  INTEGER,
  original_name TEXT,
  sync_state   TEXT NOT NULL,        -- local | uploading | synced | failed
  created_at   INTEGER NOT NULL,
  UNIQUE (sha256)
);

CREATE TABLE albums (
  id             TEXT PRIMARY KEY,
  name           TEXT NOT NULL,
  cover_asset_id TEXT,
  local_rev      INTEGER NOT NULL DEFAULT 0,
  server_rev     INTEGER,
  server_seq     INTEGER,
  hlc_wall       INTEGER NOT NULL,
  hlc_counter    INTEGER NOT NULL,
  device_id      TEXT NOT NULL,
  deleted_at     INTEGER,
  pinned         INTEGER NOT NULL DEFAULT 0,
  created_at     INTEGER NOT NULL,
  updated_at     INTEGER NOT NULL
);
CREATE UNIQUE INDEX albums_name_unique ON albums(name COLLATE NOCASE)
  WHERE deleted_at IS NULL;

CREATE TABLE slides (
  id            TEXT PRIMARY KEY,
  album_id      TEXT NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
  kind          TEXT NOT NULL,       -- photo | comment
  title         TEXT NOT NULL DEFAULT '',
  comment_text  TEXT,
  asset_id      TEXT REFERENCES assets(id),
  order_key     TEXT NOT NULL,
  z_pin_counter INTEGER NOT NULL DEFAULT 0,  -- compteur de z pour les punaises
  dirty         INTEGER NOT NULL DEFAULT 0,  -- 0/1 : diapo modifiée
  hlc_wall      INTEGER NOT NULL,
  hlc_counter   INTEGER NOT NULL,
  device_id     TEXT NOT NULL,
  server_rev    INTEGER,
  deleted_at    INTEGER,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);
CREATE INDEX slides_album ON slides(album_id) WHERE deleted_at IS NULL;

CREATE TABLE pins (
  id              TEXT PRIMARY KEY,
  slide_id        TEXT NOT NULL REFERENCES slides(id) ON DELETE CASCADE,
  kind            TEXT NOT NULL,     -- neutral | text | link | textLink
  x               REAL NOT NULL,     -- 0..1
  y               REAL NOT NULL,     -- 0..1
  size_scale      REAL NOT NULL DEFAULT 1.0,
  color           TEXT NOT NULL DEFAULT 'black',
  text            TEXT,
  target_slide_id TEXT,
  z_index         INTEGER NOT NULL DEFAULT 0,
  hlc_wall        INTEGER NOT NULL,
  hlc_counter     INTEGER NOT NULL,
  device_id       TEXT NOT NULL,
  server_rev      INTEGER,
  deleted_at      INTEGER,
  created_at      INTEGER NOT NULL
);
CREATE INDEX pins_slide ON pins(slide_id) WHERE deleted_at IS NULL;

CREATE TABLE outbox (              -- file d'attente d'envoi
  op_id       TEXT PRIMARY KEY,    -- UUID d'idempotence
  entity      TEXT NOT NULL,       -- album | slide | pin | asset
  entity_id   TEXT NOT NULL,
  op_type     TEXT NOT NULL,       -- upsert | delete
  payload     TEXT NOT NULL,       -- JSON
  hlc_wall    INTEGER NOT NULL,
  created_at  INTEGER NOT NULL,
  attempts    INTEGER NOT NULL DEFAULT 0,
  last_error  TEXT
);

CREATE TABLE sync_state (
  key   TEXT PRIMARY KEY,          -- last_server_seq, last_pull_at, ...
  value TEXT NOT NULL
);

CREATE TABLE devices ( ... );      -- agents de chiffrement (v2)
```

Contraintes d'intégrité **appliquées côté applicatif et vérifiées par tests** :

- `0 <= pins.x <= 1` et `0 <= pins.y <= 1` (CHECK SQL).
- `1.0 <= pins.size_scale <= 3.0`.
- `slides.kind` cohérent avec `asset_id` / `comment_text` (vérifié à l'écriture).
- `pins.target_slide_id` référençant une diapositive existante ou un `deleted_at` non nul.
- Suppression en cascade : album → slides → pins.

## 6.6 Gestion de l'état (Riverpod)

```dart
final albumRepositoryProvider      = Provider<AlbumRepository>();
final albumListProvider            = AsyncNotifierProvider<AlbumListNotifier, List<AlbumSummary>>();
final currentAlbumProvider         = AsyncNotifierProvider<CurrentAlbumNotifier, CurrentAlbumState>();
final currentSlideProvider         = Provider<Diapo? >();   // diapo courante
final slideViewerProvider          = AsyncNotifierProvider<SlideViewerNotifier, ViewerState>();
final pinSettingsProvider          = NotifierProvider<PinSettingsNotifier, PinSettings>();
final syncStatusProvider           = StreamProvider<SyncStatus>();
final accountProvider              = AsyncNotifierProvider<AccountNotifier, AccountState>();
final connectivityProvider         = StreamProvider<Connectivity>();
```

`ViewerState` porte le zoom/pan : `{ scale, offset, pinsHidden, navigationStack, currentSlideId }`.

**Gain vs WP8** : plus aucun état global. Chaque album ouvert a son propre contrôleur ; les tests sont possibles sans `InitializeComponent()`.

## 6.7 Cache d'images

- `cached_network_image` pour les médias distants.
- Cache disque LRU de vignettes (`thumbnailCache`), clé `sha256 + taille`, dossier privé.
- Décodage asynchrone (`compute()` / isolate) pour ne jamais bloquer le fil UI.
- Préchargement de la diapositive **suivante/précédente** (voisinage ±1).

---

# 7. Spécification du mode client / serveur (P1 — optionnel)

> Rien de ce chapitre n'est requis pour utiliser l'application (RNF-70). Il décrit un **ajout** : le mode connecté. Sa lecture peut être différée sans bloquer le P0.

## 7.1 Deux modes, un seul code

| Mode | Déclenchement | Comportement |
|---|---|---|
| **Local** (défaut, P0) | Aucun compte, aucun serveur | **100 % des exigences `RF-xx` / `R-xx` / `LIM-xx`**, stockage local seul, **zéro requête réseau**. Bouton « Activer la synchronisation » dans les Réglages. |
| **Connecté** (P1, option) | Compte authentifié | Idem + sauvegarde serveur + synchronisation continue. |
| **Connecté mais hors ligne** | Compte authentifié + réseau absent | Exactement le mode local : toutes les fonctions restent disponibles, l'outbox s'accumule, synchronisation différée au retour du réseau. |

> **Contraintes fortes** :
>
> 1. Le mode local n'est **jamais dégradé** : aucune fonctionnalité du chapitre 3 ne dépend du serveur, du compte ou du réseau.
> 2. **Aucun credential n'est exigé** pour utiliser l'application : pas de fenêtre de connexion au premier lancement, pas de réseau imposé au démarrage.
> 3. Le passage local → connecté ne doit ni bloquer l'utilisateur, ni lui faire perdre de données (les albums locaux sont **poussés** vers le compte, § 7.3).
> 4. La déconnexion réseau **ou** la panne du serveur ne produit ni erreur bloquante, ni écran vide, ni perte de données locale.
> 5. Le build `PP_ONLINE=false` (§ 6.2) doit passer la recette du cœur (§ 10.2) sans une seule modification : c'est la preuve mécanique de l'exigence.

## 7.2 Comptes

| ID | Exigence | Priorité |
|---|---|---|
| SYNC-01 | Inscription : `email` + `mot de passe` (≥ 10 caractères) + confirmation. Validation RFC 5322 simplifiée | M |
| SYNC-02 | Connexion ; **refresh token** rotatif stocké dans le Keychain (iOS) / EncryptedSharedPreferences (Android) via `flutter_secure_storage` | M |
| SYNC-03 | Session persistante au redémarrage ; access token court (15 min) rafraîchi automatiquement | M |
| SYNC-04 | Déconnexion : **ne pas** supprimer les données locales ; passer en file d'attente d'envoi vers le prochain compte | M |
| SYNC-05 | Récupération de mot de passe par email | S |
| SYNC-06 | Suppression de compte : purge serveur + purge locale, confirmation en deux temps, délai de grâce de 7 jours | M |
| SYNC-07 | Un album ne peut être partagé qu'entre comptes du **même propriétaire** en v1 (pas de partage multi-utilisateurs) | M |
| SYNC-08 | Appareil enregistré côté serveur (pour révocation et pour la liste des appareils dans les Réglages) | S |

## 7.3 Cycle de vie d'un album en mode connecté

```
CRÉATION
  UI → SQLite (immediate, offline-capable)
  SQLite → outbox (op: upsert album)
  outbox → API POST /sync/push
  API → stockage objet si média nouveau
  API → seq ++, rev = 1
  réponse → SQLite mis à jour (server_rev, server_seq, hlc serveur)

MODIFICATION
  UI → SQLite (optimiste, revision locale +1)
  outbox → push incrémental (champs modifiés seulement)

SUPPRESSION
  UI → SQLite (deleted_at = now)
  outbox → op delete (tombstone)
  → purgée après 30 j

LECTURE (sur un 2e appareil)
  GET /sync/changes?since=0
  → création locale de l'album, des diapositives, des punaises
  → téléchargement des médias manquants (lazy + prefetch du visibles)
```

## 7.4 API REST

Base : `/api/v1`. JSON UTF-8. Authentification `Authorization: Bearer <access_token>`.
Toutes les réponses d'erreur suivent le format :

```json
{ "error": { "code": "ALBUM_NOT_FOUND", "message": "...", "details": {} } }
```

### Authentification

| Méthode | Chemin | Description |
|---|---|---|
| `POST` | `/auth/register` | `{email, password}` → `{user, accessToken, refreshToken}` |
| `POST` | `/auth/login` | idem |
| `POST` | `/auth/refresh` | `{refreshToken}` → nouvelle paire (rotation) |
| `POST` | `/auth/logout` | révoque la famille de refresh tokens |
| `GET` | `/me` | profil + quotas + volume utilisé |
| `PATCH` | `/me` | `{displayName}` |
| `GET` | `/me/quota` | `{albumsUsed, albumsMax, bytesUsed, bytesMax, slidesMax, pinsMax}` |

###-CRUD de lecture (pour le débogage et l'administration)

| Méthode | Chemin |
|---|---|
| `GET` | `/albums?limit=&cursor=` |
| `POST` | `/albums` |
| `PATCH` | `/albums/{albumId}` |
| `DELETE` | `/albums/{albumId}` (soft) |
| `POST` | `/albums/{albumId}/restore` |
| `GET` | `/albums/{albumId}/slides` |
| `POST` | `/slides` |
| `PATCH` | `/slides/{slideId}` |
| `DELETE` | `/slides/{slideId}` |
| `GET` | `/slides/{slideId}/pins` |
| `POST` | `/pins` |
| `PATCH` | `/pins/{pinId}` |
| `DELETE` | `/pins/{pinId}` |

### Médias

| Méthode | Chemin | Description |
|---|---|---|
| `POST` | `/assets/init` | `{sha256, mimeType, byteSize, width, height, originalName, capturedAt}` → `200 {status:"exists", assetId}` **ou** `201 {status:"needed", assetId, uploadUrl, chunkSize, maxConcurrentChunks}` |
| `PUT` | `/assets/{assetId}/content` | Envoi binaire. Support `Content-Range` pour la reprise. `201`/`204` |
| `GET` | `/assets/{assetId}/variant?size=thumb\|preview\|original` | Redirection `302` vers une URL signée (15 min) ou flux direct |
| `DELETE` | `/assets/{assetId}` | Suppression différée si référencé |

> `POST /assets/init` est le mécanisme de **déduplication** : deux appareils qui importent la même photo obtiennent le même `assetId` sans jamais transférer les octets.

### Synchronisation

| Méthode | Chemin | Description |
|---|---|---|
| `POST` | `/sync/push` | Lot d'opérations (voir § 7.5) |
| `GET` | `/sync/changes?since=<seq>&limit=<n>` | Journal de modifications sequentiel |
| `GET` | `/sync/stream?since=<seq>` | **SSE** : notification temps réel des nouveaux `seq` |
| `GET` | `/devices` | Liste des appareils de l'utilisateur |
| `DELETE` | `/devices/{deviceId}` | Révocation |

## 7.5 Protocole de synchronisation

### `POST /sync/push`

```json
{
  "deviceId": "0192f1c2-…",
  "clientId": "a3c9…",           
  "ops": [
    {
      "opId": "0192f1d0-8e11-7a3e-…",   
      "entity": "slide",
      "entityId": "0192f1a0-…",
      "opType": "upsert",
      "baseRev": 12,
      "hlc": { "wallTimeMs": 1732100000000, "counter": 3, "deviceId": "0192f1c2-…" },
      "fields": {
        "title":         { "value": "La tour",   "hlc": { … } },
        "commentText":   { "value": "Été 2024",  "hlc": { … } },
        "orderKey":      { "value": "aU",        "hlc": { … } }
      },
      "pendingAssets": []
    }
  ]
}
```

Traitement serveur, pour chaque `op` :

1. **Idempotence** : si `opId` déjà traité → renvoyer le résultat mémorisé, ne rien réappliquer.
2. **Autorisation** : l'entité doit appartenir à l'utilisateur. `404` sinon.
3. **Dépendances médias** : si `pendingAssets` non vide ou si un `assetId` référencé est inconnu → `409 ASSET_NOT_READY` avec la liste des assets manquants (le client réessaie après upload).
4. **Fusion** : pour chaque champ fourni, `if (incoming.hlc > stored.hlc) → écrire`.
5. **Résultat** : nouvelle version + `seq` attribués.

Réponse :

```json
{
  "results": [
    {
      "opId": "0192f1d0-8e11-7a3e-…",
      "status": "applied",
      "serverRev": 13,
      "serverSeq": 48213,
      "entity": "slide",
      "entityId": "0192f1a0-…",
      "mergedFields": { "title": "La tour" },
      "rejectedFields": [
        { "field": "commentText", "reason": "stale_hlc", "authoritativeValue": "Vacances" }
      ]
    }
  ],
  "serverTime": 1732100001234,
  "cursor": 48213
}
```

Le client applique alors : `serverRev = 13`, `serverSeq = 48213`, et pour chaque `rejectedFields` → **écrase la valeur locale** par la valeur autoritaire, en journalisant un conflit (§ 7.9).

### `GET /sync/changes?since=<seq>&limit=500`

```json
{
  "changes": [
    { "seq": 48214, "entity": "slide", "entityId": "0192f1a0-…",
      "opType": "upsert", "serverRev": 14,
      "hlc": { … }, "fields": { "title": { "value": "La tour", "hlc": { … } } },
      "deletedAt": null, "actorDeviceId": "0192f1c2-…" }
  ],
  "nextCursor": 48214,
  "hasMore": true,
  "serverTime": 1732100001234
}
```

- Le journal est **strictement ordonné et immuable** (`seq` monotone croissant, jamais réattribué, jamais réutilisé).
- Pagination par `cursor`, jamais par `since` calculé (pas de trou si écriture concurrente).
- Le client persiste `last_server_seq` **après** avoir appliqué le lot en base (transaction unique).

### Dérives du `seq` (slots)

- Un `seq` est une **valeur logique attribuée en base** (colonne `BIGSERIAL` / `change_seq`), pas un `SERIAL` PostgreSQL si des trous sont possibles — le client ne doit jamais supposer la contiguïté. En pratique : `seq` contigu par transaction, et `hasMore` gère le reste.
- La rétention du journal est de **90 jours**. Au-delà, le client doit faire une **réinitialisation complète** (`GET /sync/snapshot`) — cela n'arrive en pratique uniquement après une longue inactivité.

## 7.6 Moteur de synchronisation côté client

### États

```dart
enum SyncState { offline, idle, syncing, error, disabled }
enum SyncDirection { push, pull, bidirectional }
```

### Boucle

```dart
Future<void> sync() async {
  if (!account.isConnected) return;
  if (!await connectivity.isOnline) { setState(SyncState.offline); return; }

  setState(SyncState.syncing);
  // 1. Dépendances médias d'abord
  await mediaUploader.uploadPendingAssets();      // § 7.7
  // 2. Push (lots de 100 opérations)
  while (outbox.hasPending) {
    final results = await api.push(outbox.takeBatch(100));
    await applyPushResults(results);
  }
  // 3. Pull
  while (true) {
    final page = await api.changes(since: lastSeq, limit: 500);
    await db.transaction(() { applyChanges(page.changes); setLastSeq(page.nextCursor); });
    if (!page.hasMore) break;
  }
  // 4. Téléchargement des médias référencés mais absents (lazy)
  await mediaStore.ensureAssetsForVisibleSlides();
  setState(SyncState.idle);
}
```

### Déclencheurs

| Déclencheur | Détail |
|---|---|
| Démarrage de l'app | après le chargement de la base |
| Retour au premier plan | `AppLifecycleState.resumed` |
| Après chaque mutation locale | debounce 2 s (RF-130) |
| Connectivité retrouvée | `connectivity_plus` |
| Notification push serveur | SSE / FCM quand l'app est en arrière-plan |
| Manuel | bouton `↻` (RF-09) |
| Périodique | 60 s en premier plan, 15 min en arrière-plan |

### Garanties

| ID | Exigence |
|---|---|
| SYNC-20 | **Idempotence** : une opération rejouée ne duplique rien (clé `opId`). |
| SYNC-21 | **Atomicité locale** : l'application d'un lot de changements se fait dans une seule transaction SQLite. |
| SYNC-22 | **Reprise** : un push interrompu est repris ; l'outbox conserve les opérations non acquittées. |
| SYNC-23 | **Backpressure** : maximum 100 opérations par lot, 3 lots maximum en file, puis temporisation exponentielle (1 s, 2 s, 4 s … 5 min). |
| SYNC-24 | **Déconnexion** : le push échoue proprement, l'outbox s'accumule, l'UI reste utilisable. |
| SYNC-25 | **Compte non connecté** : l'outbox est conservée et rattachée au profil local ; à la connexion, elle est rattachée au compte. |
| SYNC-26 | **Quotas** : si `me/quota` est dépassé, la synchronisation se met en pause avec un message explicite, l'édition locale reste possible. |
| SYNC-27 | **Horloge** : dérive d'horloge locale > 5 min → le serveur renvoie `serverTime` et le client réajuste son horloge (biais stocké). |

## 7.7 Synchronisation des médias

| ID | Exigence | Priorité |
|---|---|---|
| SYNC-30 | Un média est **importé** (copié + hashé) avant toute référence diapo | M |
| SYNC-31 | `POST /assets/init` systématique → déduplication globally | M |
| SYNC-32 | Upload **par blocs** avec reprise (`Content-Range`) ; 3 blocs en parallèle | M |
| SYNC-33 | Upload **uniquement en Wi-Fi par défaut** (réglable : Wi-Fi + données mobiles) | S |
| SYNC-34 | Priorité aux médias **visibles** à l'écran ; les autres en file d'attente | M |
| SYNC-35 | Une diapositive dont le média n'est pas encore disponible s'affiche avec un **placeholder** et un indicateur ; elle est déjà synchronisée sur le plan des métadonnées | M |
| SYNC-36 | Si le serveur répond `revoked` (asset identique fourni par un autre appareil), le client **réoriente** son entrée locale vers l'`assetId` canonique et libère le fichier local si plus référencé | M |
| SYNC-37 | Les variantes (`thumb`, `preview`) sont générées **par le serveur**, stockées dans le CDN ; le client les télécharge et les met en cache | M |
| SYNC-38 | Quota de stockage serveur notifié et affiché (Réglages → stockage utilisé) | S |
| SYNC-39 | Téléchargement anticipé des N diapositives voisines (±1) | S |

## 7.8 Cycle de vie d'un média (serveur)

```
POST /assets/init ──► existe ? ──oui──► 200 {status:"exists", assetId}          (0 octet transféré)
                          │non
                          ▼
                    201 {status:"needed", assetId, uploadUrl, chunkSize}
                          │
                          ▼
              PUT /assets/{id}/content  (par blocs, reprise possible)
                          │
                          ▼
              File d'attente : virus scan → extraction EXIF → variantes
                          (thumbnail 120, preview 2048)
                          │
                          ▼
              asset.state = "ready"  (les référents le savent via SSE)
```

Un asset reste `pending` sans jamais être uploadé est **purgé après 24 h**.

## 7.9 Journal des conflits et transparence

| ID | Exigence | Priorité |
|---|---|---|
| SYNC-40 | Chaque champ écrasé lors d'un conflit est journalisé (champ, valeur locale, valeur distante, appareil, horodatage) | M |
| SYNC-41 | Écran **Réglages → Synchronisation → Journal** consultable et vidable | M |
| SYNC-42 | Notification non bloquante (« Une diapositive a été modifiée sur un autre appareil ») | S |
| SYNC-43 | Aucune **boîte de dialogue** de résolution de conflit en v1 (réservé au mode expert) | M |

## 7.10 Corbeille distribuée

| ID | Exigence | Priorité |
|---|---|---|
| SYNC-50 | Suppression → `deletedAt` + tombstone propagé | M |
| SYNC-51 | Corbeille : 30 jours, visible et restaurable sur **tous** les appareils | M |
| SYNC-52 | Purge des tombstones > 30 j (serveur) et nettoyage local correspondant | M |
| SYNC-53 | La restauration « dés-supprime » (remet `deletedAt = null`) et se propage | M |

## 7.11 Gestion des appareils

| ID | Exigence | Priorité |
|---|---|---|
| SYNC-60 | Chaque installation possède un `deviceId` (UUID v7) persistant | M |
| SYNC-61 | L'appareil envoie son nom lisible (« iPhone d'Eymeric ») et sa dernière version d'app | S |
| SYNC-62 | Réglages → Appareils : liste, dernière activité, révoquer (force un plein resync) | S |
| SYNC-63 | Révocation → le client détecte un `401` persistant, purge son cache de `seq` et fait un `snapshot` complet | M |

## 7.12 Serveur — spécifications techniques

### Pile recommandée (modifiable — le client ne dépend que du contrat OpenAPI)

| Couche | Choix | Justification |
|---|---|---|
| Langage | **Go** ou **TypeScript (NestJS)** | deux choix possibles ; le contrat OpenAPI est la source de vérité |
| Base | **PostgreSQL 16** | transactions, `LISTEN/NOTIFY`, JSONB, `SKIP LOCKED` |
| Fichiers | **S3 / MinIO** + CDN | médias volumineux, URLs signées |
| Cache/files | **Redis** | file de traitement média, rate limiting |
| Auth | JWT auto-émis (Argon2id) ou **Keycloak/Zitadel** (OIDC) | — |
| Traitement média | **libvips** (thumbnail, preview, EXIF, rotation) | rapide, faible mémoire |
| Déploiement | Docker Compose (auto-hébergé) **ou** managé | l'utilisateur doit pouvoir l'héberger lui-même |
| Observabilité | logs structurés, métriques Prometheus, Sentry (optionnel) | — |

### Modèle de données serveur (principales tables)

```sql
users(id uuid PK, email citext UNIQUE, password_hash text, display_name text,
      created_at timestamptz, storage_used_bytes bigint, quota_bytes bigint, ...)

devices(id uuid PK, user_id uuid FK, name text, platform text, app_version text,
        last_seen_at timestamptz, revoked_at timestamptz)

assets(id uuid PK, user_id uuid FK, sha256 bytea, mime_type text, byte_size bigint,
       width int, height int, object_key text, state text,   -- pending|ready|rejected
       created_at timestamptz,
       UNIQUE (user_id, sha256))

albums(id uuid PK, user_id uuid FK, name text, cover_asset_id uuid,
       revision bigint, deleted_at timestamptz, created_at, updated_at)

slides(id uuid PK, user_id uuid FK, album_id uuid FK ON DELETE CASCADE,
       kind text, title text, comment_text text, asset_id uuid,
       order_key text, pin_counter int, revision bigint,
       deleted_at, created_at, updated_at)

pins(id uuid PK, user_id uuid FK, slide_id uuid FK ON DELETE CASCADE,
     kind text, x real, y real, size_scale real, color text,
     text text, target_slide_id uuid, z_index int,
     revision bigint, deleted_at, created_at,
     hlc_wall bigint, hlc_counter bigint, hlc_device uuid)

-- Champs modifiés individuellement, avec leur HLC, pour la fusion LWW
entity_fields(user_id, entity_type, entity_id, field text,
              value jsonb, hlc_wall bigint, hlc_counter bigint, hlc_device uuid,
              PRIMARY KEY (user_id, entity_type, entity_id, field))

change_log(seq bigserial PK, user_id uuid FK, entity_type text, entity_id uuid,
           op_type text, revision bigint, actor_device_id uuid, created_at)

applied_ops(user_id uuid, op_id uuid, result jsonb, applied_at,
            PRIMARY KEY (user_id, op_id))     -- idempotence, purge > 30 j
```

Index : `(user_id, deleted_at)` sur `albums/slides/pins`, `(user_id, seq)` sur `change_log`, `(user_id, state)` sur `assets`.

### Notification temps réel

`LISTEN/NOTIFY` PostgreSQL → publish Redis → `SSE` vers le client. Si indisponible, repli sur le polling 60 s (dégradation gracieuse, jamais bloquante).

### Sécurité serveur

| ID | Exigence | Priorité |
|---|---|---|
| SEC-01 | Mots de passe hachés **Argon2id** (jamais MD5/SHA) | M |
| SEC-02 | Refresh tokens rotatifs, détectés par réutilisation (reuse detection) | M |
| SEC-03 | HTTPS obligatoire (TLS 1.2+), HSTS | M |
| SEC-04 | URLs de médias **signées**, expiration 15 min, non publiques | M |
| SEC-05 | Rate limiting par IP et par compte sur `/auth/*` et `/sync/push` | M |
| SEC-06 | Validation stricte des entrées (taille, type MIME réel vs déclaré, dimensions) | M |
| SEC-07 | Anti-upload malveillant : vérification de la signature du fichier, taille max, dimensions max | M |
| SEC-08 | En-têtes de sécurité, `Content-Security-Policy` sur l'interface d'admin | S |
| SEC-09 | Journalisation d'audit des actions sensibles (connexion, révocation, suppression de compte) | S |
| SEC-10 | Suppression du compte : purge immédiate des médias, effacement des données dérivées sous 30 j | M |
| SEC-11 | Pas de télémétrie dans les données utilisateur ; métriques agrégées et anonymisées seulement | M |
| SEC-12 | Le client ne stocke **jamais** le mot de passe (uniquement via le trousseau système) | M |

### Quotas par défaut

| Quota | Défaut | Configurable |
|---|---|---|
| Stockage | 5 Gio | oui |
| Albums | 500 | oui |
| Diapositives / album | 200 | oui |
| Punaises / diapositive | 30 | oui |
| Taille d'un média | 25 Mio | oui |
| Médias / diapositive | 1 | non en v1 |

---

# 8. Écrans spécifiques au client / serveur (P1 — optionnel)

## 8.1 `SettingsScreen`

| Section | Contenu | Priorité |
|---|---|---|
| Compte | email, nom, déconnexion, supprimer le compte | M |
| Serveur | URL du serveur, statut de connexion, « Se connecter » / « Se déconnecter », test de connectivité | M |
| Synchronisation | état, dernière synchronisation, « Synchroniser maintenant », activation/désactivation, réseau autorisé (Wi-Fi seul / données mobiles) | M |
| Stockage | volume utilisé / quota, cache local, « Vider le cache », taille des albums | S |
| Appareils | liste des appareils, révoquer | S |
| Journal | historique des conflits et erreurs, export, vider | M |
| Thème | Sombre (défaut) / Clair / Système | S |
| Langue | Système / Français / English | M |
| À propos | version, licences, politique de confidentialité | M |

## 8.2 `LoginScreen` / `RegisterScreen` / `OnboardingScreen`

| ID | Exigence | Priorité |
|---|---|---|
| RF-150 | Écran d'accueil expliquant les deux modes : « Utiliser sans compte » / « Se connecter pour synchroniser » | M |
| SYNC-80 | Connexion : email, mot de passe, afficher/masquer, « mot de passe oublié » | M |
| SYNC-81 | Inscription : email, mot de passe, confirmation, case « j'accepte les conditions » | M |
| SYNC-82 | Affichage clair des erreurs (mauvais identifiants, quota, réseau indisponible) | M |
| SYNC-83 | Après inscription : proposition « synchroniser les albums locaux » → déclenche le push de l'outbox existante | M |
| SYNC-84 | Bouton « Travailler hors ligne » accessible à tout moment, y compris depuis les écrans d'authentification | M |

## 8.3 États de synchronisation visibles

| Situation | Rétroaction |
|---|---|
| Hors ligne | Bandeau discret « Mode hors ligne — les modifications seront synchronisées plus tard » |
| Synchronisation en cours | Indicateur animé discret sur l'album concerné |
| Erreur réseau | Bandeau avec bouton « Réessayer » ; **jamais de boîte modale** |
| Erreur de quota | Bandeau persistant renvoyant vers les Réglages |
| Conflit détecté | Toast non bloquant + entrée dans le journal |
| Média en attente d'upload | Pastille sur la vignette de la diapositive |

---

# 9. Non fonctionnel

## 9.1 Plateformes

| ID | Exigence |
|---|---|
| RNF-01 | Android 8.0 (API 26) et ultérieur |
| RNF-02 | iOS 13 et ultérieur |
| RNF-03 | Flutter stable (≥ 3.24) ; une seule base de code, une seule application |
| RNF-04 | Support portrait **et** paysage ; mise en page tablette prévue (non bloquante en v1) |
| RNF-05 | Compilation en mode release avec obfuscation des clés de licence/signature |

## 9.2 Performance

| ID | Exigence | Cible |
|---|---|---|
| RNF-10 | Démarrage à froid → liste des albums visible | < 1,5 s (milieu de gamme) |
| RNF-11 | Ouverture d'un album → première image affichée | < 400 ms si média en cache |
| RNF-12 | Interaction de la visionneuse (zoom/pan) | 60 fps constants |
| RNF-13 | Recalcul du positionnement des punaises | < 4 ms par frame (30 punaises) |
| RNF-14 | Défilement de la liste d'albums (200 albums) | 60 fps, sans à-coup de décodage |
| RNF-15 | Import d'une photo de 5 Mio | < 2 s (copie + hachage + vignette) |
| RNF-16 | Synchronisation d'un album de 12 diapos / 30 punaises, médias déjà en cache | < 3 s (LAN) |
| RNF-17 | Aucun décodage d'image plein résolution sur le fil UI | obligatoire |
| RNF-18 | Consommation mémoire en visionneuse | < 300 Mio (photo 12 Mpx zoomée) |

## 9.3 Fiabilité

| ID | Exigence |
|---|---|
| RNF-20 | **Aucune perte de données** sur kill de l'application : sauvegarde automatique (R-31) |
| RNF-21 | Tolérance aux crashes de l'OS pendant l'import d'un média : fichier temporaire puis renommage atomique |
| RNF-22 | Migration de schéma SQLite testée et réversible (downgrade autorisé si possible) |
| RNF-23 | Tolérance à la corruption : la lecture d'un album corrompu ne crash pas ; l'album fautif est isolé et signalé |
| RNF-24 | Reprise après interruption réseau à tout instant, sans perte ni duplication |
| RNF-25 | Rapport de crash non bloquant, avec possibilité de refuser l'envoi |
| RNF-26 | Fournir un moyen d'export d'urgence des données brutes (dump SQLite) |

## 9.4 Sécurité et vie privée

| ID | Exigence |
|---|---|
| RNF-30 | Jetons dans le trousseau système uniquement ; **jamais** en `SharedPreferences` en clair |
| RNF-31 | Certificate pinning **optionnel** (activable par l'utilisateur, désactivé par défaut) |
| RNF-32 | Les médias ne sont accessibles que via URL signée, jamais en accès public |
| RNF-33 | Aucune donnée personnelle collectée hors du compte de l'utilisateur |
| RNF-34 | **Aucune télémétrie, aucun analytics, aucun crash-reporting** dans le build local-only ; en mode connecté, tout envoi est opt-in explicite et révocable |
| RNF-38 | **Trajectoire v2 : chiffrement de bout en bout.** Non requis en v1, mais l'architecture doit le permettre : `entity_fields` stocke une colonne opaque par champ (indépendante de tout format de sérialisation) et les médias sont adressés par hash. Ne pas figer un schéma qui l'empêche. |

## 9.5 Qualité et maintenabilité

| ID | Exigence |
|---|---|
| RNF-40 | `flutter analyze` sans avertissement ni erreur ; `dart format` respecté |
| RNF-45 | Couverture de tests **≥ 80 %** sur `pp_domain` et `pp_sync` |
| RNF-46 | Tests unitaires sur chaque règle métier (R-xx, RF-xx) |
| RNF-47 | Tests d'intégration avec un **faux serveur** simulant partitions réseau, retards, doublons, conflits |
| RNF-48 | Tests **golden** des écrans clés (liste, visionneuse avec punaises, éditeur) |
| RNF-49 | Test de bout en bout : import → création de punaises → sauvegarde → synchro → vérification sur un 2e « appareil » simulé |
| RNF-50 | **Test de recette « mode avion »** : la totalité des scénarios du chapitre 3 passe sans réseau, sans compte et sur le build `PP_ONLINE=false` (§ 10.2) |
| RNF-51 | Test de coupure réseau en pleine écriture : tuer le réseau après chaque `RF` de création/édition, vérifier l'absence de perte et l'intégrité de l'`outbox` |
| RNF-55 | CI : analyse + formatage + tests + build sur chaque commit |
| RNF-56 | Versioning sémantique ; changelog tenu |
| RNF-57 | Documentation ADRs pour : choix de la synchro, du schéma, du stockage média |

## 9.6 Accessibilité et internationalisation

| ID | Exigence |
|---|---|
| RNF-60 | Cibles tactiles ≥ 48 dp ; contraste ≥ 4.5:1 (texte) et 3:1 (icônes) |
| RNF-61 | `Semantics` sur toutes les actions ; libellés en français et anglais |
| RNF-62 | Support du texte agrandi jusqu'à 200 % |
| RNF-63 | fr + en obligatoires ; infrastructure prête pour d'autres langues |
| RNF-64 | Ne jamais transmettre une information par la seule couleur (les punaises ont bien une couleur, mais leur action est aussi annoncée par un libellé) |

## 9.7 Exigences « offline-first » (non négociables)

Ce chapitre formalise le principe directeur n° 1 (§ 0.1). Ces exigences sont **M** et bloquantes : une seule d'entre elles non satisfaite interdit la publication.

| ID | Exigence | Preuve de recette |
|---|---|---|
| RNF-70 | **Toutes** les exigences `RF-xx`, `R-xx` et `LIM-xx` sont satisfaites sans réseau, sans compte et sans serveur | Recette complète en mode avion |
| RNF-71 | L'application démarre, est pleinement utilisable et se ferme proprement sans aucune autorisation réseau | `PP_ONLINE=false` + mode avion |
| RNF-72 | L'absence de réseau n'affiche jamais d'écran bloquant, de boîte de dialogue d'erreur ou deSpinner infini ; au mieux un bandeau discret d'état | Scénarios S-01 → S-05 |
| RNF-73 | Toute écriture est persistée **localement d'abord** ; l'UI ne dépend d'aucun accusé de réception distant | Inspection du schéma : la base locale est écrite avant l'`outbox` |
| RNF-74 | Les médias sont lisibles depuis le sandbox local, jamais depuis une URL distante (le cache réseau n'est qu'un accélérateur) | Test de vol de réseau |
| RNF-75 | Le stockage local n'est jamais purgé par la purge serveur : effacer le compte ou les données distantes ne touche pas aux albums non synchronisés | RNF-26, SYNC-06 |
| RNF-76 | Aucune dépendance runtime à un service tiers (CDN, crash reporter, analytics) : l'app fonctionne dans un réseau totalement fermé | Fuite DNS / air-gap |
| RNF-77 | Le mode connecté est **réversible** : « Travailler hors ligne » est accessible en permanence, et revenir en mode local ne perd rien | SYNC-84 |
| RNF-78 | Le budget de temps passé en « ligne » (synchronisation en tâche de fond) est borné et n'affecte jamais la réactivité de l'UI, même sur un album de 200 diapos | RNF-12, RNF-13 |

> **Critère d'arrêt** : si une fonctionnalité du cœur ne peut pas être livrée sans le serveur, elle n'est pas dans le cœur — elle bascule en P1 (cf. § 2.2 / § 2.3).

---

# 10. Stratégie de test et recette

## 10.1 Niveaux

| Niveau | Outil | Cible |
|---|---|---|
| Unitaire | `test` | domaine, géométrie des punaises, `OrderKey`, `Hlc`, LWW, migrations SQLite |
| Widget | `flutter_test` | écrans, états vides, états d'erreur |
| Golden | `flutter_test` (goldens) | 6 écrans × 2 thèmes × 2 langues |
| Intégration mobile | `integration_test` | parcours complets sur appareil |
| **Recette hors ligne** | `integration_test` + build `PP_ONLINE=false` | **tous les scénarios U-01 → U-10, en mode avion** |
| Synchronisation | `test` + faux serveur | convergence, offline, partition, doublons |
| Charge (serveur) | k6 | 100 comptes, 10 000 diapos, 1 Gio de médias |
| E2E multi-appareils | 2 instances de test | A push, B pull, convergence en < 10 s |

> **Recette obligatoire hors ligne** : la CI exécute la suite `U-*` sur le build `PP_ONLINE=false`, réseau coupé (fake proxy réseau). Un échec = build rouge. C'est la preuve mécanique du principe directeur n° 1 (RNF-50, RNF-70).

## 10.2 Matrice de recette (extrait)

**Légende** : `U-` = cœur hors ligne (P0, bloquant) · `O-` = robustesse hors ligne (P0) · `S-` = synchronisation (P1) · `A-` = accessibilité.

| # | Scénario | Attendu | Exigences |
|---|---|---|---|
| U-01 | Créer un album « Vacances », ajouter 3 photos et 2 commentaires | Album créé, diapositives dans l'ordre, couverture = 1ʳᵉ photo | RF-13, RF-90 |
| U-02 | Poser 3 punaises sur une photo, en zoom x1 puis en zoom x2 | Coordonnées relatives correctes dans les deux cas | RF-41, R-02 |
| U-03 | Recharger l'app : les punaises sont au même endroit | Positions identiques | R-30 |
| U-04 | Pincer/zoomer puis Ouvrir les réglages punaises, choisir violet 2.0, revenir, poser une punaise | La nouvelle punaise est violette taille 2.0, les autres inchangées | RF-100, RF-101, RF-105 |
| U-05 | Créer un lien vers la diapositive 3, le suivre, revenir via `↩` | Navigation correcte, `↩` disparaît ensuite | RF-48, R-12, R-13 |
| U-06 | Re-taper sur la diapositive 3 pour retirer le lien | Le pin redevient neutre | RF-50 |
| U-07 | Supprimer la photo d'une diapositive avec punaises | Punaises supprimées ; diapo conservée si commentaire, sinon supprimée | RF-59 |
| U-08 | Tuer l'app en cours d'édition, rouvrir | Modifications conservées (sauvegarde auto) | R-31, RNF-20 |
| U-09 | Album avec 1 diapositive : vérifier l'absence de flèches et du bouton punaises | Absents | RF-23, RF-30 |
| U-10 | Diapositive sans image : la visionneuse bascule sur le commentaire | Automatique | R-30 (routage) |
| U-11 | Supprimer la photo d'un album dans la photothèque, rouvrir l'app | L'album est intact (copie locale) | § 5.4, D3 |
| O-01 | **Mode avion + build local-only** : parcourir les 10 écrans, créer album/photo/punaise/texte/lien, réorganiser, dupliquer, restaurer de la corbeille, exporter une archive | **Tout fonctionne**, zéro écran d'erreur réseau | RNF-70, RNF-71, OBJ-1 |
| O-02 | Premier lancement, jamais connecté, aucun compte créé | L'application est directement utilisable, aucun écran de connexion | RNF-71, § 7.1 |
| O-03 | Couper le réseau juste après chaque modification (pin, texte, renommage, suppression, réorganisation) | Aucune perte ; l'UI ne se fige pas | RNF-73, RNF-51 |
| O-04 | Remplir le disque, puis importer une photo | Erreur claire et non bloquante, album intact | RNF-21 |
| O-05 | Réinstaller l'application | Cas traité comme une nouvelle installation ; l'export `.photopush` est le seul chemin de restauration (§ 3.11) | RF-142 |
| O-06 | Ouvrir l'app après 30 jours hors ligne avec un compte configuré | Fonctionne ; bandeau discret « hors ligne » ; aucune tentative de blocage | RNF-72, RNF-77 |
| S-01 | Créer 3 albums hors ligne, se connecter | Les 3 sont poussés sur le compte | SYNC-25, SYNC-83 |
| S-02 | Appareil A et B, A ajoute une punaise, B synchronise | La punaise apparaît chez B, à la bonne position | SYNC-21, § 4.3 |
| S-03 | A renomme un album pendant que B le renomme | Le plus récent (HLC) gagne ; le perdant est journalisé | § 6.4, SYNC-40 |
| S-04 | A supprime une diapositive pendant que B la modifie | La suppression l'emporte ; notification chez B ; restauration possible 30 j | § 6.4, SYNC-50 |
| S-05 | A et B importent la même photo | Un seul `assetId` ; stockage non dupliqué | SYNC-31 |
| S-06 | A édite hors ligne 5 min, B édite hors ligne 5 min, reconnexion simultanée | Convergence, aucun état intermédiaire incohérent | § 6.4 |
| S-07 | Upload d'un média interrompu à 40 % | Reprise sans recommencer de zéro | SYNC-32 |
| S-08 | Serveur indisponible 1 h, puis retour | Synchronisation automatique sans action utilisateur | SYNC-24 |
| S-09 | Couper le Wi-Fi, juste avant un push | Opération conservée en outbox, rejouée | SYNC-20, SYNC-22 |
| S-10 | Deux appareils, révoquer A depuis B | A se resynchronise intégralement | SYNC-63 |
| A-01 | Lecteur d'écran VoiceOver sur la visionneuse | Chaque punaise annoncée avec son action | RNF-61 |
| A-02 | Police système à 200 % | Aucun élément critique tronqué | RNF-62 |

---

# 11. Trace du format de données WP8 (documentaire — hors produit)

> **Ce chapitre n'est pas une spécification.** L'ancien format n'est ni lu, ni écrit, ni converti, par l'application **ou par un outil tiers**. Il est conservé pour deux raisons : (a) garder la mémoire technique de l'existant, (b) documenter ce qu'il ne faut surtout pas reproduire. Aucun package `pp_legacy`, aucun parseur XML, aucune dépendance XML dans l'application (§ 6.1).

## 11.1 Décision

| Point | Décision |
|---|---|
| Lisibilité par l'application du XML WP8 | **Non.** Aucun code de parsing dans `apps/mobile` ni dans `packages/`. |
| Écriture d'un format compatible WP8 | **Non.** Le format cible est JSON/SQLite (§ 5.1, § 6.5). |
| Maintien d'un schéma « pont » dans la base locale | **Non.** Aucun champ « legacy ». |
| **Récupération des albums WP8 existants** | **Non. On ne récupère rien** (décision D-7, § 14.1). Ni dans l'application, ni par un script externe. |
| Conservation de la documentation du format | **Oui**, ici, à titre de référence historique. |

**Conséquence assumée** : les albums créés sous Windows Phone sont **perdus**. Aucune voie de conversion n'est prévue, y compris hors application : le coût d'un convertisseur (résolution des chemins photothèque, approximation des coordonnées de punaises, correspondances d'ids) ne le justifie pas. On conserve les **usages** de l'existant, pas ses données. Le seul mécanisme de portabilité est l'export `.photopush` (RF-142/143), qui s'applique aux albums créés dans la nouvelle application.

## 11.2 Ce que l'ancien format contenait (pour mémoire)

`LocalFolder/albumsPhoto/<NomAlbum>` — un fichier XML par album, le nom de fichier portant le nom de l'album ; `LocalFolder/listeAlbumsPhoto` — un index des albums ; les photos, elles, n'étaient pas dans l'application mais référencées par chemin dans la photothèque.

Le contenu d'un fichier d'album était de la forme :

```xml
<AlbumModele>
  <NomAlbum>Vacances</NomAlbum>
  <ListeDiapos>
    <DiapoModele>
      <ListeOuvertures>
        <Ouverture>          <!-- punaise neutre -->
          <PourcentageX>213.5</PourcentageX>      <!-- en pixels d'écran, pas en % -->
          <PourcentageY>148.25</PourcentageY>
          <TailleCarre>1</TailleCarre>            <!-- 1..3 -->
          <UriImageCarre>carreNoir.png</UriImageCarre>
          <LargeurPhotoInitiale>480</LargeurPhotoInitiale>
          <HauteurPhotoInitiale>640</HauteurPhotoInitiale>
        </Ouverture>
        <OuvertureTexte>… <TexteCible>Le sommet</TexteCible></OuvertureTexte>
        <OuvertureDiapo>… <IdDiapoCible>3</IdDiapoCible></OuvertureDiapo>
        <OuvertureTexteDiapo>… <TexteCible>…</TexteCible> <IdDiapoCible>2</IdDiapoCible></OuvertureTexteDiapo>
      </ListeOuvertures>
      <TitreDiapo>La montée</TitreDiapo>
      <CheminImage>\ProgramData\Microsoft\Windows\Photos\…\IMG_0001.jpg</CheminImage>
      <Commentaire>Été 2024</Commentaire>
      <IdDiapo>0</IdDiapo>                       <!-- id local 0..49 -->
    </DiapoModele>
  </ListeDiapos>
  <IdDiapoDispoTab>true</IdDiapoDispoTab>       <!-- × 50, table d'alloc d'ids -->
</AlbumModele>
```

## 11.3 Ce qu'il ne faut surtout pas reproduire

- Un nom de fichier qui porte une donnée métier (le nom de l'album).
- Des coordonnées exprimées dans l'unité de l'écran et non dans celle de l'image (D2).
- Une table d'allocation d'ids sérialisée (`bool[50]`) qui n'est pas reconstruite au chargement (D4).
- Un polymorphisme de sérialisation par héritage (`[XmlInclude]`) (D5).
- Des chemins vers des fichiers que l'application ne possède pas (D3).
- Une couche de persistance qui dépend de la vue (D6).

---

# 12. Plan de livraison

> Le plan est **séquencé par priorité, pas par fonctionnalité** : le cœur hors ligne (P0) est livré, testé et publiable **avant** que le moindre serveur n'existe. Une équipe peut s'arrêter à la Phase 1+2 et avoir un produit complet.

## Phase 0 — Socle hors ligne (2 semaines)

- Monorepo, `pp_domain`, `pp_data` (schéma + migrations), squelette d'app, CI.
- Thème, i18n (fr/en), navigation.
- Drapeau de compilation `PP_ONLINE` : le build par défaut est **local-only**.
- **Jalon** : application vide qui démarre, affiche une liste d'albums vide depuis SQLite, **sans aucune dépendance réseau**.

## Phase 1 — Fonctionnel local (5 semaines)

- Albums (création, renommage, corbeille, couverture).
- Diapositives (photo/commentaire, ajout, suppression, réorganisation).
- Visionneuse (zoom/pan/flick/flèches/bulles/fil d'Ariane/barre immersive/pins masquables).
- Éditeur (création de punaises, texte, liens, réglages couleur/taille, sauvegarde auto).
- Gestion des médias (import, copie, hachage, vignettes, cache).
- Export/import d'archive `.photopush` (portabilité sans réseau).
- **Jalon** : **toutes les fonctionnalités `RF-01 → RF-144` et `R-xx`/`LIM-xx` reproduites, en local, testées**, recette complète en mode avion (O-01 → O-06).

> C'est le jalon de validation le plus important : il garantit la complétude du produit hors ligne, avant d'ajouter la complexité réseau. **L'application est publiable en l'état à la fin de cette phase.**

## Phase 2 — Publication du cœur (2 semaines)

- Performance (RNF-10 → RNF-18), accessibilité, i18n complète.
- Goldens, tests de robustesse hors ligne (O-01 → O-06), audit de l'exigence « zéro réseau ».
- Build Android/iOS, signatures, stores.
- Documentation utilisateur.
- **Jalon** : **version 1.0 hors ligne, publiable**. Le reste du document devient facultatif.

## Phase 3 — Serveur (4 semaines) — P1

- API auth, CRUD, schéma Postgres, stockage objet.
- Journal de modifications (`change_log`), `entity_fields`, idempotence.
- Worker média (vignettes, EXIF).
- SSE, quotas, rate limiting.
- **Jalon** : API documentée (OpenAPI), serveur déployable en local via Docker Compose.

## Phase 4 — Synchronisation (4 semaines) — P1

- Moteur client (outbox, pull, push, HLC, LWW, `OrderKey`).
- Client HTTP généré depuis l'OpenAPI, refresh de jetons.
- Upload média (blocs, reprise, déduplication).
- Conflits, journal, corbeille distribuée, appareils.
- Tests de convergence avec faux serveur.
- **Jalon** : **convergence multi-appareils démontrée** par les scénarios S-01 → S-10, **sans régression sur la recette hors ligne** (la suite O-* repasse au vert).

## Phase 5 — Durcissement & livraison connecté (2 semaines) — P1

- Goldens E2E, load test, documentation du serveur, guide de déploiement.
- **Jalon** : version 1.1 (cœur inchangé + mode connecté).

**Total : P0 ≈ 9 semaines (1 personne) / 6 semaines (2 personnes) · P1 ≈ 10 semaines (1 personne) / 5 semaines (2 personnes).**

## 12.1 Découpage recommandé en lots livrables

| Lot | Priorité | Contenu |
|---|---|---|
| L1 | P0 | Socle + albums + import média |
| L2 | P0 | Visionneuse complète |
| L3 | P0 | Éditeur complet + réglages punaises |
| L4 | P0 | Recette hors ligne (mode avion) + export/import `.photopush` |
| L5 | P0 | **Publication de la v1.0 hors ligne** |
| L6 | P1 | Serveur : auth + CRUD + médias |
| L7 | P1 | Synchronisation des métadonnées |
| L8 | P1 | Synchronisation des médias + conflits + appareils |
| L9 | P1 | Durcissement + publication de la v1.1 |

---

# 13. Risques et mitigation

| ID | Risque | Prob. | Impact | Mitigation |
|---|---|---|---|---|
| K-01 | Perte de fidélité fonctionnelle (certains détails de l'UX existante sont subtils) | Élevée | Élevé | Phase 1 dédiée à la parité, avec un **corpus de captures d'écran WP8** comme référence de recette |
| K-02 | La géométrie normalisée des punaises se comporte mal sur les cas tords : image non carrée, orientation EXIF, zoom + rognage, très grande image | Moyenne | Élevé | Tests de géométrie exhaustifs (§ 5.2), recette U-02, calcul via un seul `Transform`, test d'invariance multi-résolutions |
| K-03 | Complexité de la convergence (LWW + fractionnaire + médias) | Élevée | Élevé | Faux serveur de test early ; tests de convergence property-based ; protocoles d'op idempotents |
| K-04 | Application dorsale d'images volumineuse sur mobile | Moyenne | Élevé | Cache LRU, variantes, isolation, préchargement borné, `cached_network_image` |
| K-05 | L'utilisateur ne veut pas héberger de serveur | Élevée | Élevé | Fournir une image Docker mono-commande ; documenter le déploiement ; le mode local reste complet |
| K-06 | La galerie photo devient gigantesque | Moyenne | Moyen | Pagination + `LongListSelector` équivalent, groupement alphabétique, recherche |
| K-07 | L'export/import d'archive n'est pas réellement interopérable | Moyenne | Moyen | Test de bout en bout d'export → import, sur 2 versions de schéma |
| K-08 | Le stockage objet du serveur devient coûteux | Moyenne | Moyen | Déduplication par hash, variantes, quota par compte, URLs signées |
| K-09 | Multiplicité des appareils non gérée | Moyenne | Moyen | Liste des appareils + révocation + resync complet (SYNC-63) |
| K-10 | Scope creep sur le partage / multi-utilisateurs | Moyenne | Moyen | Hors périmètre v1, explicitement documenté (§ 2.4) |
| K-11 | **Dérive du cœur vers le réseau** : une fonctionnalité du P0 glisse insensiblement dans le P1 (lecture directe d'une API, garde `if (isSynced)`) | Élevée | **Élevé** | Drapeau `PP_ONLINE` ; lint d'interdiction d'import `pp_api` hors `pp_sync` ; recette O-01 en build local-only ; revue de code sur § 0.1 |
| K-12 | L'existant est compilé sous Windows Phone ; personne ne peut le lancer pour vérification | Élevée | Moyen | S'appayer sur le code + les captures ; documenter les incertitudes ; implémenter les usages plutôt que les bugs |
| K-13 | Les albums WP8 de l'utilisateur sont définitivement perdus | **Élevée** | **Élevé** | **Accepté et assumé** (D-7) : aucune voie de récupération n'est prévue. Mitigation partielle : `.photopush` en export/import dès le P0, pour que la perte ne se reproduise pas après la migration |
| K-14 | Le serveur devient un point de défaillance unique pour l'utilisateur connecté | Moyenne | Moyen | File d'attente persistante, reprise automatique, « Travailler hors ligne » toujours accessible (RNF-77) |

---

# 14. Registre de décisions

## 14.1 Décisions déjà tranchées

| # | Décision | Statut |
|---|---|---|
| D-1 | **Hors-lignisme** : le produit est complet sans réseau ni compte ; le mode en ligne est un ajout | **Actif** (§ 0.1, § 7.1) |
| D-2 | **Aucune compatibilité de format avec le WP8** ; pas de XML dans l'application ; le format ancien reste documenté | **Actif** (§ 11.1) |
| D-7 | **Aucune récupération des données WP8** : ni import dans l'application, ni script de conversion externe. Les albums de l'ancienne version sont perdus | **Actif** (§ 0.1, § 11.1) |
| D-3 | Base locale (SQLite) = source de vérité ; le réseau ne fait que remplir une file d'attente | **Actif** (§ 6.2) |
| D-4 | Coordonnées de punaises normalisées sur l'image | **Actif** (§ 5.2) |
| D-5 | Les médias sont **copiés** dans le sandbox, jamais référencés | **Actif** (§ 5.4) |
| D-6 | Limites « Free » supprimées, remplacées par des plafonds configurables | **Actif** (§ 4.7) |

## 14.2 Décisions à trancher avant la Phase 3 (serveur)

| # | Question | Options | Recommandation |
|---|---|---|---|
| D-A | Langage du serveur | Go, TypeScript/NestJS, Python/FastAPI, Dart/shelf | **Go** ou **NestJS**. Le contrat OpenAPI est figé en premier. |
| D-B | Hébergement | Managé (à proposer) vs auto-hébergé | **Les deux**. Fournir un `docker compose up` et documenter l'hébergement managé. |
| D-C | Authentification | JWT maison vs OIDC (Keycloak/Zitadel) | **OIDC** dès qu'un service d'identité est disponible ; JWT maison en v1 pour la simplicité. |
| D-D | Chiffrement de bout en bout | v1 non, v2 oui | **Non en P1**, mais **conserver la structure `entity_fields`** pour ne pas bloquer. |
| D-E | Partage d'albums | v1 non | **Non**, sauf demande explicite. |
| D-F | Export PDF / présentation | v1 non | **Non**. |
| D-G | Polices de conflit | `deleteWins` vs `askUser` | **`deleteWins` + corbeille** en v1 ; `askUser` en mode expert. |
| D-H | Support des très grandes images | > 50 Mpx | **Refuser** (limite 25 Mio / 40 Mpx), message clair. |
| D-I | Application tablette | v1 non | Layout responsive prévu dès le P0, optimisation tablette en v1.1. |
| D-J | Rétention du journal de sync | 90 j | **90 j**, puis resync complet. |

---

# 15. Annexe A — Correspondance fichier → exigence

| Fichier legacy | Écrans Flutter | Exigences principales |
|---|---|---|
| `MainPage.xaml(.cs)` | `AlbumListScreen` | RF-01 → RF-12 |
| `AjoutAlbum.xaml(.cs)` | `CreateAlbumSheet` | RF-13 → RF-18 |
| `PhotoVisualisationPage.xaml(.cs)` | `SlideViewerScreen` (photo) | RF-20 → RF-38 |
| `PhotoEditPage.xaml(.cs)` | `SlideEditorScreen` (photo) | RF-40 → RF-61 |
| `CommentVisualisationPage.xaml(.cs)` | `SlideViewerScreen` (commentaire) | RF-70 → RF-76 |
| `CommentEditPage.xaml(.cs)` | `CommentEditorScreen` | RF-80 → RF-87 |
| `AjoutDiapo.xaml(.cs)` | `AddSlideSheet` | RF-90 → RF-96 |
| `ChoisirDiapoLink.xaml(.cs)` | `PinTargetPickerSheet` | RF-48 → RF-50 |
| `AllerADiapo.xaml(.cs)` / `AllerADiapoList.xaml(.cs)` | `GoToSlideSheet` | RF-120 → RF-123 |
| `ReorganizeAlbum.xaml(.cs)` | `ReorderSlidesScreen` | RF-110 → RF-115 |
| `OverturesSettings.xaml(.cs)` | `PinSettingsScreen` | RF-100 → RF-106 |
| `Modele/*.cs` | `pp_domain` | § 5.1, § 5.2 |
| `ModeleVue/Gestion*.cs` | Riverpod providers | § 6.6 |
| `ModeleVue/SerialisationUtilitaires.cs` | *(aucun équivalent)* | Éliminé : SQLite/Drift, pas de XML (D5, § 11.1) |
| `ModeleVue/Bridage.cs` | `AppLimits` | § 4.7 |
| `AlphaKeyGroup.cs` | `alphabetical_groups` (package Dart) | RF-01, RF-121 |
| `Converteurs/*.cs` | — (supprimés) | corrigés par D12 |
| *(nouveau)* | `SettingsScreen` | § 8.1 |
| *(nouveau)* | `LoginScreen` / `RegisterScreen` (P1) | § 8.2 |
| *(nouveau)* | `services/api` (P1) | § 7.12 |

# 16. Annexe B — Glossaire

| Terme | Définition |
|---|---|
| **Album** | Conteneur nommé d'une liste ordonnée de diapositives. |
| **Diapositive (slide)** | Élément d'un album : photo, commentaire, ou les deux. |
| **Punaise (pin)** | Marqueur carré posé sur une photo, portant éventuellement un texte et/ou un lien. |
| **Cible de lien** | Diapositive vers laquelle une punaise navigue. |
| **Fil d'Ariane** | Pile des diapositives parentes lors d'une navigation par liens. |
| **HLC** | Hybrid Logical Clock — horloge hybride pour l'horodatage des opérations. |
| **LWW** | Last-Writer-Wins — résolution de conflit par dernier écrivain. |
| **OrderKey** | Clé d'ordre fractionnaire, garantissant un ordre total convergent. |
| **Tombstone** | Marque de suppression propagée, nécessaire pour éviter les résurrections. |
| **Outbox** | File d'attente locale des opérations à pousser vers le serveur. |
| **Sandbox** | Espace de stockage privé de l'application. |
| **Hors ligne / offline** | État de fonctionnement normal de l'application : aucun réseau utilisé, toutes les fonctions disponibles. |
| **P0 / P1** | P0 = cœur hors ligne obligatoire et publiable seul ; P1 = extension en ligne optionnelle. |
| **Build local-only** | Build compilé avec `PP_ONLINE=false` : ni `pp_sync`, ni `pp_api`, ni `pp_auth` — preuve mécanique du hors-lignisme. |
| **Mode avion (recette)** | Exécution de la suite de tests avec tout accès réseau intercepté et bloqué. |
