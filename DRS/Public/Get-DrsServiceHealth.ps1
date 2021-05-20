# Requires -Version 5.1

function Get-DrsServiceHealth {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName='NoParams')]
    param (
        
        # Parameter for the computers to query against
        [Parameter(Mandatory,ParameterSetName='ComputerSpecified',ValueFromPipeline)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        # Parameter for Creds
        [Parameter(ParameterSetName='ComputerSpecified')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName='ComputerSpecified')]
        [Parameter(ParameterSetName='NoParams')]
        $config
    )
    
    begin {

        # Read Config if Needed
        if ($null -eq $config) {
            Write-Verbose "Config not passed, acquiring"
            $config = Get-DrsConfig
        }
        
    }
    
    process {

        # Common CIM Query Params for Services
        # Not using Get-Service for greater compatability and more information about individual services
        # Only Queries Automatic Services
        $cimParams = @{
            ClassName = 'Win32_Service'
            Filter = 'StartMode = "Auto"'
        }

        # Based on passed Params, query other computer or local
        if ($ComputerName) {
            if ($Credential) {
                Write-Verbose "Getting Services from Remote Computer, Credentials Specified"
                $services = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName -Credential $Credential
            } else {
                Write-Verbose "Getting Services from Remote Computer, Current User"
                $services = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName
            }
        } else {
            Write-Verbose "Getting Services from Local Computer"
            $services = Get-DrsCimInstance -CimParams $cimParams 
        }
        
        foreach ($service in $services) {

            # Skip Intentionally Ignored Services
            if ($service.StartName -in $config.serviceHealth.ignoreStartName) {
                Write-Verbose "Skipping Service $($service.name) due to start name $($service.startname)"
            }
            elseif ($service.Name -in $config.serviceHealth.ignoreServiceName) {
                Write-Verbose "Skipping Service $($service.name)"
            }
            else {
                # Determine Service Health Status
                $serviceStatus = Get-ServiceHealthStatus -Service $service -config $config

                # Final Construction and return
                [PSCustomObject]@{
                    ComputerName = $service.SystemName
                    Name        = $service.Name
                    StartMode = $service.StartMode
                    State = $service.State
                    StartName = $service.StartName
                    Status = $serviceStatus.Severity
                    RuleResults = $serviceStatus.RuleResults
                }
            }
        }
    }
    
    end {
        
    }
}