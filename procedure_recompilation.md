# Méthode de recompilation

Ce document permet de reconstruire tous les fichiers .exe qui sont présents dans ce repository.

Il devrait également permettre de créer des exécutables binaires pour d'autres systèmes (Mac, Linux, ...). Mais cela n'a pas été testé.


## Récupération du compilateur

Allez sur le site : https://www.freepascal.org/

Sélectionnez "Download", puis "Windows 64-bit", puis n'importe quelle site de téléchargement (le plus simple étant SourceForge).

Vous récupérerez un fichier ayant ce nom : `fpc-3.0.4.i386-win32.exe` (Le numéro de version 3.0.4 peut avoir changé).

Exécuter ce fichier pour installer le compilateur.

Sélectionner "Full installation".

Il est conseillé de définir un répertoire de destination écrit en majuscules (comme à la bonne époque du DOS), et sans espaces. Par exemple : `C:\PASCAL\3.0.4`.

Les autres options à définir durant l'installations sont assez simples, et peu significatives.




## Récupération des codes sources

Télécharger ou cloner ce repository sur votre disque.

Dans la suite de cette documentation, on supposera que le contenu de ce repository a été placé dans `C:\repo_git\prog_pascal`

Tous les fichiers *.pas utilisent l'encodage de caractère du MS-DOS : CP 437

https://fr.wikipedia.org/wiki/Page_de_code_437


fpc <nom du fichier .pas>

