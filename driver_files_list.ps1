# 1. Identify the GPU
$GPUNAME = "AMD Radeon RX 6800 XT" #CHANGE FOR THE NAME OF YOUR GPU
$OUTPUTPATH = "C:\Users\iulli\Downloads\hyperv\Output" #THE PATH FOR EXPORT THE FILES
$Gpu = Get-PnpDevice -Class Display | Where-Object FriendlyName -like "$GPUNAME"

if (-not $Gpu) {
    Write-Error "Could not find driver information for the specified GPU."
    return
}

# 2. Get General Driver Info (Provider, Version, Signer)
Write-Host "--- Driver Metadata ---" -ForegroundColor Cyan
$DriverInfo = Get-CimInstance Win32_PnPSignedDriver | Where-Object DeviceID -eq $Gpu.InstanceId
$DriverName = $DriverInfo.InfName
Write-Host "DeviceName: "$DriverInfo.DeviceName
Write-Host "Driver Name: "$DriverName
Write-Host "DriverProviderName: "$DriverInfo.DriverProviderName
Write-Host "DriverVersion: "$DriverInfo.DriverVersion

# 3. Define the path to your INF file
$InfPath = "C:\Windows\INF\$DriverName"
$HwId = $DriverInfo.DeviceID
$HwId = ($HwId -split "&")[1]

# 4. Find the Install Section name for this GPU
$Content = Get-Content $InfPath
$InstallSectionLine = $Content | Select-String -Pattern $HwId | Select-Object -First 1
$InstallSection = ($InstallSectionLine -split "=")[1].Split(",")[0].Trim()

Write-Host "Searching INF for Install Section: [$InstallSection]" -ForegroundColor Cyan

# 5. Find the 'CopyFiles' lists within that section
$CopyFileSections = @()
$InTargetSection = $false

foreach ($line in $Content) {
    if ($line -match "\[$InstallSection(\.ntamd64)?\]") { $InTargetSection = $true; continue }
    if ($InTargetSection -and $line -match "^\[") { $InTargetSection = $false }
    
    if ($InTargetSection -and $line -match "CopyFiles\s*=\s*(.*)") {
        $CopyFileSections += $matches[1].Split(",").Trim()
    }
}

# 6. Extract filenames from each identified CopyFiles section
$DriverFiles = New-Object System.Collections.Generic.HashSet[string]

foreach ($Sect in $CopyFileSections) {
    # Handle direct file copies (prefixed with @)
    if ($Sect.StartsWith("@")) {
        $null = $DriverFiles.Add($Sect.Substring(1))
        continue
    }

    # Otherwise, find the section and grab the filenames
    $InCopySection = $false
    foreach ($line in $Content) {
        if ($line -match "^\[$([regex]::Escape($Sect))\]") { $InCopySection = $true; continue }
        if ($InCopySection -and $line -match "^\[") { $InCopySection = $false }
        
        if ($InCopySection -and $line.Trim() -and $line -notmatch "^;") {
            # Filenames are the first part of the comma-separated line
            $FileName = $line.Split(",")[0].Trim()
            if ($FileName) { $null = $DriverFiles.Add($FileName) }
        }
    }
}

# 7. Build a lookup table (Hashtable) of all files in those directories
$DriverStoreLocation = Get-WindowsDriver -Online | Where-Object { $_.Driver -eq "$DriverName" } | Select-Object -ExpandProperty OriginalFileName
$DriverStoreLocation = Split-Path -Path $DriverStoreLocation -Parent
$searchPaths = @("C:\Windows\System32", "C:\Windows\SysWOW64", "$DriverStoreLocation") #falta colocar a pasta da driverstore

$fileLookup = @{}

Get-ChildItem -Path $searchPaths -Recurse -Depth 2 -File -ErrorAction SilentlyContinue | ForEach-Object {
    if (-not $fileLookup.ContainsKey($_.Name)) {
        $fileLookup[$_.Name] = New-Object System.Collections.Generic.List[string]
    }
    $fileLookup[$_.Name].Add($_.FullName)
}

# 8. Create the new collection with full paths
$results = foreach ($name in $DriverFiles) {
    [PSCustomObject]@{
        FileName  = $name
        FoundAt   = if ($fileLookup.ContainsKey($name)) { $fileLookup[$name] } else { "NOT_FOUND" }
        MatchCount = if ($fileLookup.ContainsKey($name)) { $fileLookup[$name].Count } else { 0 }
    }
}

# 9. Output the list of the mission files, or if uncomment, the list of the driver files
Write-Host "`n--- List of Not Found Driver Files ---" -ForegroundColor Red
#$DriverFiles | Sort-Object #just the list
#$results | Format-Table -AutoSize #the list with path
$results | Where-Object MatchCount -eq 0

# 10. Copy files to output folder
Write-Host "`n--- Copying Files to Export Folder ---" -ForegroundColor Cyan
$null = New-Item -Path "$OUTPUTPATH" -ItemType Directory -Force
$null = New-Item -Path "$OUTPUTPATH\System32" -ItemType Directory -Force
$null = New-Item -Path "$OUTPUTPATH\SysWOW64" -ItemType Directory -Force
$hashfolder = ($DriverStoreLocation -split "\\")[5]
$null = New-Item -Path "$OUTPUTPATH\$hashfolder" -ItemType Directory -Force
foreach ($item in $results){
    if ($item.MatchCount -ne 0){
        foreach ($subd in $item.FoundAt){
            $splited = $subd -split "\\"
            if (($splited[4] -ne "FileRepository")){
               $dest = $OUTPUTPATH + "\" + $splited[2]
                $i = 3;
                while (($dest -split "\\")[-1] -ne $splited[-2]){ 
                    $dest = $dest + "\" + $splited[$i]
                    $i = $i + 1
                    $null = New-Item -Path $dest -ItemType Directory -Force
                }
                Copy-Item -Path "$subd" -Destination $dest -Force
            }
        }
    }
}
Copy-Item -Path $DriverStoreLocation -Destination $OUTPUTPATH -Recurse -Force
