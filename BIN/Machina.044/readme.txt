Deus ex Machina 0.44
====================

(1996-01)

Verze pro nativni prohlizeni projektu verze 0.xx (Pareniste 5-27)
se vsemi tehdejsimi featurami.
Nouzove prohlizeni umoznuji i novejsi verze, ale ne zcela presne 
a s pady na nekterych strankach.

Editor+list+spoj.exe are for creating new diskmags.

K behu vyzaduje
 - DOS (ne Windows)
 - EMS pamet

DOS s EMS pameti lze ziskat nejsnaze nabootovanim z CD.

(Denicku, protoze Masina nekamaradila s rychlejsimi procesory,
 zmenil jsem v diskmag.exe na offsetu ae90 $00 na $20. Ted by mela
 kamaradit aspon do 30GHz. Doufam ze jsem tim nepokazil neco jineho.
 Jinak cim vyssi cislo tam je, tim rychlejsi procesor snese.
 A protoze PS/2 mysi vysilaji stejne signaly jako klavesa ESC,
 zmenil jsem na offsetu 7bae $01 na $29,
 takze Masina nereaguje na ESC, ale na ` - tu klavesu hned pod nim.
 Aby pri zdetekovani PS/2 nevypnul klavesnici, nastavil jsem v INI PS2=ne.)

Pro prohlizeni Parenist 5-15 spust v DOSu run05_15.bat.
Pro prohlizeni Parenist 16-27 spust v DOSu run16_27.bat.
