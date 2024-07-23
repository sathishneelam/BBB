$containerName = "artifacts"
$blobName = "BuildPackage.zip"
$storageAccountName = "sathishstoragecli"
$outputFolder = "C:\temp\BuildPackage.zip"

# Force use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Firewall
netsh advfirewall firewall add rule name="http" dir=in action=allow protocol=TCP localport=80
# Folders
 
New-Item -ItemType Directory c:\mpdownload

# Install Az Module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az -Force -Scope CurrentUser
Install-Module Az.Storage,Az.KeyVault -Force

#Getting Artifacts
Clear-AzContext -force
Connect-AzAccount -identity
$ctx = New-AZStorageContext  -StorageAccountName $storageAccountName
Get-AzStorageBlobContent -Blob $blobName -Container $containerName -Destination $outputFolder  -Context $ctx -Force

Expand-Archive "$outputFolder" -DestinationPath "C:\Temp" -Force
Copy-Item -Path "C:\Temp\BuildPackage\*" -Destination "C:\mpdownload" -Recurse -Force

# Install iis
Install-WindowsFeature -Name Web-Server,NET-WCF-HTTP-Activation45 -IncludeManagementTools
 
# Configure iis
#Set-ItemProperty IIS:\AppPools\DefaultAppPool\ managedRuntimeVersion ""
Import-Module WebAdministration
New-Item 'IIS:\Sites\Default Web Site\mpdownload' -type Application -physicalPath c:\mpdownload
$desiredThumbprint=(Get-AzKeyVaultCertificate -VaultName "sathish-vault" -Name "ocs-cert").Thumbprint
New-IISSiteBinding -Name "Default Web Site" -BindingInformation "*:443:" -CertificateThumbPrint `$desiredThumbprint -CertStoreLocation My -Protocol https
 
Restart-Service W3SVC
