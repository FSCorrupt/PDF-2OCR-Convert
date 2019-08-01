#Path to Ghostscript/Tesseract
$Ghostscripttool = '.\gswin64c.exe'
$Tesseractdata = '.\Tesseract\tessdata'
$Tesseractexe = '.\Tesseract\tesseract.exe'

#Directory containing the PDF files that will be converted
$inputDir = '.\Source'

#Output path where convertedPDF files will be stored
$outputDirPDF = '.\Converted'

#Output path where original file from Source folder will be stored
$CompletedPDF = '.\Completed'

#Output path where the Temp TIF files will be saved
$outputDir = '.\tif_temp\'

$ErrorActionPreference = 'SilentlyContinue'

$Directory = Get-ChildItem -Name $inputDir

while ($Directory -ne 'NoEnd')
{
	If ($Directory) 
	{
		$pdfs = Get-ChildItem $inputDir -Recurse | Where-Object -FilterScript {
			$_.Extension -match 'pdf'
		}

		foreach($pdf in $pdfs)
		{
			$tif = $outputDir + $pdf.BaseName + '.tif'
			if(Test-Path $tif)
			{
				'tif file already exists ' + $tif
			}
			else        
			{   
				'Processing ' + $pdf.Name        
				$param = "-sOutputFile=$tif"
				& $Ghostscripttool -q -dNOPAUSE -sDEVICE=tiffgray $param -r300 $pdf.FullName -c quit #Greyscale 8bit and 300dpi
			}
			Move-Item "$inputDir\$($pdf.Name)" $CompletedPDF
		}

		$tifs = Get-ChildItem $outputDir -Recurse | Where-Object -FilterScript {
			$_.Extension -match 'tif'
		}
		foreach ($tif in $tifs)
		{
			$Tifdata = $tif.Fullname
			$Pdfdata = $outputDirPDF+'\'+$tif.basename
			$result = & $Tesseractexe --tessdata-dir $Tesseractdata $Tifdata $Pdfdata -l deu pdf #"DEU" is the Language Code for German.
			Remove-Item -Path $Tifdata -Force -Confirm:$false
		}
		$Directory = Get-ChildItem -Name $inputDir
	}
	if (!$Directory)
	{
		Start-Sleep -Seconds 15
		$Directory = Get-ChildItem -Name $inputDir
	}
}
