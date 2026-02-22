## Style Sciences Po

Ce style reprend les exigences du mémorandum Sciences Po (cf. [Mémorandum Sciences Po](https://www.sciencespo.fr/bibliotheque/sites/sciencespo.fr.bibliotheque/files/Citer-sources-rediger-bibliographie-fr-2024.pdf)) en s'appuyant sur les trois fichiers suivants :

- `sciencespo.cbx` : gestion des citations en notes (`ibid.`/`op. cit.`, ajout du `shorttitle`).
- `sciencespo.bbx` : format de la bibliographie (noms en majuscules, ordre des éléments).
- `biblatex-dm.cfg` : déclaration des champs additionnels (mois textuel, plateforme vidéo, discipline, etc.).

Ils sont basés sur `biblatex` avec `biber` et couvrent tous les exemples du mémo : livres, rapports, chapitres, articles, thèses, films, vidéos en ligne, articles en ligne, sites web, *podcasts*, etc.

## Utiliser ce dépôt comme *subtree* Git

Ce projet peut être intégré dans un autre dépôt avec `git subtree`, tout en conservant les mêmes cibles de *build* (`pdf`, `pdf-demo`, `clean`).

Exemple de commande d'ajout :

```bash
git subtree add --prefix=vendor/biblio <repo-url> <branch-or-tag> --squash
```

### Surcharger `STYLE_DIR` et `BIB_DIR` depuis un projet externe

Lors d'un *build* depuis le dépôt parent, les chemins du style et des bibliographies peuvent être surchargés au moment de l'appel :

```bash
make -C vendor/biblio pdf \
  STYLE_DIR=../my-project/latex/style \
  BIB_DIR=../my-project/latex/bibliographies
```

Il est recommandé de définir ces surcharges dans des cibles *wrapper* du `Makefile` du projet parent, afin d'aligner les exécutions locales et CI.

### Comportement du build Docker depuis un autre dépôt

Avec `USE_DOCKER=1`, le `Makefile` du subtree exécute `docker compose` depuis le dossier du *subtree* et monte ce *subtree* dans le conteneur sous `/app`.

- `LATEXMK` et `LATEXMK_CLEAN` sont partagés et transmis à Docker.
- `TEXINPUTS`, `BIBINPUTS` et `BSTINPUTS` sont exportés et transmis à Docker, ce qui garantit la cohérence des surcharges de chemins.
- La sortie reste dans `/app/build` et `main.pdf` est copié à la racine du subtree.
- La identifiants `UID`/`GID` sont conservés (avec par défaut `1000:1000`).

Exemple :

```bash
make -C vendor/biblio pdf USE_DOCKER=1
```

### Bonnes pratiques pour les mises à jour du *subtree*

1. Utiliser une branche ou un tag stable et l'option `--squash` pour conserver un historique lisible dans le dépôt parent.
2. Conserver les personnalisations spécifiques au parent dans des cibles *wrapper* ou des variables CI, plutôt que d'éditer les fichiers vendorisés.
3. Récupérer les mises à jour avec :
   ```bash
   git subtree pull --prefix=vendor/biblio <repo-url> <branch-or-tag> --squash
   ```
4. Après chaque mise à jour, valider `pdf`, `pdf-demo` et `clean` en mode local et en mode Docker.
