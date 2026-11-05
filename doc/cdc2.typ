#import "styles.typ": report_template, tableau, th

#show: report_template

#let accent = rgb("#1f4e79")
#let gris = rgb("#f2f4f7")

// pdg

#page(margin: 2.5cm, header: none, footer: none)[
  #v(0.4cm)
  #text(size: 32pt, weight: "bold", fill: accent)[Photo Push]
  #v(0.2cm)
  #text(
    size: 14pt,
  )[Réécriture Flutter d'une application d'albums photo interactifs, légère et 100 % hors ligne, avec import/export manuel et synchronisation distante optionnelle]
  #v(1fr)
  #tableau(
    columns: (4cm, 1fr),
    [#th[]],
    [#th[]],
    [Projet source],
    [PhoneAppPhoto (Windows Phone 8.1, Silverlight)],
    [Cible],
    [Application Flutter, Android (API 26+) et iOS (13+)],
    [Version],
    [1.1],
    [Statut],
    [À valider],
  )
]

#outline(title: "Sommaire", depth: 1, indent: 1em)
#pagebreak()


// ───────────── 1 ─────────────
= Contexte et objectifs

== Contexte
L'application existante est un livre photo interactif pour Windows Phone 8.1.

L'utilisateur crée des albums composés de diapositives (photo, commentaire, ou les deux). Sur une photo, il pose des "punaises" qui portent un texte (bulle) et/ou un lien vers une autre diapositive. La navigation se fait par glissement, flèches ou liens.

La plateforme est obsolète et l'application présente des défauts structurants : état global statique, coordonnées de punaises en pixels d'écran (donc non portables), photos référencées par chemin (l'album casse si la photo est supprimée), persistance XML fragile avec perte de données, limites artificielles (8 albums, 12 diapositives, 5 punaises).

La nouvelle version assume la simplicité apparente de l'existant : une application légère, utilitaire, avec peu de persistance, peu d'appels réseau, et simple à utiliser, à créer et à échanger.

== Objectifs
#tableau(
  columns: (1.6cm, 1.6cm, 1fr),
  [#th[ID]],
  [#th[Priorité]],
  [#th[Objectif]],
  [OBJ-1],
  [P0],
  [Fonctionner intégralement hors ligne, sans compte ni serveur],
  [OBJ-2],
  [P0],
  [Réécrire en Flutter en conservant tous les usages de la version existante],
  [OBJ-3],
  [P0],
  [Supprimer les défauts structurants de l'existant],
  [OBJ-4],
  [P0],
  [Albums simples et portables : un album = un dossier (fichier JSON + images), échangeable par import/export manuel],
  [OBJ-5],
  [P0],
  [Laisser le choix du stockage des photos : lien direct avec la galerie ou copie dans l'application (avec limites)],
  [OBJ-6],
  [P0],
  [Robustesse : écritures atomiques, validation à la lecture, nettoyage des fichiers orphelins],
  [OBJ-7],
  [P0],
  [Base testable et maintenable (tests unitaires, architecture en couches)],
  [OBJ-8],
  [P1],
  [Échange réseau optionnel : synchronisation manuelle d'un album de référence via un stockage S3],
)

== Principes directeurs
+ Hors ligne par défaut. Toute fonctionnalité du cœur marche en mode avion, sans compte.
+ L'unité, c'est l'album : un dossier contenant un fichier JSON et ses images. Pas de base de données : l'application lit ces fichiers et les écrase, ils sont la source de vérité.
+ Simplicité avant sophistication. Une fonction n'est ajoutée que si elle est pertinente pour l'usage. Le réseau n'est sollicité que sur action explicite de l'utilisateur.
+ Robustesse. Écritures atomiques, validation des fichiers lus, nettoyage des fichiers orphelins.
+ Le choix reste à l'utilisateur pour ses photos : galerie ou stockage dans l'application.

= Périmètre

#grid(
  columns: (1fr, 1fr),
  gutter: 14pt,
  [
    == Application (P0)
    - Albums : création, renommage, duplication, suppression avec confirmation
    - Diapositives : ajout, édition, suppression, réorganisation
    - Punaises : création, texte, liens, couleur et taille, masquage
    - Visionneuse : zoom/pan, liens, fil d'Ariane, mode immersion
    - Photos : lien galerie ou copie dans l'app (avec limites)
    - Écran de gestion des fichiers et nettoyage
    - Export/import d'archive `.photopush`
  ],
  [
    == Extension (P1, optionnelle)
    - Écran de synchronisation manuel
    - Accès à un stockage S3 avec authentification
    - Album de référence distant
  ],
)

#pagebreak(weak: true)
= Exigences fonctionnelles

#tableau(
  columns: (3.4cm, 1fr, 1.7cm),
  [#th[Module]],
  [#th[Exigences clés]],
  [#th[Prio.]],
  [Liste des albums],
  [Groupement alphabétique (insensible à la casse et aux accents) ; imagette = propriété du dossier de l'album (fichier de couverture `cover.jpg` issu de la première photo, sinon titre de la diapositive 1) ; menu contextuel (renommer, dupliquer, supprimer avec confirmation) ; texte d'accueil si vide ; album illisible signalé sans bloquer la liste],
  [M],

  [Création d'album],
  [Nom de 1 à 80 caractères, trimé ; caractères de chemin interdits ; unicité insensible à la casse ; création du dossier et du fichier `album.json` ; enchaînement direct sur l'éditeur],
  [M],

  [Visionneuse photo],
  [Zoom 1$times$ à 6$times$ ancré au pincement ; flick avec bouclage ; flèches transitoires (1 s) ; bulles de punaises ; bouton retour `↩` selon la pile de liens ; masquage des punaises ; mode immersion ; rotation à chaud ; état « Image not found » avec ajout de photo],
  [M],

  [Éditeur photo],
  [Création de punaise par appui ; menu (texte, lien, supprimer) ; texte multi-lignes, 400 caractères max ; sélecteur de cible (bascule on/off) ; titre de 40 caractères max ; suppression de photo ; sauvegarde manuelle et automatique],
  [M],

  [Commentaires],
  [Visionneuse et éditeur dédiés ; bascule automatique vers la photo si le commentaire est absent ; compteur de caractères au-delà de 350],
  [M / S],

  [Ajout de diapositive],
  [Choix Photo (caméra activée) ou Commentaire ; insertion après la diapositive courante ; titre par défaut « Titre $n$ » ; photo enregistrée selon le mode de stockage choisi],
  [M],

  [Stockage des photos],
  [Choix laissé à l'utilisateur (défaut dans les réglages, modifiable à l'ajout) : (a) lien direct avec la galerie ; (b) copie dans le dossier de l'album, avec limites (côté long ≤ 2048 px, donc compression potentielle) ; photo liée supprimée de la galerie : état « Image not found » avec ré-association],
  [M],

  [Gestion des fichiers],
  [Nouvel écran : liste des albums avec espace occupé, contenu du dossier d'un album (fichier JSON, images), suppression d'images, import manuel, export ; action « Nettoyer » (images non référencées, fichiers temporaires, liens orphelins) avec récapitulatif avant suppression],
  [M],

  [Import / export],
  [Archive `.photopush` = dossier de l'album compressé (`album.json` + images) ; export par la feuille de partage du système (Drive, iCloud, OneDrive, messagerie…) ; import par le sélecteur de fichiers ; à l'export, les photos liées à la galerie sont rapatriées dans l'archive ; nom déjà pris : renommer, remplacer (avec confirmation) ou annuler ; archive invalide refusée sans toucher aux albums existants],
  [M],

  [Réglages de punaises],
  [6 couleurs (noir, blanc, vert, jaune, bleu, violet) ; taille 1 à 3 par pas de 0,5 ; réglages persistés ; appliqués aux nouvelles punaises uniquement],
  [M],

  [Réorganisation],
  [Glisser-déposer (mode « sélectionner puis cible » conservé) ; suppression avec confirmation ; liens orphelins signalés],
  [M],

  [Aller à…],
  [Suivant, précédent ou liste groupée par titre ; la sélection remet la pile de liens à zéro],
  [M],

  [Transverses],
  [Sauvegarde auto 1,5 s après modification ; langues fr et en ; accessibilité (cibles ≥ 48 dp, contraste ≥ 4,5:1, texte jusqu'à 200 %) ; thème clair/sombre suivant le système],
  [M / S],
)

= Modèle de données et architecture

== Modèle (fichiers JSON)
Pas de base de données. Chaque album est un dossier du stockage local de l'application, contenant un fichier `album.json` (lu et réécrit par l'application) et les images rapatriées :

```toml
albums/
  Mon voyage/
    album.json         -- modèle de l'album (source de vérité)
    cover.jpg          -- imagette de l'album
    images/
      photo_001.jpg    -- 1ère image de l'album
```

Trois niveaux imbriqués dans `album.json` :
- Album : nom, version du format, liste ordonnée de diapositives ;
- Diapositive : type (photo/commentaire), titre, commentaire, image, liste de punaises ;
- Punaise : position normalisée (0 à 1), taille, couleur, type, texte, diapositive cible.

L'image d'une diapositive est soit un chemin relatif au dossier de l'album (`images/…`), soit un identifiant de la galerie. L'ordre des diapositives est celui de la liste. Les positions normalisées rendent les punaises indépendantes de l'écran. Un album copié ou dupliqué reste valide : copier son dossier suffit. Supprimer un album supprime son dossier ; supprimer une diapositive supprime ses punaises.

Écriture robuste : fichier temporaire puis renommage atomique. Lecture validée : version du format, bornes (position, taille), liens vers des diapositives existantes. Un album illisible est signalé sans bloquer les autres.

== Gestion des médias
En mode « stockage dans l'app », la photo est redimensionnée si elle dépasse les limites, puis copiée dans `images/` (écriture atomique). En mode « galerie », seul l'identifiant est mémorisé. L'affichage décode les images à taille réduite ; aucun décodage plein résolution sur le fil de l'interface. Le nettoyage supprime les fichiers de `images/` que `album.json` ne référence plus.

== Architecture
Trois couches : interface (écrans), modèle (albums, diapositives, punaises) et stockage (lecture/écriture des dossiers et fichiers JSON). L'interface n'accède jamais directement aux fichiers.

= Extension (P1, optionnelle)

== Principe
Le cœur P0 est complet sans cette extension : l'import/export manuel suffit à échanger des albums, y compris via un cloud personnel grâce au partage du système. L'extension ajoute un échange réseau, toujours déclenché à la main depuis un écran dédié. L'unité d'échange reste l'album (JSON + images), exposé comme album de référence sur un stockage distant.

== Synchronisation manuelle
- Nouvel écran de synchronisation : liste des albums distants, actions « Récupérer » et « Envoyer ».
- Un album récupéré écrase la copie locale après confirmation (option : conserver les deux).
- Seules les images absentes sont transférées (comparaison nom + taille).
- En cas d'échec réseau : message clair, aucune modification locale, reprise possible.

== Accès au stockage distant et sécurité
- S3 (ou compatible, ex. MinIO) en priorité, choix confirmé par le besoin d'externaliser les albums ; derrière une interface de stockage unique, pour ajouter d'autres services plus tard.
- Authentification : clés d'accès saisies dans les réglages et conservées dans le trousseau système ; HTTPS obligatoire ; pas de télémétrie.
- Import sécurisé : chemins contenus dans l'archive contrôlés, taille maximale, format validé avant toute écriture.

= Exigences non fonctionnelles

#tableau(
  columns: (3.4cm, 1fr),
  [#th[Domaine]],
  [#th[Exigence]],
  [Hors ligne \ (bloquant)],
  [Toutes les exigences du cœur satisfaites sans réseau ni compte

    Aucun écran d'erreur réseau bloquant ni spinner infini

    Aucune dépendance à un service tiers (hors extension P1 déclenchée par l'utilisateur).],
  [Simplicité],
  [Aucune base de données : fichiers JSON + images

    Aucun appel réseau dans le cœur

    Peu de dépendances externes.],
  [Performance],
  [Démarrage à froid < 1,5 s

    Première image < 400 ms ;

    Zoom/pan à minimum 60 fps

    Positionnement des punaises sans décalage visible à l'œil nu.
  ],
  [Fiabilité \ (nettoyage)],
  [
    Aucune perte de données si l'application est tuée (écriture atomique)

    Import atomique : archive invalide refusée sans modifier l'existant

    Fichiers orphelins détectés et supprimables.
  ],
  [Qualité],
  [`flutter analyze`

    Tests unitaires (modèle JSON, lecture/écriture, nettoyage).
  ],
  [Accessibilité / i18n],
  [Cibles ≥ 48 dp et contraste ≥ 4,5:1

    Libellés TalkBack/VoiceOver

    Traduit en anglais et en français.],
  [Plateformes],
  [Android 8.0+, iOS 13+, Flutter stable ≥ 3.24, portrait et paysage.],
)

= Organisation de l'équipe

== Répartition
#tableau(
  columns: (3.4cm, 1fr, 1.6cm),
  [#th[Rôle]],
  [#th[Responsabilité]],
  [#th[Prio.]],
  [Affichage],
  [Affichage photo et punaises : visionneuse, éditeur, ergonomie du geste (zoom, pan, pose de punaise)],
  [P0],
  [Menus et écrans],
  [Navigation, menus et écrans : ergonomie, étude de design d'application, IHM],
  [P0],
  [Modèle et fichiers],
  [Modèle et persistance dans le téléphone ; gestion des fichiers de l'app (images et fichiers album) ; nouvel écran de gestion ; import manuel et export],
  [P0],
  [Synchronisation],
  [Synchronisation des fichiers album depuis un serveur : écran de synchronisation manuel, import/export réseau],
  [P1],
  [Accès distant],
  [Accès au dossier serveur (S3) avec authentification et sécurité],
  [P1],
)

== Suivi
- Avancement synchronisé entre les membres : dépôt partagé, une branche par rôle, point d'équipe régulier (discussion avec prise en compte des disponibilités des alternants).
- Points de suivi avec le demandeur à chaque jalon du planning.

= Planning

#tableau(
  columns: (3.4cm, 1fr, 2.6cm, 1.6cm),
  [#th[Phase]],
  [#th[Contenu et jalon]],
  [#th[Durée]],
  [#th[Prio.]],
  [0 — Socle],
  [Dépôt, structure du projet, modèle JSON, i18n.

    Jalon : modèle de l'app.],
  [2 sem.],
  [P0],
  [1 — Affichage],
  [Albums, diapositives, visionneuse, éditeur, stockage des photos (galerie / app), écran de gestion des fichiers, import/export.

    Jalon : Première version fonctionnelle hors ligne.],
  [5 sem.],
  [P0],
  [2 — Finalisation],
  [Robustesse (nettoyage), performance, accessibilité, tests, préparation de la soutenance.

    Jalon : v1.0 hors ligne démontrable.],
  [2 sem.],
  [P0],
  [3 — Extension],
  [Écran de synchronisation manuel, accès distant (S3), import/export réseau.],
  [3 sem.],
  [P1],
)

// == Soutenance
// Durée : 20 min, soit 10 min de présentation (diaporama) et 10 min de questions. Chaque membre présente une partie qu'il a réalisée. La présentation couvre :
// + l'existant : application mobile de livre photo pour Windows Phone ;
// + son architecture : C\#/XAML ;
// + le fonctionnel cible : améliorations par rapport à l'existant ;
// + les choix techniques : reprise et différences par rapport à l'existant ;
// + la nouvelle architecture : conception Flutter ;
// + la répartition des tâches, le suivi de l'avancement et les points avec le demandeur ;
// + une démonstration de la nouvelle application.
