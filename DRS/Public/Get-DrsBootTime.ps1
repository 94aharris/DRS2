# Requires -Version 5.1

function Get-DrsBootTime {
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
    [CmdletBinding(DefaultParameterSetName = 'NoParams')]
    param (
        
        # Parameter for the computers to query against
        [Parameter(Mandatory, ParameterSetName = 'ComputerSpecified', ValueFromPipeline)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        # Parameter for Creds
        [Parameter(ParameterSetName = 'ComputerSpecified')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName = 'ComputerSpecified')]
        [Parameter(ParameterSetName = 'NoParams')]
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

        # Common CIM Query Params for Boot Time
        $cimParams = @{
            ClassName = 'Win32_OperatingSystem'
            Property  = @('lastbootuptime', 'csname')
        }

        # Based on passed Params, query other computer or local
        if ($ComputerName) {
            if ($Credential) {
                Write-Verbose "Getting BootTime from Remote Computer, Credentials Specified"
                $bootTimes = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName -Credential $Credential
            }
            else {
                Write-Verbose "Getting BootTime from Remote Computer, Current User"
                $bootTimes = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName
            }
        }
        else {
            Write-Verbose "Getting BootTime from Local Computer"
            $bootTimes = Get-DrsCimInstance -CimParams $cimParams 
        }
        
        foreach ($boot in $bootTimes) {        

            # Final Construction and return
            [PSCustomObject]@{
                ComputerName = $boot.csname
                LastBootTime = $boot.lastbootuptime
                Status       = "Info"
                RuleResults  = $null
            }
        }
    }
    
    
    end {
        
    }
}