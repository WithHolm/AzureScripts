function Test-StorageAccountName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Name,
        [parameter(Mandatory)]
        [string]$SubcriptionID
    )
    
    begin {
        
    }
    
    process {
        $AuthToken = Get-AzToken -context (Get-AzContext)


        $Request = @(
            @{
                Content = @{
                    Name = $Name
                    Type = "Microsoft.Storage/storageAccounts"
                }
                httpMethod = "POST"
                requestHeaderDetails=@{
                    commandName = "Microsoft_Azure_Storage.CreateStorageAccountHelper.validateStorageAccountNameForCreate"
                }
                url = "https://management.azure.com/providers/microsoft.resources/checkresourcename?api-version=2015-11-01"
            }
            @{
                Content = @{
                    Name = $Name
                    Type = "Microsoft.Storage/storageAccounts"
                }
                httpMethod = "POST"
                requestHeaderDetails=@{
                    commandName = "Microsoft_Azure_Storage.StorageHelper.executeStorageNameCheck"
                }
                url = "https://management.azure.com/subscriptions/$SubcriptionID/providers/Microsoft.Storage/locations/westeurope/checkNameAvailability?api-version=2019-06-01"
            }
        )
        $header = @{
            Authorization="$($AuthToken.Result.AccessTokenType) $($AuthToken.Result.AccessToken)"
        }
        foreach($req in $request)
        {
            $header.keys|%{
                $req.requestHeaderDetails.$_ = $header.$_
            }
            $return = Invoke-WebRequest  -Uri $req.url -Headers $req.requestHeaderDetails -Body ($req.content|convertto-json -Depth 99) -Method $req.httpmethod -ContentType "application/json"
            $content = $return.content|ConvertFrom-Json
            switch($req.requestHeaderDetails.commandName)
            {
                "Microsoft_Azure_Storage.StorageHelper.executeStorageNameCheck"{
                    if(!$content.nameAvailable)
                    {
                        throw $return.content
                    }
 
                }
                "Microsoft_Azure_Storage.CreateStorageAccountHelper.validateStorageAccountNameForCreate"{
                    if($content.status -ne "Allowed")
                    {
                        throw $return.content
                    }
                }
                default{
                    throw "Cannot find any handling for command $($req.requestHeaderDetails.commandName)"
                }
            }
        }
    }
    
    end {
        
    }
}

# Test-StorageAccountName -Name "testing" -Verbose