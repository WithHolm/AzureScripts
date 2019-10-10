function Get-AzToken {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext]$context,
        [string]$TenantID,
        [switch]$All
    )
    
    begin {
        
    }
    
    process {
        # Update-TypeData -MemberName TenantID
        # $context = Get-AzContext
        if(!$all)
        {
            if(!$TenantID)
            {
                $TenantID = $context.Tenant.Id
            }
        }
        else {
            $TenantID = "*"
        }
        ([System.Text.Encoding]::ASCII.GetString(($context.TokenCache.CacheData|select -Skip 10)).split('?')|?{$_ -like '$*'})|%{$_.substring(1)|convertfrom-json}|?{
            $_.result.tenantid -like $TenantID
        }
    }
    
    end {
        
    }
}