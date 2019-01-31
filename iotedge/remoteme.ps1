
Write-Host Ref: https://docs.microsoft.com/en-us/windows/iot-core/connect-your-device/powershell
$machine =  '192.168.0.38'
Write-Host The next command shouldnt be needed
Write-Host net start WinRM
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $machine
Enter-PSSession -ComputerName $machine -Credential $machine\Administrator
Write-Host To edit remote file: cd to directory  then psedit filename
Write-Host To exit remote session: Exit-PSSession 