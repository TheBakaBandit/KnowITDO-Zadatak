Function DodajKDI
#ova funkcija vrsi prebacivanje izvoda u KDI
{
 param (
    $Partija,
    $Datum,
    $mb,
    $mbp
    )

 
 
	  
 
 New-Item  -Path "./$mb/$Datum" -Name "temp" -ItemType "directory"
 unzip  ./$mbp/$Datum/$Partija".json.zip" -d ./$mb/$Datum/temp/
 unzip  ./$mbp/$Datum/$Partija".txt.zip" -d ./$mb/$Datum/temp/
 unzip ./$mbp/$Datum/$Partija".pdf.zip" -d ./$mb/$Datum/temp/
 zip  -g -j ./$mb/$Datum/$mb"_sve-partije.zip" ./$mb/$Datum/temp/*
 Remove-Item ./$mb/$Datum/temp -Recurse

}
 #Ovde moze da se promeni po potrebi lokacija foldera izvodi
 cd /izvodi
 #ovde moze da se promeni lokacija log fajla
 Start-Transcript -Append ./KDIlog.txt
 
 $organizacije = Get-ChildItem -Path ./ -Directory -Name
 #prolazimo kroz sve organizacije
 foreach($mb in $organizacije) 
 {
  $partije = Get-Content -raw -Path ./$mb/$mb"_partije.json" | ConvertFrom-Json
   #prolazimo kroz sve organizacije cijim partijama originalna organizacija ima pristup
   foreach( $mbp in ($partije | Get-Member -MemberType NoteProperty).Name)
   {
    $datumip = Get-ChildItem -Path ./$mbp/ -Directory -Name
    $datumio = Get-ChildItem -Path ./$mb/ -Directory -Name
    #prolazimo kroz sve datume kada su bile promene u organizacijama cijim partijama originalna organizacija ima pristup
    foreach( $dat in $datumip) 
    {
        
        $pud = (dir -Path ./$mbp/$dat/ -Name ) -Replace ([regex]::Escape('.txt.zip'))
              
        $mbpud = (Compare-Object -IncludeEqual -ExcludeDifferent $partije.$mbp $pud).InputObject 
        foreach ($Partija in $mbpud)
        {
            #Prvo se vrsi provera da li KDI vec postoji, i ako postoji da li su svi izvodi prisutni
	    if (Test-Path -Path ./$mb/$dat/$mb"_sve-partije.zip" -PathType Leaf)
	    {
	    	$provera = zipinfo -1 ./$mb/$dat/$mb"_sve-partije.zip"

 	    	if (-not $provera.Contains($Partija+'.txt') ) 
 	    	{
            	DodajKDI -Partija $Partija -Datum $dat -mb $mb -mbp $mbp
            
            	}	
            	elseif (-not $provera.Contains($Partija+'.pdf') ) 
 	    	{
            	DodajKDI -Partija $Partija -Datum $dat -mb $mb -mbp $mbp
            
            	}
            	elseif (-not $provera.Contains($Partija+'.json') ) 
 	    	{
            	DodajKDI -Partija $Partija -Datum $dat -mb $mb -mbp $mbp
                }
            	else
            	{
            	#Ovde radimo proveru da li je CRC fajlova isti, za slucaj da je nekom greskom izvod korumpiran prilikom arhiviranja
            	$CRCtxt = zipinfo -v ./$mb/$dat/$mb"_sve-partije.zip" $Partija".txt"
            	$CRCpdf = zipinfo -v ./$mb/$dat/$mb"_sve-partije.zip" $Partija".pdf"
            	$CRCjson = zipinfo -v ./$mb/$dat/$mb"_sve-partije.zip" $Partija".json"
            	$mbpCRCtxt = zipinfo -v ./$mbp/$dat/$Partija".txt.zip" $Partija".txt"
            	$mbpCRCpdf = zipinfo -v ./$mbp/$dat/$Partija".pdf.zip" $Partija".pdf"
            	$mbpCRCjson = zipinfo -v ./$mbp/$dat/$Partija".json.zip" $Partija".json"
            	if (($CRCtxt[35] -ne $mbpCRCtxt[35]) -or ($CRCpdf[35] -ne $mbpCRCpdf[35]) -or ($CRCjson[35] -ne $mbpCRCjson[35]) )
            	{
            	DodajKDI -Partija $Partija -Datum $dat -mb $mb -mbp $mbp
            	}
            	
            	
            }
        }
        else { DodajKDI -Partija $Partija -Datum $dat -mb $mb -mbp $mbp}
        
        }
            

   }

 
 }
 $datumio = Get-ChildItem -Path ./$mb/ -Directory -Name
 $OK = "Za organizaciju sa MB: "+$mb+" KDI ok za datume: "+$datumio
 $OK 
 }
 Stop-Transcript 
 Exit
