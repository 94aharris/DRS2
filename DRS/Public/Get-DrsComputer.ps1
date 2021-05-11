function Get-DrsComputer {
    <#
    .SYNOPSIS
        Get Computers to test based config
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
    [CmdletBinding(DefaultParameterSetName="Config")]
    param (
        [Parameter(ParameterSetName="Config")]
        $Config,

        [Parameter(ParameterSetName="Config")]
        [PSCredential]$Credential
    )
    
    begin {
        
    }
    
    process {
        if ($null -eq $Config) {
            Write-Verbose "Config not passed, acquiring"
            $Config = Get-DrsConfig
        }
        
        # Directly Entered Computers
        $directComputer = $Config.environment.computer
        Write-Verbose "# of Directly Entered Computers in Config: $($directComputer.length)"

        $directComputerHeartbeats = foreach ($computer in $directComputer) {
            Get-DrsHeartbeat -ComputerName $computer
        }
        
        # Set AD Qeury Params
        $ou = $Config.environment.computerOu
        if ($ou.length -gt 0) {
            $adComputerQueryParams = @{
                Filter = 'servicePrincipalName -notLike "*Virtual*"'
                Properties = 'Name'
            }

            if ($config.environment.directoryServer) {
                 $adComputerQueryParams.add("Server",$config.environment.directoryServer)
            }

            if ($Credential) {
                $adComputerQueryParams.add("Credential",$Credential)
            }
        }
        
        
        Write-Verbose "# of OUs in Config: $($ou.length)"
        
        $ouComputers = foreach($unit in $ou) {
            #Get-AdComputer @adComputerQueryParams -SearchBase $unit
            Get-ADComputer @adComputerQueryParams -SearchBase $unit
        }

        # Make sure to specify .Name Attribute
        $ouComputerHeartbeats = foreach ($computer in $ouComputers) {
            Get-DrsHeartbeat -computer $computer.Name 
        }

        Write-Verbose "Returning all the heartbeats"
        $directComputerHeartbeats
        $ouComputerHeartbeats

        
    }
    
    end {
        
    }
}