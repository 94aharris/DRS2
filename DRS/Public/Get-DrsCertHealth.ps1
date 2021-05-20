# Requires -Version 5.1

function Get-DrsCertHealth {
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
    [CmdletBinding(DefaultParameterSetName='NoParams')]
    param (
        
        # Parameter for the computers to query against
        [Parameter(Mandatory,ParameterSetName='ComputerSpecified',ValueFromPipeline)]
        [Alias("Computer")]
        [String[]]$ComputerName,

        # Parameter for Creds
        [Parameter(ParameterSetName='ComputerSpecified')]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName='Service')]
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
    
        # Block for Computer Cert
        $getCertBlock = {
            try {
                Get-ChildItem Cert:\LocalMachine\My -ErrorAction Stop |
                ForEach-Object {
                    [PSCustomObject]@{
                        Subject = $_.Subject
                        Expiration = $_.NotAfter
                        FriendlyName = $_.FriendlyName
                    }
                }
            } catch {
                Write-Error "Error Processing Cert Store $($_.Exception.Message)"
            }
        }

        # Based on passed Params, query other computer or local
        if ($ComputerName) {
            if ($Credential) {
                Write-Verbose "Getting Certs from Remote Computer, Credentials Specified"
                $certs = Invoke-Command -ComputerName $computerName -ScriptBlock $getCertBlock -Credential $Credential
            } else {
                Write-Verbose "Getting Certs from Remote Computer, Current User"
                $certs = Invoke-Command -ComputerName $computerName -ScriptBlock $getCertBlock 
            }
        } else {
            Write-Verbose "Getting Certs from Local Computer"
            $certs = Invoke-Command -ScriptBlock $getCertBlock
        }
        
        # Determine Health Based on Expiration
        if ($config.certHealth.ignoreExpiredOlderThanDays -gt 0) {
            $ignorePastDate = (Get-Date).AddDays(-($config.certHealth.ignoreExpiredOlderThanDays))
            Write-Verbose "Only Checking Certs that Expire After $ignorePastDate"
            $statusCerts = $certs | Where-Object {$_.expiration -gt $ignorePastDate}

        } else {
            Write-Verbose "Not Ignoring Any Expired Certs"
            $statusCerts = $certs
        }

        # Determine Dates for Alerts
        $criticalDate = (Get-Date).AddDays($config.certHealth.criticalExpirationDays)
        Write-Verbose "Critical Date: $criticalDate"

        $alertDate =    (Get-Date).AddDays($config.certHealth.alertExpirationDays)
        Write-Verbose "Alert Date: $AlertDate"

        $warningDate =  (get-Date).AddDays($config.certHealth.warningExpirationDays)
        Write-Verbose "Warning Date $warningDate"

        # Determine the Health
        foreach ($cert in $statusCerts) {
            
            Write-Verbose "Checking Expiration Health of $($cert.FriendlyName)"
            if ($cert.Expiration -lt $criticalDate) {
                Write-Verbose "$($cert.FriendlyName) is Critical on $($cert.Expiration)"
                $status = "Critical"
                $ruleResults = "Cert Expires Before $criticalDate"   
            }
            elseif ($cert.Expiration -lt $alertDate) {
                Write-Verbose "$($cert.FriendlyName) is Alert on $($cert.Expiration)"
                $status = "Alert"
                $ruleResults = "Cert Expires Before $alertDate"   
            }
            elseif ($cert.Expiration -lt $warningDate) {
                Write-Verbose "$($cert.FriendlyName) is Warning on $($cert.Expiration)"
                $status = "Warning"
                $ruleResults = "Cert Expires Before $warningDate"   
            }
            else {
                Write-Verbose "$($cert.FriendlyName) is Info on $($cert.Expiration)"
                $status = "Info"
                $ruleResults = ""
            }
        

            Write-Verbose "Returning Cert $($cert.FriendlyName)"
            [PSCustomObject]@{
                Subject = $cert.Subject
                FriendlyName = $cert.FriendlyName
                Expiration = $cert.Expiration
                Status = $status
                RuleResults = $ruleResults
            }
        }
    }
    
    end {
        
    }
}