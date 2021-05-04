<#

    Module Manifest for module 'DRS'

#>

@{
    # If authoring a script module, the RootModule is the name of your .psm1 file
    RootModule = 'DRS.psm1'

    ModuleVersion = '0.1'

    # Use the New-Guid command to generate a GUID, and copy/paste into the next line
    GUID = '8430552e-c39b-458b-b659-f7afc6d6c538'

    Description = 'The Daily Report Script 2 (DRS2) is a overhaul improvement to a daily reporting tool for windows environments'

    # Minimum PowerShell version supported by this module (optional, recommended)
    PowerShellVersion = '3.0'

    # Which PowerShell Editions does this module work with? (Core, Desktop)
    # CompatiblePSEditions = @('Desktop', 'Core')

    # Which PowerShell functions are exported from your module? (eg. Get-CoolObject)
    #FunctionsToExport = @('')
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    #CmdletsToExport = @('')
    CmdletsToExport = '*'

    # Variables to export from this module
    #VariablesToExport = @('')
    VariablesToExport = '*'

    # Which PowerShell aliases are exported from your module? (eg. gco)
    #AliasesToExport = @('')
    AliasesToExport = '*'

    # PowerShell Gallery: Define your module's metadata
    PrivateData = @{
        PSData = @{
            # What keywords represent your PowerShell module? (eg. cloud, tools, framework, vendor)
            Tags = @('Reporting', 'Monitoring')

            # What software license is your code being released under? (see https://opensource.org/licenses)
            #LicenseUri = ''

            # What is the URL to your project's website?
            #ProjectUri = ''

            # What is the URI to a custom icon file for your project? (optional)
            #IconUri = ''

            # What new features, bug fixes, or deprecated features, are part of this release?
            #ReleaseNotes = ''
        }
    }

    # If your module supports updateable help, what is the URI to the help archive? (optional)
    # HelpInfoURI = ''
}