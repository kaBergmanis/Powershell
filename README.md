# Powershell
Gadu gaitā sarakstītie skripti, bez kopīgas tēmas

#================
# Bilžu kārtotājs
#================
Kā ievaddatus pieņem bilžu mapi, paņem katras apakšmapes pirmo attēla failu, un nolasa tā uzņemšanas datumu.
Pēc tam pārsauc mapi formātā "YYYY-MM-DD Vecais nosaukums".
Lielāku arhīvu kārtošanai nav pārskatāmāka formāta par gads-mēnesis-diena.
Mīnusi - nestrādās pārāk labi, ja vecajos nosaukumos jau bija iekļauts datums kādā formātā.
Radies tad, kad es gribēju no drauga arhīva pārkopēt kopīgo pasākumu bildes, kas bija pazudušas ar HDD bojāeju,
bet drauga arhīvs bija, izsakoties pieklājīgi, sub-optimālā kārtībā. GUI vēlāk pievienoju tikai tāpēc,
ka tobrīd tas bija mans jaunākais atklājums.

#===============
# Subnet Snooper
#===============
Ļoti uzskatāmi konkrētais situācijai un konkrētai firmai rakstīts skripts.
Pieņem kā ievaddatus IP adreses trešo oktetu, un pārbauda vērtības 10.10.nn.0/24 subnetā. Atgriež csv failu ar
iekārtas nosaukumu, ielogoto lietotāju, un iekārtas tipu (uzņēmuma specifika).
