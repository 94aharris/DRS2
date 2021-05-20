function Get-ComputerCert {
    [CmdletBinding()]
    param (
        
    )
    
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