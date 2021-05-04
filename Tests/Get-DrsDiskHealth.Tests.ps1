
BeforeAll {
    # Verify Pester Version
    if ((Get-Module Pester).Version -lt [version]'5.0') { throw "Pester 5 or later is required." }

    Write-host "$PSScriptRoot"
    # dot source function
    if ($PSScriptRoot -eq '') {
        Import-Modules ../DRS/DRS.psd1 -Force
    }
    else {
        Import-Module $PSScriptRoot/../DRS/DRS.psd1 -Force
    }
    
    

    # Get Information about Volumes
    $ActualVolumes = Get-CimInstance -ClassName Win32_Volume
    $ActualSingleVolume = $ActualVolumes[0]
    $ActualVolumeCapacityGB = [math]::round(($ActualSingleVolume.Capacity / 1GB), 2) -as [int]
    $ActualVolumeFreeGB = [math]::round(($ActualSingleVolume.FreeSpace / 1GB), 2) -as [int]
    $ActualVolumeFreePct = [math]::round((($ActualSingleVolume.FreeSpace / $ActualSingleVolume.Capacity) * 100), 0) -as [int];
    
}

Describe 'Get-DrsDiskHealth Unit Tests' {
    BeforeAll {
    }
    Context "Unit Tests" {
    }
}

Describe 'Get-DrsDiskHealth Integration Tests' {
    BeforeAll {
        $TestVolumes = Get-DrsDiskHealth
        $TestSingleVolume = $TestVolumes | Where-Object { $_.DeviceId -eq $ActualSingleVolume.DeviceID }
    }
    Context "Get Disk Health Status with no Parameters" {
        It "Outputs All Volumes With Correct Count" {
            $TestVolumes.Count | Should -BeExactly $ActualVolumes.Count
        }
        It "Outputs Correct Capacities" {
            $TestSingleVolume.Capacity | Should -BeExactly $ActualSingleVolume.Capacity
        }
        It "Outputs the correct Free Space %" {
            $TestSingleVolume.FreeSpacePct | Should -BeExactly $ActualVolumeFreePct
        }
        It "Outputs the correct Capacity in GB" {
            $TestSingleVolume.CapacityGB | Should -BeExactly $ActualVolumeCapacityGB
        }
        It "Outputs the correct Free GB" {
            $TestSingleVolume.FreeSpaceGB | Should -BeExactly $ActualVolumeFreeGB
        }
    }
}