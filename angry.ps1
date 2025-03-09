$url = "https://store4.gofile.io/download/web/cd7eadbe-5e62-4ec1-9945-b3be8c613eb1/bypasse_2_2.7z"
$output = "bypasse_2_2.7z"

Invoke-WebRequest -Uri $url -OutFile $output

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

& "$sevenZipPath" x $output -aoa

& "$sevenZipPath" x "bypasse_2.7z" -aoa

& "$sevenZipPath" x "bypasse.7z" -aoa
