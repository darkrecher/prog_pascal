# Méthode de recompilation

Ce document permet de reconstruire tous les fichiers .exe qui sont présents dans ce repository.

Il devrait également permettre de créer des exécutables binaires pour d'autres systèmes (Mac, Linux, ...). Mais cela n'a pas été testé.


## Récupération du compilateur

Allez sur le site : https://www.freepascal.org/

Sélectionnez "Download", puis "Windows 64-bit", puis n'importe quelle site de téléchargement (le plus simple étant SourceForge).

Vous récupérerez un fichier ayant ce nom : `fpc-3.0.4.i386-win32.exe` (Le numéro de version 3.0.4 peut avoir changé).

Pour info, les liens sont les mêmes, et le fichier téléchargé est le même, que l'on choisisse "Windows 32-bit" ou "Windows 64-bit".

Exécuter ce fichier pour installer le compilateur.

Sélectionner "Full installation".

Il est conseillé de définir un répertoire de destination écrit en majuscules (comme à la bonne époque du DOS), et sans espaces. Par exemple : `C:\PASCAL\3.0.4`.

Les autres options à définir durant l'installations sont assez simples, et peu significatives.


## Récupération des codes sources

Télécharger ou cloner ce repository sur votre disque.

Dans la suite de cette documentation, on supposera que le contenu de ce repository a été placé dans `C:\repo_git\prog_pascal`

À l'origine, tous les fichiers *.pas étaient écrits avec l'encodage de caractère du MS-DOS : [CP 437](https://fr.wikipedia.org/wiki/Page_de_code_437).

Ils ont été reconvertis en "Western Windows 1252", afin que les informations écrites sur la sortie standard s'affichent mieux dans la console. (Désolé si votre console n'est pas dans cet encodage, c'est ce que j'ai chez moi).

Le premier commit de chaque fichier .pas est tel qu'il était lorsque je l'ai codé à l'époque, encodé en CP 437. Les commits suivants changent l'encodage et éventuellement apportent des modifs diverses.

Les accents et autres caractères spéciaux s'affichent mal lorsqu'on ouvre les fichiers dans l'IDE de Free Pascal. Le but de ce repository est d'avoir des codes sources et des exécutables qui fonctionnent le mieux possible avec les machines modernes. Tant pis si pour cela, il faut faire une petite entorse aux souvenirs de cette ancienne époque.

Il existe des colorations syntaxiques du Pascal pour les IDE actuels. Par exemple, pour Sublime Text, le package [ST-Pascal](https://github.com/fnkr/ST-Pascal), v2017.08.13.14.19.23.

L'IDE de Free Pascal n'est pas nécessaire pour recompiler les codes sources. Il suffit d'utiliser l'outil en ligne de commande `fpc`, qui est disponible si vous avez installé le Free Pascal.

Pour vérifier si cet outil est disponible, il faut ouvrir une invite de commande MS-DOS, et écrire `fpc`. Si un grand texte d'information s'affiche, c'est OK.

Si un message indiquant que ce programme n'est pas reconnu, c'est que le répertoire des binaires du Free Pascal n'a pas été ajoutée dans le PATH. Dans ce cas, essayez la commande `C:\PASCAL\3.0.4\bin\i386-win32\fpc.exe`. Si le texte d'informaton s'affiche, c'est OK, mais dans la suite de cette documentation, vous devrez remplacer toutes les commandes `fpc` par `C:\PASCAL\3.0.4\bin\i386-win32\fpc.exe`.

Si ce n'est toujours pas OK, c'est que le Free Pascal a été installé à un autre endroit de votre disque. Dans ce cas, re-essayer la commande précédente, en remplaçant `C:\PASCAL\3.0.4\` par votre emplacement d'installation.


## Recompilation des exécutables simples

#### artifice.exe

`cd C:\repo_git\prog_pascal\animation`

`fpc artifice.pas`

#### boutons.exe

`cd C:\repo_git\prog_pascal\divers`

`fpc boutons.pas`

