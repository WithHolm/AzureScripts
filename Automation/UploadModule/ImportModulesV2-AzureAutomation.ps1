[cmdletbinding()]
param(
    [string]$ModuleName,
    [ValidateSet("AzureRM", "Az")]
    [string]$UsingAzuremodule = "Az",
    [bool]$CheckModulePowershellRestriction
)
<#
    $ThisPkg = [pscustomobject]@{
        Name = $Package.properties.id
        Version = $Package.properties.Version
        ContentLink = "$NugetUri/package/$($Package.properties.id)/$($Package.properties.Version)"
        dependencies = @()
        Raw = $package
    }
#>
$UpdateNugetTypeDataParam = @{
    MemberType = "NoteProperty"
    Force = $true
    TypeName = "NugetPkg"
}
Update-TypeData @UpdateNugetTypeDataParam -MemberName "Name" -Value ""
Update-TypeData @UpdateNugetTypeDataParam -MemberName "Version" -Value ""
Update-TypeData @UpdateNugetTypeDataParam -MemberName "ContentLink" -Value $null
Update-TypeData @UpdateNugetTypeDataParam -MemberName "Dependencies" -Value @()
Update-TypeData @UpdateNugetTypeDataParam -MemberName "Raw" -Value $null

<#
    $ThisPkg.dependencies += [pscustomobject]@{
        Name = $OneDepArr[0]
        MinimumVersion = $versions[0]
        MaximumVersion = $versions[1]
    }
#>
$UpdateDependencyTypeDataParam = @{
    MemberType = "NoteProperty"
    Force = $true
    TypeName = "NugetDependency"
}
Update-TypeData @UpdateNugetTypeDataParam -MemberName "Name" -Value ""
Update-TypeData @UpdateNugetTypeDataParam -MemberName "MinimumVersion" -Value ""
Update-TypeData @UpdateNugetTypeDataParam -MemberName "MaximumVersion" -Value ""


function Format-StringModern {
    [CmdletBinding()]
    param (
        [string]$InputString,
        $object
    )
    
    begin {
        
    }
    
    process {
        [regex]::Matches($InputString,"([{].*?[}])")|%{
            $Key = $_.value.substring(1,$_.length-2)
            $value = $object
            $key.split(".")|%{
                $value = $value.$_
            }
            $Inputstring = $Inputstring.Replace($_,($value).tostring()) 
        }
        return $InputString
    }
    
    end {
        
    }
}


function Find-NugetPkg
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string] $ModuleName,
        [String] $Minimumversion,
        [String] $Maximumversion,
        [switch] $IncludeDependencies,
        [switch] $AcceptPreview,
        [string] $NugetUri = 'https://www.powershellgallery.com/api/v2',
        [string] $DownloadSource = 'https://devopsgallerystorage.blob.core.windows.net/packages/{name}.{version}.nupkg'
    )
    
    begin
    {
    }
    
    process
    {
        $Packages = @()
        $InitialSearch = $true
        $RunQuery = $true
        $Apipackages = @()
        While ($RunQuery)
        {
            if ($InitialSearch -eq $true)
            {
                $Endpoint = "FindPackagesById()"
                $query = [ordered]@{
                    id = "'$ModuleName'"
                }
            }
            else 
            {
                $Endpoint = "Search()"
                $query = [ordered]@{
                    filter            = "''"
                    searchTerm        = "'$modulename'"
                    targetFramework   = "''"
                    includePrerelease = $false
                    '$skip'           = 0
                    '$top'            = 40
                }
            }

            $SearchUri = [uri]"$NugetUri/$Endpoint`?$(($query.Keys|%{"$_=$($query[$_])"}) -join '&')"
            $SearchResult = @(Invoke-RestMethod -Method Get -Uri $SearchUri)
            if ($SearchResult.count -eq 0 -and $InitialSearch)
            {
                $InitialSearch = $false
                Write-verbose "Switching from 'FindPackageById' to 'Search'"
                continue
            }
            elseif ($SearchResult.Count -eq 0 -and !$InitialSearch)
            {
                Write-Verbose "Could not find any packages with the search term '$($query.searchterm)' or filter:'$($query.filter)'"
                $RunQuery = $false
            }
            else
            {
                if ($SearchResult.count -eq 40)
                {
                    $query.'$skip' += $SearchResult.Count
                }
                else
                {
                    $RunQuery = $false
                }
            }
            $Apipackages += $SearchResult
        }
        if($AcceptPreview -and !$Maximumversion)
        {
            Write-verbose "Getting Latest preview version if avalible"
            $Apipackages = @($Apipackages.Where{$_.properties.IsabsoluteLatestVersion})
        }
        elseif($AcceptPreview -and $Maximumversion)
        {
            throw "Cannot accept previews versions and set a maximum version"
        }
        elseif($Maximumversion) {
            Write-version "Getting versions over $Maximumversion"
            $ApiPackages = @($ApiPackages.where{$_.properties.version -le $Maximumversion})
        }
        else{
            Write-verbose "Getting Latest (non preview) version"
            $Apipackages = @($ApiPackages.where{$_.properties.IsLatestVersion})
        }

        if($Minimumversion)
        {
            $ApiPackages = @($ApiPackages.Where{$_.properties.version -ge $Minimumversion})
        }

        if($ApiPackages.count -gt 1)
        {
            Write-verbose "Selecting highest version of each packageinfo from api"
            #Select the highest version from each of the returning packagenames
            $ApiPackages = @($ApiPackages.properties.id|Select-Object -Unique|%{
                $pkgname = $_
                $Apipackages|
                    Where-Object{$_.properties.id -eq $pkgname}|
                        Sort-object id -Descending|
                            Select-Object -first 1
            })
        }

        # $Packages = $Packages|sort-object 

        Foreach($package in $Apipackages)
        {
            Write-verbose "Creating package object for $($package.id)"
            $ThisPkg = [pscustomobject]@{
                Name = $Package.properties.id
                Version = $Package.properties.Version
                ContentLink = "$NugetUri/package/$($Package.properties.id)/$($Package.properties.Version)"
                dependencies = @()
                Raw = $package
                TypeName = "NugetPkg"
            }
            if($DownloadSource)
            {
                $ThisPkg.ContentLink = Format-StringModern -InputString $DownloadSource -object $ThisPkg
            }
            
            $Dep = @($($Package.properties.dependencies.split("|")))
            Write-verbose "Converting text for $($Dep.count) dependenc$(if($Dep.count -gt 1){"ies"}else{"y"}) to dependency objects."
            
            #Dependencies comes in as a huge string, so figure out how to split it and deliver back a array of pscustomobject with dependencyinfo
            #"Az.Accounts:[1.6.2, ):|Az.Advisor:[1.0.1, 1.0.1]:|Az.Aks:[1.0.2, 1.0.2]:" etc....
            $Dep.ForEach{
                #"Az.Accounts:[1.6.2, ):" --split--> "Az.Accounts","[1.6.2, )",""
                $OneDepArr = @($_.split(":"))

                #"[1.6.2, )" --Replace--> "1.6.2, " --split--> "1.6.2"," " --trim--> "1.6.2"," " --Where not null or empty--> "1.6.2"
                $versions = @(($OneDepArr[1] -replace "\[|\]|\)|\(", "").split(",") | % { $_.trim() })
                if(![string]::IsNullOrEmpty($OneDepArr[0]))
                {
                    $ThisPkg.dependencies += [pscustomobject]@{
                        Name = $OneDepArr[0]
                        MinimumVersion = $versions[0]
                        MaximumVersion = $versions[1]
                    }
                }
            }
            $Packages += $ThisPkg
        }

        if($IncludeDependencies)
        {
            
            foreach($package in $packages)
            {
                Write-Verbose "testing if dependencies for $($package.name) should be added (Count:$($package.dependencies.count))"
                #include Dependencies
                Foreach($Dependency in $package.Dependencies)
                {

                    <#
                    [pscustomobject]@{
                        Name = $dep[0]
                        MinimumVersion = $versions[0]
                        MaximumVersion = $versions[1]
                    }
                    #>
                    #Figure out if package already has a entry in $packages
                    $ExisitingDependencyPackages = $Packages|?{$_.name -eq $Dependency.name}
    
                    if($Dependency.MinimumVersion)
                    {
                        $ExisitingDependencyPackages = $ExisitingDependencyPackages|?{$_.version -ge $Dependency.MinimumVersion}
                    }
                    if($Dependency.MaximumVersion)
                    {
                        $ExisitingDependencyPackages = $ExisitingDependencyPackages|?{$_.version -le $Dependency.MaximumVersion}
                    }
                    if(!$ExisitingDependencyPackages)
                    {
                        Write-Verbose "Adding info about dependency $($Dependency.name)"
                        $packages += @(Find-NugetPkg -ModuleName $Dependency.name -Maximumversion $Dependency.MaximumVersion -Minimumversion $Dependency.MinimumVersion)
                    }
                    else {
                        Write-verbose "Found exisisting package for $($ExisitingDependencyPackages.name)"
                    }
                    # Write-verbose $
                }
            }
        }
        $Packages
    }
    
    end
    {
        
    }
}

function Install-AzAutomationModule
{
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline = $true,Mandatory=$true)]
        [Microsoft.Azure.Commands.Automation.Model.AutomationAccount] $AutomationAccount,
        
        [parameter(Mandatory = $true)]
        [string] $ModuleName,
        
        [String] $Maximumversion
    )
    
    begin
    {
        $Packages = Find-NugetPkg -ModuleName $ModuleName -Maximumversion $Maximumversion -IncludeDependencies
    }
    
    process
    {
        # $AutomationAccount
        $Installedmodules = Get-AzAutomationModule -ResourceGroupName $AutomationAccount.ResourceGroupName -AutomationAccountName $AutomationAccount.AutomationAccountName
        Write-Verbose "Installing $($packages.count) packages to AutomationAccount $($AutomationAccount.AutomationAccountName)"
        Foreach($Package in $packages)
        {
            $modulepresent = $Installedmodules|?{$_.name -eq $Package.name -and $_.Version -eq $Package.version -and $_.ProvisioningState -in @("Created","Succeeded")}
            if($modulepresent)
            {
                Write-Verbose "Installing module $($package.name):$($package.version)"
                $AutomationAccount|New-AzAutomationModule -Name $package.name -ContentLinkUri $package.ContentLink
            }
            else 
            {
                Write-Verbose "Did not install module ($Package.name): Allready present $($modulepresent|convertto-json)"    
            }
        }

        
    }
    
    end
    {
        
    }
}

if($ModuleName)
{
    
}

# Find-NugetPkg -ModuleName "az" # -Maximumversion "4.0" -Verbose -IncludeDependencies #|select -ExpandProperty dependencies
#Get-ModuleDependencyAndLatestVersion -ModuleName az -Verbose