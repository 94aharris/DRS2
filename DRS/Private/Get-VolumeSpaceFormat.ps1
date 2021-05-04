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
            
            # Calculate Capacity (TODO Add GB / TB / MB Rounding)
            $VolumeCapacityGB = [math]::round(($volume.Capacity/ 1GB),2) -as [int]

            # Run the Same Calculations for Free
            $VolumeFreeGB = [math]::round(($volume.FreeSpace/ 1GB),2) -as [int]

            # Get an Easy Percent
            $VolumeFreePct = [math]::round((($volume.FreeSpace/$volume.Capacity) * 100),0) -as [int];
            
            
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