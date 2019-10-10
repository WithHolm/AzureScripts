# POST method: $req
$requestBody = Get-Content $req -Raw | ConvertFrom-Json
$ModuleName = $requestBody.name

# GET method: each querystring parameter is its own variable
if ($req_query_name)
{
    $name = $req_query_name
}

#Input ModuleName
#Input Version

<#Output
    [
        {
            "Name":"ModuleName"
            "Version":"Version"
            "Content":"http://Path.To/ZippedModule.zip"
            "ContentReady":false
            "Dependencies":[
                {
                    "Name":"ParentModule"
                    "Version":ParentModuleVersion
                }
            ]
        }
        {
            "Name":"ParentModule"
        }
    ]
#>

Out-File -Encoding Ascii -FilePath $res -inputObject "Hello $name"

# powershell -noexit -noprofile -Command "$SID = ((Get-WmiObject win32_useraccount -Filter  {LocalAccount='True'} | Select-Object -First 1).SID) ; ($SID).Substring(0, $SID.LastIndexOf('-'))"