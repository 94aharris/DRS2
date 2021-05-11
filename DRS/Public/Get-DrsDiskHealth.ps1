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
        
        # Splat the cim params based on parameter set name used
        switch ($PSCmdlet.ParameterSetName) {
            
            # Processing for Multiple Computers
            'ComputerSpecified' {
                
                $volumes = foreach ($computer in $computerName) {
                    
                    Write-Verbose "Processing $Computer"
                    # Attempt to process a CimSession to the remote computer
                    try {
                        if ($Credential) {
                            Write-Verbose "Connecting to $Computer with Credentials"
                            $cimSession = New-CimSession -ComputerName $Computer -Credential $Credential
                        } else {    
                            Write-Verbose "Connecting to $Computer as Current User"
                            $cimSession = New-CimSession -ComputerName $Computer 
                        }
                        
                        # If computer is specified, passed computer and classname for win32_volume
                        Write-Verbose "Getting Volume Info From $Computer"
                        Get-CimInstance @cimParams -CimSession $cimSession

                    } catch {
                        throw "Error Processing $Computer : $($_.Exception.Message)"
                    } Finally {
                        if ($cimSession) {
                            Write-Verbose "Cleaning Up CIM Session to $Computer"
                            Remove-CimSession -CimSession $cimSession
                        }
                    }

                }

              }
            
            # Processing for No Params (Local Computer)
            Default {
                # Get Volumes using splatted params
                Write-Verbose "Getting Volume Info From Local Host"
                $volumes = Get-CimInstance @cimParams    
            }
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