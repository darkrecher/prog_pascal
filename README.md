# Programmes écrits en Pascal

Ce repository regroupe mes anciens programmes écrits dans le langage Pascal, à une époque indéterminée et assez lointaine (j'étais au lycée, puis à l'UTBM).


## Recompilation des exécutables simples

Il est possible de recompiler, avec l'éditeur Free Pascal, les codes sources qui ne font pas trop appel à des fonctions bas niveau des machines de l'époque.

Voir : [procedure_recompilation.md](procedure_recompilation.md).


## Test de la librairie SDL

Pour réussir à refaire marcher tous ces programmes, il a été envisagé de recoder les librairies spécifiques (en particulier McgaGraf), en utilisant la SDL. La SDL (Simple DirectMedia Layer) est une librairie dédiée aux jeux vidéos, permettant de piloter l'écran, de récupérer les événements claviers et souris, etc.

Quelques tests rapides ont été réalisés dans le cadre de cette première approche. Voir : [libs/test_sdl.md](libs/test_sdl.md).

Mais cette approche aurait nécessité une certaine quantité de temps, que je n'ai pas. Il existe une solution plus simple, qui permettrait de profiter directement de mes anciennes créations, sans rien avoir à installer.


## Test de js-dos

Js-dos est une librairie JavaScript, basé sur DosBox, permettant d'exécuter des programmes du système d'exploitation "DOS", dans un navigateur internet.

J'y ai pas cru au début, mais il semblerait que ça marche. Même avec des "vrais" jeux.

Voir : [https://github.com/caiiiycuk/js-dos](https://github.com/caiiiycuk/js-dos).


