# Fichier de configuration pour latexmk (latexmkrc)

# 1. Utiliser le compilateur Pdflatex
$pdflatex = 'pdflatex -interaction=nonstopmode %O %S';

# 2. Utiliser Biber au lieu de BibTeX
$bibtex = 'biber %O %S';
$biber = 'biber';

# 3. Spécifier le format de sortie (PDF)
$pdf_mode = 1;

# 3bis. Répertoires de sortie/auxiliaires
$out_dir = 'build';
$aux_dir = 'build';

# 4. Forcer la compilation jusqu'à ce que le fichier soit stable
$force_mode = 1;

# 5. Biber control file extension
$biber_aux_ext = 'bcf';

# 6. FIX CRITIQUE : DÉFINITION EXPLICITE DES FICHIERS À SUPPRIMER POUR LA COMMANDE -C
# Nous utilisons la variable dédiée au nettoyage complet et y ajoutons les fichiers Biber.
# (Notez l'espace au début de la chaîne pour la séparation des extensions)
$clean_full_ext .= ' bbl bcf run.xml';
