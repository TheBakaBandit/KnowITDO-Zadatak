# KnowITDO-Zadatak
This repository is for the purposes of applying to KnowIT doo for the position of DevOps

Ova skripta krerira kompletan dnevni izvod (KDI) koji predstavlja ZIP arhivu koja sadrži otpakovane sve dnevne izvode za konkretni datum. KDI sadrži sve sopstvene partije organizacije kao i "tuđe partije" u koje ta organizacija ima uvid, a imali su aktivnost tog dana.

# Preduslovi
  1. Skripta je u Powershell-u i potrebno je da je PowerShell 5.1 ili vise instaliran na masini koja je izvrsava
  2. Skripta pretpostavlja da se izvrsava na Linux sistemu sa instaliranim cli Zip alatom u PATH varijabli kao i Unzip i Zipinfo funkcijama tog alata
  3. Skripta pretpostavlja da ima puna prava u folderu gde se izvrsava
  
# Folder izvrsavanja
  Moguce je promeniti lokaciju foldera `/izvodi` gde se skripta izvrsava koristeći parametar `-Path` prilikom aktivacije skripte

# Logovanje:
  Skripta automatski loguje sve sto uradi, i upisuje u log file koji se zove `KDIlog.txt` moguće je namestiti lokaciju log fajla oristeći parametar `-Log` prilikom aktivacije skripte
  
# Aktivacija:
  Kako bi se scripta izvrsavala redovno putem Cron job-a potrebno je da Cron izvrsi komandu sa sledecim parametrima:
  > `* * * * * pwsh /put/do/skripte/KnowITDO.ps1 -Path put/do/izvodi -Log put/do/loga`

# Opis rada
  Skripta prolazi kroz sve organizacije po folderima i izvlaci listu partija kojima ta organizacija ima pristup preko fajla koji je u formatu `<mb>_partije.json`, onda prolazi kroz sve datume organizacijama kojima originalana organizacija ima pristup(uključujući i originalnu organizaciju) i ukoliko originalna organizacija ima pristup partiji koja ima promenu u tom datumu dodaje pod originalnom organizacijom u tom datumu(kojeg kreira ukoliko prethodno ne postoji) sve izvode od tog datuma te partije u arhivu formata `<mb>_sve-partije.zip`.
  Ukoliko već postoji KDI tog formata, proverava da li ima sve partije koje je našla već u arhivi i dodaje ih ukoliko ih nije bilo. Ukoliko arhiva postoji i ima sve partije upoređuje CRC32 vrednost između ta dva fajla kako bi proverila da nije došlo do korupcije.
 
