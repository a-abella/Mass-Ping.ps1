<#
    Antonio Abella  -  Nov. 30, 2016
    
    network status.

    Graphical OU selection provided by MicaH's
    Choose-ADOrganizationalUnit function.
    https://itmicah.wordpress.com/2016/03/29/active-directory-ou-picker-revisited/
#>

# Dot-source file containing Choose-ADOrganizationalUnit
# function.
. .\path\to\ChooseADOrganizationalUnit.ps1

function StringIsNullOrWhitespace([string] $string) {
    if ($string -ne $null) { 
        $string = $string.Trim() 
    }
    return [string]::IsNullOrEmpty($string)
}

Write-Host "`n`n=============================="
Write-Host "Mass Ping - Network Status Query"
Write-Host "================================`n"

$oubool = 0
$pcs = ""
$ou = ""
$hostArray = @()

# Read target hosts from input files if provided.
if ($args.Length) {

    foreach ($arg in $args) {
        Get-Content $arg | foreach-object { $hostArray += $_ }
    }
    Write-Host "`n`nUsing hosts from file(s) " -NoNewLine
    foreach ($arg in $args) {
        Write-Host "$arg " -NoNewLine
    }
    $hostArray | Format-Wide {$_} -Column 6 -Force
    start-sleep -m 1250
} else {

    # Query for OU selection.
    $ouselect = Read-Host -Prompt "`nDo you want to ping all PCs in a given OU? [y/N]"
    if (([string]::Compare($ouselect, 'y', $True) -eq 0) -or ([string]::Compare($ouselect, 'yes', $True) -eq 0)){
        $ou = Choose-ADOrganizationalUnit
        $oubool = 1
        $pcs = $(Get-ADComputer -Filter * -SearchBase $ou.distinguishedName)
        $pcs = $pcs.name -split ' '
    }

    # Manual host entry if OU selection is denied.
    if ($oubool -eq 0) {
        Write-Host "`nEnter valid hostnames one line a time. A list may be pasted in."
        Write-Host "Case insensitive. When finished, enter a blank line.`n"
        while ($entry -ne "") { 
            $entry = Read-Host -Prompt 'Enter hostname'
            
            if ($entry -ne "") { 
                $hostArray += $entry 
            }
        }
    } else {
        $hostArray = $pcs
        Write-Host "Using hosts from OU"$ou.name":"
        $hostArray | Format-Wide {$_} -Column 6 -Force
    }
}

Write-Host ""
[array]::sort($hostArray)

# Append the rest of your FQDN for faster name resolution 
# and better performance
$hostArray = $hostArray | % {$_ + ".fqdn.com"}

$numberup = 0
$resolves = 0

# Ping host lists and parse ouput for status.
# Status:
#           UP: host replies to ICMP echo request
#           DOWN: host does not reply to ICMP echo request
#           NoDNS: ping cannot resolve the hostname.
$hostArray | % {
    $pingcap = ping.exe $_ -n 1 -w 400
    $pingup = echo $pingcap | Select-String "reply","try again"
    if (StringIsNullOrWhitespace($pingup)) {
        $resolves++
        Write-Host "-"$_.split('.')[0]"=> " -NoNewLine
        Write-Host "DOWN" -Backgroundcolor red -Foregroundcolor white
    } elseif ($(echo $pingup | select-string "try again").Length) {
        Write-Host "-"$_.split('.')[0]"=> " -NoNewLine
        Write-Host "NoDNS" -Foregroundcolor darkgray
    } else {
        $resolves++
        Write-Host "+"$_.split('.')[0]"=> " -NoNewLine
        Write-Host "UP" -Backgroundcolor green -Foregroundcolor black
        $numberup++
    }
}

# Display statistics.
$uppctotal = ($numberup/$hostArray.length)*100
$uppcres = ($numberup/$resolves)*100
$uppctotalrnd = [math]::Round($uppctotal,1)
$uppcresrnd = [math]::Round($uppcres,1)

Write-Host "`nHosts up (total):"$numberup"/"$($hostArray.length)"  "$uppctotalrnd"%"
Write-Host "Hosts up (reslv):"$numberup"/"$resolves"  "$uppcresrnd"%`n`n"
