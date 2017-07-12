function Add-Path() {
    [Cmdletbinding()]
    param([parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)][String[]]$AddedFolder)
    # Get the current search path from the environment keys in the registry.
    $OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    # See if a new folder has been supplied.
    if (!$AddedFolder) {
        Return 'No Folder Supplied. $ENV:PATH Unchanged'
    }
    # See if the new folder exists on the file system.
    if (!(TEST-PATH $AddedFolder))
    { Return 'Folder Does not Exist, Cannot be added to $ENV:PATH' }cd
    # See if the new Folder is already in the path.
    if ($ENV:PATH | Select-String -SimpleMatch $AddedFolder)
    { Return 'Folder already within $ENV:PATH' }
    # Set the New Path
    $NewPath=$OldPath+’;’+$AddedFolder
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath
    # Show our results back to the world
    Return $NewPath
}

######################################################
# Install apps using Chocolatey
######################################################
Write-Host "Installing Chocolatey"
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
Write-Host

Write-Host "Installing applications from Chocolatey"
cinst sublimetext3 -y
cinst git -y
cinst winmerge -y
cinst visualstudio2017enterprise -y
cinst resharper-platform -y
cinst wox -y
cinst everything -y
cinst poshgit -y
cinst docker-for-windows -y
cinst docker-kitematic -y
cinst Evernote -y
cinst postman -y
Write-Host

######################################################
# Set environment variables
######################################################
Write-Host "Setting home variable"
[Environment]::SetEnvironmentVariable("HOME", $HOME, "User")
Write-Host

######################################################
# Download custom .bashrc file
######################################################
Write-Host "Creating .bashrc file for use with Git Bash"
$filePath = $HOME + "\.bashrc"
New-Item $filePath -type file -value ((new-object net.webclient).DownloadString('http://bit.ly/winbashrc'))
Write-Host

######################################################
# Add Git to the path
######################################################
Write-Host "Adding Git\bin to the path"
Add-Path "C:\Program Files (x86)\Git\bin"
Write-Host

######################################################
# Configure Git globals
######################################################
Write-Host "Configuring Git globals"
$userName = Read-Host 'Enter your name for git configuration'
$userEmail = Read-Host 'Enter your email for git configuration'

& 'C:\Program Files (x86)\Git\bin\git' config --global user.email $userEmail
& 'C:\Program Files (x86)\Git\bin\git' config --global user.name $userName

# $gitConfig = $home + "\.gitconfig"
# Add-Content $gitConfig ((new-object net.webclient).DownloadString('http://bit.ly/mygitconfig'))

# $gitexcludes = $home + "\.gitexcludes"
# Add-Content $gitexcludes ((new-object net.webclient).DownloadString('http://bit.ly/gitexcludes'))
Write-Host

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

######################################################
# Generate public/private rsa key pair
######################################################
Write-Host "Generating public/private rsa key pair"
Set-Location $home
$dirssh = "$home\.ssh"
mkdir $dirssh
$filersa = $dirssh + "\id_rsa"
ssh-keygen -t rsa -f $filersa -q -C $userEmail
Write-Host

######################################################
# Download custom PowerShell profile file
######################################################
Write-Host "Creating custom $profile for Powershell"
if (!(test-path $profile)) {
    New-Item -path $profile -type file -force
}
Add-Content $profile ((new-object net.webclient).DownloadString('http://bit.ly/profileps'))
Write-Host

######################################################
# Enable the Windows subsystem for Linux
######################################################
Write-Host "Enabling the Linux subsystem"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
Write-Host

######################################################
# Enable Hyper-V
######################################################
Write-Host "Enabling Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Write-Host
