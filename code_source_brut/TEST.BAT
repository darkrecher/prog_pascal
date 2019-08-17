
disktest C
if Errorlevel 1 Goto NON
if Errorlevel 0 Goto OUI


:NON
Le lecteur C n'existe pas
Goto Next

:OUI
Le lecteur C existe
Goto Next

:Next

disktest dffgh
if Errorlevel 1 Goto NON2
if Errorlevel 0 Goto OUI2


:NON2
Le lecteur E n'existe pas
Goto Next2

:OUI2
Le lecteur E existe
Goto Next2

:Next2
