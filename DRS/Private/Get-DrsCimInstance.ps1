function Get-DrsCimInstance {
    [CmdletBinding(DefaultParameterSetName='LocalComputer')]
    param (
        
    
        # Parameter for Cim Params
        [Parameter(ParameterSetName='ComputerSpecified', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='LocalComputer', Mandatory, ValueFromPipeline, Position = 0)]
        [Hashtable] $CimParams,
        
        # Parameter for specifying computers
        [Parameter(Mandatory,ParameterSetName='ComputerSpecified')]
        [Alias("Computer")]
        [String[]]$computerName,

        # Parameter for specifying Credentials
        [Parameter(ParameterSetName='ComputerSpecified')]
        [PSCredential]$Credential

    )

    # Processing if ComputerName is Specified
    if ($ComputerName) {
        foreach ($computer in $ComputerName) {
            Write-Verbose "Procesing $computer"
    
            # Attempt to process a CimSession to the remote computer
            try {
                if ($Credential) {
                    Write-Verbose "Connecting to $computer with Credential"
                    $cimSession = New-CimSession -ComputerName $computer -Credential $Credential
                } else {
                    Write-Verbose "Connecting to $Computer as Current User"
                    $cimSession = New-CimSession -ComputerName $computer
                }
        
                # Perform Cim Query
                Write-Verbose "Querying $computer for $cimParams"
                Get-CimInstance @CimParams -CimSession $cimSession
        
            }   catch {
                Write-Error "Error Processing $Computer : $($_.Exception.Message)"
            } finally {
                if ($cimSession) {
                    Write-Verbose "Cleaning Up Cim Session to $computer"
                    Remove-CimSession -CimSession $CimSession -ErrorAction Continue
                }
            }
        }
        
    } 
    
    # Processing if no Computer Name is Specified
    else {
    
        Write-Verbose "Querying Local host for $cimParams"
        try {
            Get-CimInstance @cimParams
        } catch {
            Write-Error "Error Processing Local Computer : $($_.Exception.Message)"
        }
    }
    

    
}

