#Requires -Version 5.1
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
function Get-DrsDiskHealth {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        
        # Get Info for All Volumes and process
        # Use CIM here instead of 'Get-Volume' because measures at 6x faster
        $Volumes = Get-CimInstance -ClassName Win32_volume 
        
        
        foreach ($Volume in $Volumes) {
            # Check For Dirty Bit
            if ($Volume.DirtyBitSet) {
                $VolumeDirtyBit = $true
            }
            else {
                $VolumeDirtyBit = $false
            }
        
            # Return Each Volume as an Object
            [PSCustomObject]@{
                ComputerName = $Volume.SystemName
                Label        = $Volume.Label
                Drive        = $Volume.DriveLetter
                DirtyBit     = $VolumeDirtyBit
                DeviceId     = $Volume.DeviceId
                Capacity = $Volume.Capacity
                FreeSpace = $Volume.FreeSpace

            }
        }
        return
        
        
    }
    
    end {
        
    }
}