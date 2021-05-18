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
        [Parameter(Mandatory,ParameterSetName='ComputerSpecified',ValueFromPipeline)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        # Parameter for Creds
        [Parameter(ParameterSetName='ComputerSpecified')]
        [PSCredential]$Credential
    )
    
    begin {

        
    }
    
    process {
        
        # Common CIM Query Params
        # Filter Out Optical Drives (Drive Type 5)
        # Not using Get-Volume here because performance with Get-CimInstance is about 6x faster
        $cimParams = @{
            ClassName = 'Win32_volume'
            Filter = 'DriveType != 5' 
        }
        
        # Based on passed Params, query other computer or local
        if ($ComputerName) {
            if ($Credential) {
                Write-Verbose "Getting Volumes from Remote Computer, Credentials Specified"
                $volumes = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName -Credential $Credential
            } else {
                Write-Verbose "Getting Volumes from Remote Computer, Current User"
                $volumes = Get-DrsCimInstance -CimParams $cimParams -ComputerName $ComputerName 
            }
            
        } else {
            Write-Verbose "Getting Volumes from Local Computer"
            $volumes = Get-DrsCimInstance -CimParams $cimParams    
        }
               
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