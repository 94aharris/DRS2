# Get public and private function definitions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($import in @($Public + $Private)) {
    Try
    {
        .$import.fullname
    }
    Catch {
        Write-Error -Message "Failed to Import Function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename