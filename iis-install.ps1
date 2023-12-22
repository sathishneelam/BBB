# Force use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
# Firewall
netsh advfirewall firewall add rule name="http" dir=in action=allow protocol=TCP localport=80
 
# Folders
New-Item -ItemType Directory c:\temp
New-Item -ItemType Directory c:\mpdownload
 
# Install IIS with HTTP Activation
Install-WindowsFeature -Name Web-Server, Web-Http-Activation -IncludeManagementTools
 
# Restart IIS to apply changes
Restart-Service W3SVC 
 
# Install dot.net core sdk
Invoke-WebRequest http://go.microsoft.com/fwlink/?LinkID=615460 -outfile c:\temp\vc_redistx64.exe
Start-Process c:\temp\vc_redistx64.exe -ArgumentList '/quiet' -Wait
Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkID=809122 -outfile c:\temp\DotNetCore.1.0.0-SDK.Preview2-x64.exe
Start-Process c:\temp\DotNetCore.1.0.0-SDK.Preview2-x64.exe -ArgumentList '/quiet' -Wait
Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkId=817246 -outfile c:\temp\DotNetCore.WindowsHosting.exe
Start-Process c:\temp\DotNetCore.WindowsHosting.exe -ArgumentList '/quiet' -Wait

 
# Configure iis
Set-ItemProperty IIS:\AppPools\DefaultAppPool\ managedRuntimeVersion ""
New-Website -Name "mpdownload" -Port 80 -PhysicalPath C:\mpdownload\ -ApplicationPool DefaultAppPool
& iisreset
