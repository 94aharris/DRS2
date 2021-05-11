<#
.SYNOPSIS
    Format a passed disk object Free Space %
    and Available Disk Space / Capacity
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
function Get-VolumeSpaceFormat {
    [CmdletBinding(DefaultParameterSetName = 'Volume')]
    param (
        # Volume to Return Formatted Space 
        [Parameter(Mandatory=$true,ParameterSetName='Volume',ValuefromPipeline=$True)]
        $Volume
    )
    
    begin {
        
    }
    
    process {
        $Volume | foreach {
            
            # Handle for Divide by Zero
            if ($Volume.Capacity -eq 0) {
                $VolumeCapacityGB = 0
            } else {
                # Calculate Capacity (TODO Add GB / TB / MB Rounding)
                $volumeCapacityGB = [math]::round(($volume.Capacity/ 1GB),2) -as [int]
            }
            
            # Run the Same Calculations for Free
            if ($Volume.FreeSpace -eq 0) {
                $VolumeFreeGB = 0
            } else {
                $VolumeFreeGB = [math]::round(($volume.FreeSpace/ 1GB),2) -as [int]
            }

            # Get an Easy Percent Handle for divide by zero 
            if (($Volume.FreeSpace -eq 0) -or ($Volume.Capacity -eq 0)) {
                $VolumeFreePct = 0
            } else {
                $VolumeFreePct = [math]::round((($volume.FreeSpace/$volume.Capacity) * 100),0) -as [int];
            }
            
            
            [PSCustomObject]@{
                CapacityGB = $VolumeCapacityGB
                FreeSpaceGB = $VolumeFreeGB
                FreeSpacePct = $VolumeFreePct
            }
        }
    }
    
    end {
        
    }
}