          ZARMABLAST!!!!!!

  The Never Finished Version...

Oh c'est beau! Oh c'est super! Oh c'est quoi?
C'est le nouveau jeu made by R/eche\r Grzmktbq
Un Bomberman ou on peut configurer un tas de trucs

(mais l� le jeu est pas fini, il y a pas encore les bonus,
ni un tas d'autres trucs � rajouter)

Ca s'appelle The Never Finished Version parce qu'avec le jeu,
je distribue aussi les codes sources et que n'importe qui
a le droit de les modifier comme il veut, � condition
que, apr�s les modifications, le jeu soit toujours distribu�
gratuitement comme je l'ai fait avec les codes sources
(et indiquez dans un fichier TXT que vous donnerez avec le jeu
les modification faites, c'est mieux )
Voil�, c'est pour me la jouer mec super-pro qui a l'esprit Linux
que je donne les codes sources, parce que sans vouloir
vous d�courager, c'est peut �tre un peu le bazar.
L'ensemble a �t� cod� en Pascal 7.0, avec des morceaux
d'assembleur (en incluant les nouvelles instructions
du 286.)



Touche du joueur 1
Z,Q,S,D : direction
&       : Poser les bombes

Joueur 2
8,4,5,6 : Direction
Page Down : Poser les bombes

Joueur 3
O,K,L,M : Direction
6 (ou 7) je sais plus : Poser les bombes

Joueur 4
Haut,Bas,Gauche,Droite : Direction
BackSpace : Poser les bombes

Voil�, les touches ont �t� choisie le mieux possible, si �a vous
plait pas, change le code source et recompilez le programme

LES FICHIERS DE CONFIGURATION

indiquer le nom du fichier .ini en param�tre, au
moment d'ex�cuter le jeu, pour choisir
quel configuration vous voulez.

Le jeu est donn� au d�part avec 4 fichiers .ini :
normal.ini, zarma.ini, WhoIsWho.ini, Claustro.ini
(ce sont des fichiers textes, regardez les pour voir
comment c'est fait)

Par exemple, si vous voulez jouer avec la configuration
qui est dans le fichier zarma.ini, vous �crivez
sur la ligne de commande du DOS :
bombman zarma.ini
Par contre, sur Windows, on peut pas lancer une application en mettant
des param�tres, mais vous avez qu'� vous d�merder tout seul.
De toute fa�ons Windows c'est de la merde,
Mettez vous en mode Dos, ou faites des .BAT

Vous pouvez aussi faire vos propres fichiers de configuration,
consulter alors le fichier vide.ini pour savoir quoi comment
faire.

Les r�gles g�n�rales pour les fichiers de configuration sont les suivantes

 - un point-virgule en d�but de ligne indique que c'est un commentaire
 et que le jeu ne prendra pas en compte cette ligne
 - les choses � configurer sont s�par�es en sections,
 chaque section poss�de un nom, et il faut �crire son nom
 entre crochets pour configurer les choses figurant
 dans cette section
 - les majuscules-minuscules ne sont pas importantes
 - on ne met qu'une information par ligne dans le fichier texte.
 - on n'est pas oblig� de jouer avec une configuration sp�ciale,
 si on ne met aucun fichier en param�tre,
 �a joue avec la configuration par d�faut
 - si une ligne dans le fichier est incoh�rente, elle est consid�r�
 comme inexistante, mais le reste du fichier est interpr�t� quand m�me
 - les lignes incoh�rentes sont indiqu�es au moment o� on ex�cute le jeu


Voil�, normalement, le jeu comporte les fichiers suivants :

executable : bombman.exe
codes sources (extension .PAS ) : mcgagraf, zetime, keyboard, dosfile
bombimg, bombfile, bombconf, bombman
donn�es : bombman.spr, bombman.pal, mcgachar
fichiers de configuration (extension .INI) : WhoisWho, zarma,
normal, claustro







