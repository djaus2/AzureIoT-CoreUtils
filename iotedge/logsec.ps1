Get-WinEvent -ea SilentlyContinue -FilterHashtable @{ProviderName='iotedged';LogName='application';StartTime=[datetime]::Now.AddSeconds(-30)} |
    Select TimeCreated, Message |
    Sort-Object @{Expression='TimeCreated';Descending=$false} |
    Format-Table -AutoSize -Wrap