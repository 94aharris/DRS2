#Requires -Version 5.1
function Get-DrsDiskHealth {
    <#
        .SYNOPSIS
            Get Disk Dirty Bit
        .DESCRIPTION
            Returns the current disk health status (dirty bit)
        .EXAMPLE
            PS C:\> Get-DrsDisk
            Returns local volumes health
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
        [Parameter(Mandatory=$true,ParameterSetName='ComputerSpecified',ValueFromPipeline=$True)]
        [Alias("Computer")]
        [String[]]$ComputerName

    )
    
    begin {
        
    }
    
    process {
        
        # Splat the cim params based on parameter set name used
        if ($PSCmdlet.ParameterSetName -eq 'ComputerSpecified') {
            
            # If computer is specified, passed computer and classname for win32_volume
            $cimParams = @{
                ClassName = 'Win32_volume'
                ComputerName = $ComputerName
            }
        
        } else {
        
            # if no params are passed, only pass the classname to cim
            $cimParams = @{
                ClassName = 'Win32_Volume'
            }
        
        }

        # Get Volumes using splatted params
        # Not using Get-Volume here because performance with Get-CimInstance is about 6x faster
        $volumes = Get-CimInstance @cimParams    
        
        foreach ($volume in $volumes) {
            
            # Check For Dirty Bit
            if ($volume.DirtyBitSet) {
                $volumeDirtyBit = $true
            }
            else {
                $volumeDirtyBit = $false
            }

            # Format The Space Using the Private Format Function
            $volumeSpace = Get-VolumeSpaceFormat -Volume $volume
            
        
            # Construct the statless Vol
            $statelessVol = [PSCustomObject]@{
                # TypeName     = 'DRS.Disk' # Possibly to Implement Later
                ComputerName = $volume.SystemName
                Label        = $volume.Label
                Drive        = $volume.DriveLetter
                DirtyBit     = $volumeDirtyBit
                DeviceId     = $volume.DeviceId
                Capacity = $volume.Capacity
                FreeSpace = $volume.FreeSpace
                # Calculated from the Private Format Function
                FreeSpaceGB = $volumeSpace.FreeSpaceGB
                CapacityGB = $volumeSpace.CapacityGB
                FreeSpacePct = $volumeSpace.FreeSpacePct
                Status = $volumeStatus
            }

            # Determine Vol Status
            $volumeStatus = Get-VolumeHealthStatus -Volume $statelessVol

            # Final Construction and Return
            [PSCustomObject]@{
                ComputerName = $volume.SystemName
                Label        = $volume.Label
                Drive        = $volume.DriveLetter
                DirtyBit     = $volumeDirtyBit
                DeviceId     = $volume.DeviceId
                Capacity = $volume.Capacity
                FreeSpace = $volume.FreeSpace
                # Calculated from the Private Format Function
                FreeSpaceGB = $volumeSpace.FreeSpaceGB
                CapacityGB = $volumeSpace.CapacityGB
                FreeSpacePct = $volumeSpace.FreeSpacePct
                Status = $volumeStatus.Severity
                RuleResults = $volumeStatus.RuleResults
            }

        }
        return
        
        
    }
    
    end {
        
    }
}