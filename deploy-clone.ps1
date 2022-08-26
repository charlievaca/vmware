<#
    .NOTES
    ===========================================================================
     Created by:    Charlie Vaca
     Date:          Ago 26, 2022
     WWW:           help-it.es
    ===========================================================================
    .SYNOPSIS
        Sample script to utilize Instant Clone feature of VMware vSphere
    .DESCRIPTION
        Deploys 5 new Inte Clone VMs from master VM with some basics customization
=    .NOTES
        Make sure that you have both a vSphere 6.7 env (VC/ESXi) as well as
        as the latest PowerCLI 10.1 installed which is reuqired to use vSphere 6.7 APIs
#>

import-module ./new-instantclone.psm1

Connect-VIServer -server vc7-avs.vclass.local -user "administrator@vsphere.local" -password "VMware1!"
$sourceVM="Oracle7-SourceVM"

$StartTime = Get-Date
Write-Host -ForegroundColor Cyan "Starting Instant Clone setup"

foreach ($i in 1..5){

$newVM="OracleInstantClone"+$i
$octet=$i+100

$ip="172.20.10."+$octet

 $guestCustomizationValues = @{
        "guestinfo.ic.hostname" = $newVM
        "guestinfo.ic.ipaddress" = "$ip"
    }

New-InstantClone -SourceVM $SourceVM -DestinationVM $newVM -CustomizationFields $guestCustomizationValues Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -Confirm:$false | Set-NetworkAdapter -Connected:$true -Confirm:$false
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
Write-Host -ForegroundColor Cyan  "`nStartTime: $StartTime"
Write-Host -ForegroundColor Cyan  "  EndTime: $EndTime"
Write-Host -ForegroundColor Green " Duration: $duration minutes"

Disconnect-VIServer -Confirm:$false
