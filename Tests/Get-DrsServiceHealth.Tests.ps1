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

}

Describe 'Get-DrsServiceHealth Unit Tests' {
    BeforeAll {

    }
    Context "Unit Tests" {

    }
}

Describe 'Get-DrsServiceHealth Integration Tests' {
    BeforeAll {
        $TestServices = Get-DrsServiceHealth
        $SingleTestService = $TestServices[0]
        $SingleActualService = Get-Service $SingleTestService.name
    }
    Context "Get Service Health with no Parameters" {
        It "Should Report the Correct Service Statuses" {
            $SingleTestService.state | Should -BeExactly $SingleActualService.Status
        }
    }
}