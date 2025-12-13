# Dockerfile
# Utilise l'image officielle TeX Live complète (contient pdflatex, biber,
# latexmk, etc.)
FROM docker.io/texlive/texlive:latest

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Point d'entrée par défaut: lance latexmk sur le fichier fourni
# (Le fichier sera monté via docker-compose)
CMD ["latexmk", "-pdf", "-xelatex", "main.tex"] 
# NOTE: Utilisation de xelatex pour une meilleure compatibilité Unicode, 
# mais pdflatex est souvent suffisant. 
# Si vous n'utilisez pas de polices avancées, changez "-xelatex" par "-pdflatex"
