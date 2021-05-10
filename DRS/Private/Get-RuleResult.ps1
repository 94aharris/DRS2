function Get-RuleResult {
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
    [CmdletBinding(DefaultParameterSetName="ObjectRule")]
    param (
        # Object to Test 
        [Parameter(Mandatory=$true,ParameterSetName='ObjectRule',ValuefromPipeline=$True)]
        $TestObject,

        # Rule to Parse Against
        [Parameter(Mandatory=$true)]
        $Rule
    )
    
    begin {
        $ValidSeverityLevels = @(
            'Critical',
            'Alert',
            'Warning',
            'Info'
        )    
    }
    
    process {
        
        Write-Verbose "Validating Test Object for property"
        if ($TestObject.Psobject.properties.name -notcontains $Rule.property) {
            throw "Object $TestObject does not contain property $($Rule.property)"
        }

        Write-Verbose "Validating Rule Severity"
        if ($ValidSeverityLevels -notcontains $Rule.Severity) {
            throw "Rule $($Rule.Name) Severity $($Rule.Severity) is not a valid severity level"
        }
        
        Write-Verbose "Processing Alert Rule $($Rule.Name)"
        $compareVariables = @{
            property = $TestObject.($Rule.property)
            comparator = $Rule.comparator
            value = $Rule.value
        }
                
        Write-Verbose "Checking $($compareVariables['property']), $($compareVariables['comparator']), $($compareVariables['value'])"
        $RuleOutcome = compare-values @compareVariables

        Write-Verbose "Outcome: $RuleOutcome"
        if ($RuleOutcome) {
            [PSCustomObject]@{
                Severity = $Rule.severity
                Message = $Rule.Message
            }
        }
    }
    
    end {
        
    }
}