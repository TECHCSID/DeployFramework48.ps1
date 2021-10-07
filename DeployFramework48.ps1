Param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $FrameworkDownloadURL = [string]("https://go.microsoft.com/fwlink/?linkid=2088631"),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $workingDirectory = [string]("C:\temp\")
)

$exeFileName = "framework48-Setup.exe"
$tagertPath = $workingDirectory + $exeFileName
$logPath = "$workingDirectory\FrameWorkInstallLog\"
$logFileName = "DotNET48-Install.html";
$targetLogPath = $logPath + $logFileName

if (-Not(Test-Path -Path $workingDirectory)) {
    Write-Host "Création du répertoire temporaire $workingDirectory"
    New-Item -ItemType "directory" -Path $workingDirectory
}

if (-Not(Test-Path -Path $logPath)) {
    Write-Host "Création du répertoire temporaire $logPath"
    New-Item -ItemType "directory" -Path $logPath
}

Write-Host "Téléchargement du fichier depuis $FrameworkDownloadURL vers $tagertPath"
Invoke-WebRequest -Uri $FrameworkDownloadURL -OutFile $tagertPath

$MSIArguments = @(
    "/q"
    "/norestart"
    "/log"
    $targetLogPath
)

Write-Host "Lancement de l'installation du framework 4.8 en Silent et sans lancer de restart (log : $workingDirectory\log\DotNET48-Install.log)"
$code = (Start-Process $tagertPath -ArgumentList $MSIArguments -PassThru -NoNewWindow -Wait).ExitCode

if ($code -eq 0)
{
    Write-Host "--------------------------------"
    Write-Host "Installation réalisée avec succès"
}
else
{
    Write-Host "--------------------------------"
    Write-Host "Installation non réalisée - un problème à été rencontré"
    $content = (Get-Content $targetLogPath -Raw -Encoding UTF8)    
    $content = $content -replace "<[^>]+>","`n"
    $content = ($content -replace "(?m)^\s*`n","")
    $content = ($content -replace "(?m)^\s*`r","")
    $content = ($content -replace "(?m)^\s*`r`n","")
    $content = $content.ToLower().Trim()
    
    $start = $content.LastIndexOf('installation blockers:')
    if ($start -ne -1)
    {
        $errorLog = $content.substring($start)
        Write-Host "--------------------------------"
        Write-Host $errorLog
    }
    else #other errors
    {
        Write-Host "--------------------------------"
        Write-Host $content
    }
}