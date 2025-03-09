# URL of the file to download
$url = "https://www.mediafire.com/file/owgnox66mxdjkkl/bypasse_2_2.7z/file"
$outputFile = "bypasse_2_2.7z"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $outputFile

# Path to 7z executable (ensure 7-Zip is installed and in PATH or specify the full path)
$sevenZip = "7z"

# First extraction
& $sevenZip x $outputFile -o"bypasse_2_2" -y

# Second extraction
& $sevenZip x ".\bypasse_2_2\bypasse_2.7z" -o"bypasse_2" -y

# Third extraction
& $sevenZip x ".\bypasse_2\bypasse.7z" -o"bypasse" -y

Write-Host "Extraction completed successfully."
