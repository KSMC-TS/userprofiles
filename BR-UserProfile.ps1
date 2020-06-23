param(
$destination = (Read-Host "Enter backup share '\\server\share'") ,
[Parameter(Mandatory=$true)]
[ValidateSet('Backup','Restore')]
[String[]]
$Mode
)


# Identify Variables 
$username = Get-Content env:username
$userprofile = Get-Content env:userprofile
$appData = Get-Content env:localAPPDATA
$backupdir = "$destination\$username"
$folders = "Desktop",
"Downloads",
"Favorites",
"Documents",
"Music",
"Pictures",
"Videos",
"AppData\Roaming\Microsoft\Signatures",
"AppData\Local\Mozilla",
"AppData\Local\Google",
"AppData\Roaming\Mozilla"

 

###### Backup Data section ########
if($Mode -eq "Backup") { 		
	Write-Host -ForegroundColor green "Outlook is about to close, save any unsaved emails then press any key to continue ..."
    if (!(Test-Path $backupdir)) { New-Item $backupdir -Type Directory}
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Get-Process | Where-Object { $_.Name -Eq "OUTLOOK" } | Stop-Process
	Write-Host -ForegroundColor green "Backing up data from local machine for $username"
	foreach ($folder in $folders) {	
		$currentLocalFolder = "$userprofile\$folder"
        $currentRemoteFolder = "$backupdir\$folder"
        if (Test-Path $currentLocalFolder) {
            Write-Host "Backing up $CurrentLocalFolder"
		    $currentFolderSize = (Get-ChildItem -ErrorAction silentlyContinue $currentLocalFolder -Recurse -Force | Measure-Object -ErrorAction silentlyContinue -Property Length -Sum ).Sum / 1MB
		    $currentFolderSizeRounded = [System.Math]::Round($currentFolderSize)
		    Write-Host -ForegroundColor cyan "  $folder... ($currentFolderSizeRounded MB)"
            Copy-Item -ErrorAction silentlyContinue -recurse $currentLocalFolder $backupdir
        }
	}
	
	if (Test-Path "$appdata\Microsoft\Outlook") {
        $oldStylePST = [IO.Directory]::GetFiles($appData + "\Microsoft\Outlook", "*.pst") 
	    foreach($pst in $oldStylePST) { 
		    if ((Test-Path -path ("$backupdir\Documents\Outlook Files\oldstyle")) -eq 0){ New-Item -type directory -path ("$backupdir\Documents\Outlook Files\oldstyle") | Out-Null }
		    Write-Host -ForegroundColor yellow "  $pst..."
		    Copy-Item $pst ("$backupdir\Documents\Outlook Files\oldstyle")
	    }  
    }  
	Write-Host -ForegroundColor green "Backup complete!"
} 

###### Restore data section ######
if($Mode -eq "Restore") { 
    Write-Host -ForegroundColor green "Restoring data to local machine for $username"
	foreach ($folder in $folders) {	
		$currentLocalFolder = "$userprofile\$folder"
        $currentRemoteFolder = "$backupdir\$folder"
        if ($folder -eq "AppData\Local\Mozilla") { Rename-Item -ErrorAction SilentlyContinue $currentLocalFolder "$currentLocalFolder.old" }
		if ($folder -eq "AppData\Roaming\Mozilla") { Rename-Item -ErrorAction SilentlyContinue $currentLocalFolder "$currentLocalFolder.old" }
		if ($folder -eq "AppData\Local\Google") { Rename-Item -ErrorAction SilentlyContinue $currentLocalFolder "$currentLocalFolder.old" }
		Write-Host -ForegroundColor cyan "  $folder..."
		Copy-Item -ErrorAction silentlyContinue -recurse $currentRemoteFolder $userprofile
		}
	Write-Host -ForegroundColor green "Restore Complete!"
}


