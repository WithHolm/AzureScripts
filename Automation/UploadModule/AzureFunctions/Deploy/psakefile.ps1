param(
    $SubscriptionName,
    
    [validateset("Prod", "Test")]
    $pipeline = "Test",

    [validateset("Build", "Teardown", "Pester")]
    $Action = "Build",

    $Location = "Westeurope"
)
Properties {
    $ProjectName = "AModuleService"
    $ResourceGroupName = "$ProjectName-$pipeline-RG"
    $StorageAccountName = "$($ProjectName)$($pipeline)SA".ToLower()
    $FunctionsAppName = "$ProjectName-$pipline-FA"
    $ResourceTags = @{
        Owner   = "Philip.meholm@atea.no"
        Project = $ProjectName
    }
}

task default -depends Validate,Run
Task Run -depends RemoveSolution,DeployCode
Task DeployCode -precondition { $Action -eq "Build" } -depends UploadFunctions



task Validate {
    Write-Output "Action: $Action"
    Write-Output "Pipeline: $pipeline"
    $Azlocation = (get-azlocation)
    if ($Location -notin $Azlocation.location)
    {
        throw "Could not find azure location $location. must be one of $($azlocation.Location)"
    }

    if ($SubscriptionName)
    {
        $context = get-azcontext
        if ($context.Subscription.Name -ne $SubscriptionName)
        {
            Write-Output "Setting azure context to subscription '$SubscriptionName'"
            Get-AzSubscription -SubscriptionName $SubscriptionName | Set-AzContext
        }
    }
    Write-Output "Azure context is '$((get-azcontext).Subscription.Name)'"
}

#Teardown
task RemoveSolution -precondition { $Action -eq "Teardown" } {
    $ResourceGroup = Get-AzResourceGroup|?{$_.ResourceGroupName -eq $ResourceGroupName}
    if($ResourceGroup)
    {
        $Resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        $Resources|%{
            Write-Output "Removing resource: $($_.ResourceId)"
            $_|Remove-AzResource -force
        }
        $ResourceGroup|Remove-AzResourceGroup -Force
    }
}

task ResourceGroup -depends Validate {
    # $SubscriptionName
    $RG = Get-AzResourceGroup | ? { $_.ResourceGroupName -eq $ResourceGroupName } # -Name $ResourceGroupName
    if (!$RG)
    {
        Write-Output "Creating new resourcegroup '$ResourceGroupName'"
        $RG = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    }
    else
    {
        Write-Output "'$($rg.ResourceGroupName)' already exists"
    }

    $ResourceTags.GetEnumerator() | % {
        # Write-Output "tag: $($_.name):$($rg.Tags["$($_.name)"])"
        if ($rg.Tags["$($_.name)"] -ne $_.Value)
        {
            Write-Output "Setting Tag $($_.Key) = $($_.Value)" # $($_|convertto-json)"
            $RgTags = @{ }
            $rg.Tags.GetEnumerator() | % {
                $RgTags.$($_.name) = $_.Value
            }
            $RgTags.$($_.name) = $_.Value
            $rg = $rg | Set-AzResourceGroup -Tag $RgTags
        }
    }
}

Task StorageAccountResource -depends ResourceGroup {
    $Storage = Get-AzResource -ResourceGroupName $ResourceGroupName | ? { $_.ResourceType -eq "Microsoft.Storage/storageAccounts" }
    if (@($Storage).count -gt 1)
    {
        Throw "There are several storage accounts in resourcegroup. please clean this up" 
    }

    if (!$Storage)
    {
        Write-Output "Creating new storageaccount '$StorageAccountName'"
        $Storage = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Tag $ResourceTags -SkuName Standard_LRS -Location $location -Kind StorageV2
    }
}

Task FunctionAppResource -depends StorageAccountResource,ResourceGroup {

    $properties 
    New-AzResource `
        -ResourceGroupName $ResourceGroupName `
        -Kind "Microsoft.Web/sites/functionapp" `
        -Location $Location `
        -Properties
    # New-AzWebApp -Name $FunctionsAppName -ResourceGroupName $ResourceGroupName -Location $Location -
}

Task UploadFunctions -depends FunctionAppResource {

}

# $creds = Invoke-AzResourceAction -ResourceGroupName "Random1234509" -ResourceType Microsoft.Web/sites/config -ResourceName Random1234509/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force

# $username = $creds.Properties.PublishingUserName
# $password = $creds.Properties.PublishingPassword



# $username = '<publish username>' #IMPORTANT: use single quotes as username may contain $
# $password = "<publish password>"
# $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

# $apiUrl = "https://<yourFunctionApp>.scm.azurewebsites.net/api/zip/site/wwwroot"
# $filePath = "<yourFunctionName>.zip"
# Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PUT -InFile $filePath -ContentType "multipart/form-data"

<#
Function DeployHttpTriggerFunction($ResourceGroupName, $SiteName, $FunctionName, $CodeFile, $TestData)
{
    $FileContent = "$(Get-Content -Path $CodeFile -Raw)"

    $props = @{
        config = @{
            bindings = @(
                @{
                    type = "httpTrigger"
                    direction = "in"
                    webHookType = ""
                    name = "req"
                }
                @{
                    type = "http"
                    direction = "out"
                    name = "res"
                }
            )
        }
        files = @{
            "index.js" = $FileContent
        }
        test_data = $TestData
    }

    New-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/functions -ResourceName $SiteName/$FunctionName -PropertyObject $props -ApiVersion 2015-08-01 -Force
}

#>