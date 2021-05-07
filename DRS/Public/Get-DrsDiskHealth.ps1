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
            if ($Volume.DirtyBitSet) {
                $VolumeDirtyBit = $true
            }
            else {
                $VolumeDirtyBit = $false
            }

            # Format The Space Using the Private Format Function
            $VolumeSpace = Get-VolumeSpaceFormat -Volume $Volume
            $VolumeStatus = Get-VolumeHealthStatus -Volume $Volume
        
            # Return Each Volume as an Object
            [PSCustomObject]@{
                # TypeName     = 'DRS.Disk' # Possibly to Implement Later
                ComputerName = $Volume.SystemName
                Label        = $Volume.Label
                Drive        = $Volume.DriveLetter
                DirtyBit     = $VolumeDirtyBit
                DeviceId     = $Volume.DeviceId
                Capacity = $Volume.Capacity
                FreeSpace = $Volume.FreeSpace
                # Calculated from the Private Format Function
                FreeSpaceGB = $VolumeSpace.FreeSpaceGB
                CapacityGB = $VolumeSpace.CapacityGB
                FreeSpacePct = $VolumeSpace.FreeSpacePct
                Status = $VolumeStatus
            }
        }
        return
        
        
    }
    
    end {
        
    }
}