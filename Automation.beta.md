# Importing and updating Azure Automation Modules

<!-- 
*Warning: This is not a story of me making some super awesome script that does everything*   
-->
## Intro
Recently I was tasked with creating a routine in Azure Automation gathering some info and deleting some resourcegroups on a timer in our sandbox subscription.  
Naturally I created a Azure Automation account, a storage account, fired up VSCode, importing the 'az' and 'aztables' modules and making this work on my local computer.  
Because Azure Automation is running PS V5.1 it's not really a problem porting scripts created locally to Azure Automation cause they share alot of **simililarities(SPELLING)**.. Well, except for how to connect and some limitations like not using write-host and generally not supporting tasks that require user-interractions that is mostly true.

Long story short, Azure Automation couldnt handle the az module directly..Why?  

## Why it doesn't work
Azure Automation doesn't come pre configured with the Az module. It's generally because AzureRM and Az cannot function within the same session. Thinking that AzureRM have been out for years and Az have been in GA less than a [year](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-2.7.0), it's not surprising that Microsoft has AzureRM as the main module (But Az should be the defacto default for most people by now).  
To fix this I went to "Modules" in the Azure Automation blade, selected "Install from gallery", searched for "Az", and choose import. I was however met with a warning saying the [following](2019.10.01-AutomationModuleImportFail.JPG):
```
This module has dependencies that are not present in this account. 
All dependencies must be present before this module can be imported.
Dependencies:
Az.Accounts (≥ 1.6.2)
Az.Advisor (= 1.0.1)
...
```

Allright.. so in order to install this main module i had to install all the dependencies first, and then install this module. Now doing this via the GUI is tedious. 56 dependencies is uneccary if you can automate it, so lets see how we can do this:

```
PS C:\> ipmo Az.Automation
PS C:\> command *az*module*

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           Import-AzAutomationModule                          1.3.3      Az.Automation
Cmdlet          Get-AzAutomationModule                             1.3.3      Az.Automation
Cmdlet          New-AzAutomationModule                             1.3.3      Az.Automation
Cmdlet          Register-AzModule                                  1.6.2      Az.Accounts
Cmdlet          Remove-AzAutomationModule                          1.3.3      Az.Automation
Cmdlet          Set-AzAutomationModule                             1.3.3      Az.Automation
```

Great!  
We have both the alias `Import-AzAutomationModule`, the cmdlet `New-AzAutomationModule`!  
The alias just points to `New-AzAutomationModule` :
```
PS C:\> alias Import-AzAutomationModule|select ReferencedCommand

ReferencedCommand
-----------------
New-AzAutomationModule
```

So if we take a look at `New-AzAutomationModule`:
```
PS C:\> help New-AzAutomationModule

NAME
    New-AzAutomationModule

SYNOPSIS
    Imports a module into Automation.


SYNTAX
    New-AzAutomationModule [-ResourceGroupName] <System.String> [-AutomationAccountName] <System.String> [-Name] <System.String> [-ContentLinkUri] <System.Uri> [-DefaultProfile <Microsoft.Azure.Commands.Common.Authentication.Abstra
    ctions.Core.IAzureContextContainer>] [<CommonParameters>]


DESCRIPTION
    The New-AzAutomationModule cmdlet imports a module into Azure Automation. This command accepts a compressed file that has a .zip file name extension. The file contains a folder that includes a file that is one of the following....
```

This goes on, explaining what a module should contain, and how to check status after import.  
Documentation states it accepts a zip file, but i can only see that it accepts a `[uri]`, so one could guess that you insert a URL to a zip file that Automation can download without defining credentials. 

Ok, so now we know that we cannot just tell Azure Automation: 
> "Hey there! Please install module x and all dependencies from psgallery, thank you!"  

We have to tell Automation both the name of the module, AND a url of where it should grab the source files from. 

It's not really an optimal solution, and one could wish that this kind of thing would be better handled by Microsoft, but we work with what we have, right?  
Besides this shouldn't be TOO hard as I'm pretty sure SOMEONE have created a command..  

## Found a script
Searching around (and in hindsight practicing bad google-fu), I found mostly gui work, but i also found this: [Update Az. Modules](https://gallery.technet.microsoft.com/scriptcenter/Update-Az-Modules-a312e6bb), and after reading some of the code i can see he does 5 steps:
1. Create a storage account with random name
2. Download the newest version of az.* modules to your local profile
3. Zip each downloaded module, and upload it to blob storage.
4. Start `New-AzAutomationModule` with modulename and a link to the file in blob storage.
5. cleanup

I really liked the idea of generally zipping the module files, uploading them to azure storage and then importing them to Automation, but i could see some potential flaws with this: 
* seeing as this script requires me to be connected to azure via the same powershell session, using the az module this could potentially be trouble because i know `Compress-Archive` could complain if the file is currently in use. I know he handles it in the script, but still...
* It only works for az.* modules. No parameter for module name
    * In extension it downloads all az.* modules. some of them is PSv6 only, making import fail
    * az.* Is ALOT of modules.. 85 at this time... zipping all of them and uploading to blob could take alot of time. we are talking 800-900 MB of data. 
* does not check if the module is already present in automation before doing any work
* verbose/debug messaging and inscript documentation
* no checking if the modules have sucessfully installed

Generally the script is well written and the idea is really nice, but some of this just irks me as this has alot of pontential for usage with jobs and generally handling temp data better and being async/faster. So why dont we try to improve this?

----
## The Fix
Ok First of all, the process is as follows:
1. Download modules
2. Zip modules
3. Create azure storage
3. Upload to azure storage
4. Import to azure
5. Delete temp files + storage

#### Going though this should be fixed:
* make it so i can search for any module
* when listing modules, use `-IncludeDependencies` to get all required modules.
* check that the module is not installed in current or newer version before doing any work. 
* Working with temporary files, i try to use $env:temp\{randomname}. `Get-random` generally works for temp folder names.  
* Use Jobs, Jobs, Jobs
* Ditch `Install-module`.. use `save-module` instead. Point this to the tempfolder
    * `save-module` also downloads all dependencies even if that dependency exists in current directory, so make sure that one job doesn't interfer with another.
* import of a module fails if automation cannot find the dependencies.
    * can be mitigated by installing modules with the least dependencies.. atleast untill i figure out a smarter solution for this
* Wait for import completion and list install status of all modules.
    * there is potential for the install to fail above reason or some othe issue, but you could just rerun the script and the missing modules should be installed. For now i accept this "feature", but in the future i would like to be able to read the actual failure message, and if there is a error i can do something with, remediate and reinstall.

### The Script  
Without geeking on the actual code, here is the repo. The script is named *V1*: [Script!](https://github.com/WithHolm/ModulesInAzureAutomation/)

Now if you take a look at the repo, you can see that there is also a V2 script there too.. Once i start something i have a tendency to really figure out if mye current solution is the most optimal one, and in this case.. Lets just say that i could have searched the internet better before jumping in tho this.


### The Revisement
After i made this script i realised that you COULD read the Information directly from Nuget (PowershellGallery) and find the package already hosted publicly. This means that i can skip the download step and go straight to registering the module in azure automation.

Thinking through the V1 version of my solution could be WAY more robust compared to the current solution.
1. I dont need a storage account.. the package is already hosted in powershell gallery, but the address is not "public" per-se. so i have to figure out how to get this information.
1. I ALWAYS need to wait for completion, as an import of a module needs to have all dependencies in place before loading. This also means i have to check if all dependencies have been imported before i import a given package.
1. I want this to run on both my client AND in Azure automation.


