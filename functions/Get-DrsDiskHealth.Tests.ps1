
BeforeAll {
    # Verify Pester Version
    if ((Get-Module Pester).Version -lt [version]'5.0') { throw "Pester 5 or later is required." }

    Write-host "$PSScriptRoot"
    # dot source function
    if ($PSScriptRoot -eq '') {
        . ./Get-DrsDiskHealth.ps1
    } else {
        . $PSScriptRoot/Get-DrsDiskHealth.ps1
    }

    # Get Information about Volumes
    $ActualVolumes = Get-CimInstance -ClassName Win32_Volume
    $ActualSingleVolume = $ActualVolumes[0]
    
}
Describe 'Get-DrsDiskHealth' {
    BeforeAll {
        $TestVolumes = Get-DrsDiskHealth
        $TestSingleVolume = $TestVolumes | Where-Object {$_.DeviceId -eq $ActualSingleVolume.DeviceID}
    }
    Context "Get Disk Health Status with no Parameters" {
        It "Outputs All Volumes With Correct Count" {
            $TestVolumes.Count | Should -BeExactly $ActualVolumes.Count
        }
        It "Outputs Correct Capacities" {
            $TestSingleVolume.Capacity | Should -BeExactly $ActualSingleVolume.Capacity
        }
    }
}