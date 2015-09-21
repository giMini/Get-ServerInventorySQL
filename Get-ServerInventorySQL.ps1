<#
#requires -version 4

.SYNOPSIS         
    Name : Server Inventory (Get-ServerInventorySQL.ps1)
    Description : Get informations from remote servers with WMI and ouput in an SQL Database
 
    Author : Pierre-Alexandre Braeken
    
    * Select list of servers from a CSV file with an OpenFileDialog
    * Get remotely Servers informations with WMI and Powershell :
    * General (Domain, role in the domain, hardware manufacturer, type and model, cpu number, memory capacity, operating system and sp level)
    * System (BIOS name, BIOS version, hardware serial number, time zone, WMI version, virtual memory file location, virtual memory current usage, virtual memory peak usage and virtual memory allocated)
    * Processor (Processor(s), processor type, family, speed in Mhz, cache size in GB and socket number)
    * Memory (Bank number, label, capacity in GB, form and type)
    * Disk (Disk type, letter, capacity in GB, free space in GB + display a chart Excel)
    * Network (Network card, DHCP enable or not, Ip address, subnet mask, default gateway, Dns servers, Dns registered or not, primary and secondary wins and wins lookup or not) 
    * Installed Programs (Display name, version, install location and publisher) 
    * Share swith NTFS rights (Share name, user account, rights, ace flags and ace type) 
    * Services (Display name, name, start by, start mode and path name)
    * Scheduled Tasks (Name, last run time, next run time and run as)
    * Printers (Locationm, name, printer state and status, share name and system name)
    * Process (Name, Path and sessionID)
    * Local Users (Groups, users)
    * ODBC Configured (dsn, Server, Port, DatabaseFile, DatabaseName, UID, PWD, Start, LastUser, Database, DefaultLibraries, DefaultPackage, DefaultPkgLibrary, System, Driver, Description)
    * ODBC Drivers Installed (Driver, DriverODBCVer, FileExtns, Setup)
    * Operating System Privileges (Strategy, SecurityParameters)   
    * MB to GB conversion
    * Display of the progress of the script

.INPUT
    .csv file with servers to activate

.OUTPUTS
    Console outputs : server ok or not ok
    Log file 

.NOTES
    Version:        1.0
    Author:         Pierre-Alexandre Braeken
    Creation Date:  2015-05-12
    Purpose/Change: Initial script development
  
.EXAMPLE
    .\Get-ServerInventorySQL.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

$scriptPath = split-path -parent $myInvocation.MyCommand.Definition
$loggingFunctions = "$scriptPath\logging\Logging_Functions.ps1"
. $loggingFunctions

$tc = [System.Management.ManagementDateTimeconverter] 

$start =$tc::ToDmtfDateTime((Get-Date).AddDays(-1).Date) 

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script version will be write in the log file
$sScriptName = "Get-ServerInventorySQL"
$sScriptVersion = "1.0"

#Log File Info
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$launchDate = get-date -f "yyyyMMdd"
$sLogPath = $scriptPath + "\" + $launchDate
$logDate = get-date -f "yyyyMMddHHmm"

if(!(Test-Path $sLogPath)) {
    New-Item $sLogPath -type directory
}

$sLogName = $sScriptName + $logDate + ".log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

$returnValue = ""

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Connect-Database' - connect to a SQL database
# ________________________________________________________________________
Function Connect-Database($connString){
    $sqlConnection = new-object System.Data.SqlClient.SqlConnection
    $sqlConnection.ConnectionString = $connString
    return $sqlConnection
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Count-Record' - count number of record about a query
# ________________________________________________________________________
Function Count-Record($query) {
    $queryText = $query
    $sqlCommand = $sqlConnection.CreateCommand()
    $sqlCommand.CommandText = $QueryText
    $dataAdapter = new-object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataset = new-object System.Data.Dataset
    $dataAdapter.Fill($dataset) | Out-Null
    $nbRecord = ($dataset.Tables[0].recordCount)
    return $nbRecord
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Count-Record' - count number of record about a query
# ________________________________________________________________________
Function Select-FromDatabase($query) {
    $queryText = $query
    $sqlCommand = $sqlConnection.CreateCommand()
    $sqlCommand.CommandText = $QueryText
    $dataAdapter = new-object System.Data.SqlClient.SqlDataAdapter $sqlCommand
    $dataset = new-object System.Data.Dataset
    $dataAdapter.Fill($dataset) | Out-Null
    $record = ($dataset.Tables[0])
    return $record
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Insert-IntoDatabase' - insert record in a SQL table
# ________________________________________________________________________
Function Insert-IntoDatabase($sqlCommand, $query){        
    $sqlCommand.CommandText = $query
    try{
        $sqlCommand.executenonquery() | Out-Null
    }
    catch {
        $_.Exception
    }
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Clean-CharacterChain' remove spaces, quotes and accents 
# from a string
# ________________________________________________________________________
Function Clean-CharacterChain {
param ([String]$src = [String]::Empty)
    $normalized = $src.Normalize( [Text.NormalizationForm]::FormD )
    $normalized = $normalized.replace(" ","")    
    $normalized = $normalized.replace("'","")    
    $sb = new-object Text.StringBuilder
    $normalized.ToCharArray() | % { 
        if( [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($_)
        }
    }

    return $sb.ToString()        
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Read-OpenFileDialog' - Open an open File Dialog box
# ________________________________________________________________________
Function Read-OpenFileDialog([string]$InitialDirectory, [switch]$AllowMultiSelect) {      
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog        
    $openFileDialog.ShowHelp = $True    # http://www.sapien.com/blog/2009/02/26/primalforms-file-dialog-hangs-on-windows-vista-sp1-with-net-30-35/
    $openFileDialog.initialDirectory = $initialDirectory
    $openFileDialog.filter = "csv files (*.csv)|*.csv|All files (*.*)| *.*"
    $openFileDialog.FilterIndex = 1
    $openFileDialog.ShowDialog() | Out-Null
    return $openFileDialog.filename
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Translate-AccessMask' - Translate integer value in string
# ________________________________________________________________________
Function Translate-AccessMask($val) {
    Switch ($val)
    {
        2032127 {"FullControl"; break}
        1179785 {"Read"; break}
        1180063 {"Read, Write"; break}
        1179817 {"ReadAndExecute"; break}
        -1610612736 {"ReadAndExecuteExtended"; break}
        1245631 {"ReadAndExecute, Modify, Write"; break}
        1180095 {"ReadAndExecute, Write"; break}
        268435456 {"FullControl (Sub Only)"; break}
        default {$AccessMask = $val; break}
    }
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Translate-AceType' - Translate integer value in string
# ________________________________________________________________________
Function Translate-AceType($val) {
    Switch ($val)
    {
        0 {"Allow"; break}
        1 {"Deny"; break}
        2 {"Audit"; break}
    }
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Translate-AceFlagse' - Translate integer value in string
# ________________________________________________________________________
<#  OBJECT_INHERIT_ACE
    1 (0x1)
    Noncontainer child objects inherit the ACE as an effective ACE.
    For child objects that are containers, the ACE is inherited as an inherit-only ACE unless the NO_PROPAGATE_INHERIT_ACE bit flag is also set.
    CONTAINER_INHERIT_ACE
    2 (0x2)
    Child objects that are containers, such as directories, inherit the ACE as an effective ACE. The inherited ACE is inheritable unless the NO_PROPAGATE_INHERIT_ACE bit flag is also set.
    NO_PROPAGATE_INHERIT_ACE
    4 (0x4)
    If the ACE is inherited by a child object, the system clears the OBJECT_INHERIT_ACE and CONTAINER_INHERIT_ACE flags in the inherited ACE. This prevents the ACE from being inherited by subsequent generations of objects.
    INHERIT_ONLY_ACE
    8 (0x8)
    Indicates an inherit-only ACE which does not control access to the object to which it is attached. If this flag is not set, the ACE is an effective ACE which controls access to the object to which it is attached.
    Both effective and inherit-only ACEs can be inherited depending on the state of the other inheritance flags.
    INHERITED_ACE
    16 (0x10)
    The system sets this bit when it propagates an inherited ACE to a child object.
    Access these the same way. You can break them out using the bitwise AND operator or just test for the totals #>
Function Translate-AceFlags($val) {
    Switch ($val)
    {
        0 {"0"}
        1 {"Noncontainer child objects inherit"; break}
        2 {"Containers will inherit and pass on"; break}
        3 {"Containers AND Non-containers will inherit and pass on"; break}       
    }
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'Get-NtfsRights' - Enumerates NTFS rights of a folder
# ________________________________________________________________________
Function Get-NtfsRights($name,$path,$comp) {
	$path = [regex]::Escape($path)
	$share = "\\$comp\\$name"
	$wmi = gwmi Win32_LogicalFileSecuritySetting -filter "path='$path'" -ComputerName $comp
	$wmi.GetSecurityDescriptor().Descriptor.DACL | where {$_.AccessMask -as [Security.AccessControl.FileSystemRights]} |select `
                @{name="ShareName";Expression={$share}},
				@{name="Principal";Expression={"{0}\{1}" -f $_.Trustee.Domain,$_.Trustee.name}},
				@{name="Rights";Expression={Translate-AccessMask $_.AccessMask }},
				@{name="AceFlags";Expression={Translate-AceFlags $_.AceFlags }},
				@{name="AceType";Expression={Translate-AceType $_.AceType }}
				
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'listProgramsInstalled' - get info in registry 
# ________________________________________________________________________
Function listProgramsInstalled ($uninstallKey) {
    $array = @()

    $computername = $strComputer           
    $remoteBaseKeyObject = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)     
    if($remoteBaseKeyObject) {
        $remoteBaseKey = $remoteBaseKeyObject.OpenSubKey($uninstallKey)             
        if($remoteBaseKey) {
            $subKeys = $remoteBaseKey.GetSubKeyNames()            
            foreach($key in $subKeys){            
                $thisKey=$UninstallKey+"\\"+$key          
                $thisSubKey=$remoteBaseKeyObject.OpenSubKey($thisKey) 
                $psObject = New-Object PSObject        
                $psObject | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
                $psObject | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
                $psObject | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))
                $psObject | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
                $array += $psObject
            }    
        }     
    }  
    $array
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'getTasks' - get scheduled tasks on remote server 
# ________________________________________________________________________
Function getTasks($path) {
    $out = @()
    # Get root tasks
    $schedule.GetFolder($path).GetTasks(0) | % {
        $xml = [xml]$_.xml
        $out += New-Object psobject -Property @{
            "Name" = $_.Name
            "Path" = $_.Path
            "LastRunTime" = $_.LastRunTime
            "NextRunTime" = $_.NextRunTime
            "Actions" = ($xml.Task.Actions.Exec | % { "$($_.Command) $($_.Arguments)" }) -join "`n"
            "RunAs" = ($xml.Task.Principals.principal.userID)
        }
    }
    # Get tasks from subfolders
    $schedule.GetFolder($path).GetFolders(0) | % {
        $out += getTasks($_.Path)
    }    
    $out
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'getLocalUsersInGroup' - get local users in groups 
# ________________________________________________________________________
function getLocalUsersInGroup {
    if($saveIntDomainRole -le 3) {
        $serverADSIObject = [ADSI]"WinNT://$strComputer,computer"
        $localUserinGroups=@()
        $serverADSIObject.psbase.children | Where { $_.psbase.schemaClassName -eq 'group' } |`
            foreach {
                $group =[ADSI]$_.psbase.Path
                $group.psbase.Invoke("Members") | `
                foreach {$localUserinGroups += New-Object psobject -property @{Group = $group.Name;User=(($_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)) -replace "WinNT://","")}}
            }
    }
    else {
        $localUserinGroups = @()
    }
    $localUserinGroups
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'listODBCConfigured' - get ODBC connections configured 
# ________________________________________________________________________
Function listODBCConfigured ($odbcConfigured) {
    $computername = $strComputer 
    $arrayConfigured = @()           
    $remoteBaseKeyObject = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)     
    $remoteBaseKey = $remoteBaseKeyObject.OpenSubKey($odbcConfigured)             
    $subKeys = $remoteBaseKey.GetSubKeyNames()            
    foreach($key in $subKeys){            
        $thisKey=$odbcConfigured+"\\"+$key          
        $thisSubKey=$remoteBaseKeyObject.OpenSubKey($thisKey)         
        $psObjectConfigured = New-Object PSObject
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computername
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DSN" -Value $($thisSubKey.GetValue("dsn"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Server" -Value $($thisSubKey.GetValue("Server"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Port" -Value $($thisSubKey.GetValue("Port"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DatabaseFile" -Value $($thisSubKey.GetValue("DatabaseFile"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $($thisSubKey.GetValue("DatabaseName"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "UID" -Value $($thisSubKey.GetValue("UID"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "PWD" -Value $($thisSubKey.GetValue("PWD"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Start" -Value $($thisSubKey.GetValue("Start"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "LastUser" -Value $($thisSubKey.GetValue("LastUser"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Database" -Value $($thisSubKey.GetValue("Database"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DefaultLibraries" -Value $($thisSubKey.GetValue("DefaultLibraries"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DefaultPackage" -Value $($thisSubKey.GetValue("DefaultPackage"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "DefaultPkgLibrary" -Value $($thisSubKey.GetValue("DefaultPkgLibrary"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "System" -Value $($thisSubKey.GetValue("System"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Driver" -Value $($thisSubKey.GetValue("Driver"))
        $psObjectConfigured | Add-Member -MemberType NoteProperty -Name "Description" -Value $($thisSubKey.GetValue("Description"))
        $arrayConfigured += $psObjectConfigured
    }           
    $arrayConfigured    
}
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'listODBCInstalled' - get ODBC connections installed 
# ________________________________________________________________________
Function listODBCInstalled ($odbcDriversInstalled) {
    $computername = $strComputer 
    $arrayInstalled = @()       
    $remoteBaseKeyObject = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername)     
    $remoteBaseKey = $remoteBaseKeyObject.OpenSubKey($odbcDriversInstalled)             
    $subKeys = $remoteBaseKey.GetSubKeyNames()            
    foreach($key in $subKeys){            
        $thisKey=$odbcDriversInstalled+"\\"+$key          
        $thisSubKey=$remoteBaseKeyObject.OpenSubKey($thisKey)         
        $psObjectInstalled = New-Object PSObject
        $psObjectInstalled | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computername
        $psObjectInstalled | Add-Member -MemberType NoteProperty -Name "Driver" -Value $($thisSubKey.GetValue("Driver"))
        $psObjectInstalled | Add-Member -MemberType NoteProperty -Name "DriverODBCVer" -Value $($thisSubKey.GetValue("DriverODBCVer"))
        $psObjectInstalled | Add-Member -MemberType NoteProperty -Name "FileExtns" -Value $($thisSubKey.GetValue("FileExtns"))
        $psObjectInstalled | Add-Member -MemberType NoteProperty -Name "Setup" -Value $($thisSubKey.GetValue("Setup"))
        $arrayInstalled += $psObjectInstalled
    }           
    $arrayInstalled    
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function Name 'ListFile' - get server based on a CSV file
# ________________________________________________________________________
Function ListFile {	
    $fileOpen = Read-OpenFileDialog 
    if($fileOpen -ne '') {	
		$colComputers = Import-Csv $fileOpen
    }
    $colComputers
}
# Run-WmiRemoteProcess
Function Run-WmiRemoteProcess
{
    Param(
        [string]$computername=$env:COMPUTERNAME,
        [string]$cmd=$(Throw "You must enter the full path to the command which will create the process."),
        [int]$timeout = 0
    )
 
    Write-Host "Process to create on $computername is $cmd"
    [wmiclass]$wmi="\\$computername\root\cimv2:win32_process"
    # Exit if the object didn't get created
    if (!$wmi) {return}
 
    try{
    $remote=$wmi.Create($cmd)
    }
    catch{
        $_.Exception
    }
    $test =$remote.returnvalue
    if ($remote.returnvalue -eq 0) {
        Write-Host ("Successfully launched $cmd on $computername with a process id of " + $remote.processid)
    } else {
        Write-Host ("Failed to launch $cmd on $computername. ReturnValue is " + $remote.ReturnValue)
    }
 
    # Wait for the process to complete or to reach timeout
    $processId = $remote.processid
    $processActive = 1
    while ( $processActive -ge 1) {
        $process = Get-Wmiobject -class win32_process `
        -namespace "rootcimv2" -computerName $computername -Filter "ProcessId = $processId"
        if ($process -ne $null) {
            if ($processActive -ge $timeout -and $timeout -ne 0){
                Write-Host "Remote process execution is taking too long and timed out"
                return
            }
            $processActive++
            Start-Sleep -Seconds 1
        } else {
            Write-Host "Remote process finished"
            $processActive = 0
        }
    }
}

function Get-NameFromSid
{
    Param (
        [String]$currentSid
    )
 
    $objSID = $null
    $objUser = $null
 
    try {
        $sid = $currentSid.Replace("`*","")
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($sid)
        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
        Write-Host "SID $sid translated to $objUser.Value" 
        return $objUser.Value
    } catch {
        Write-Host "SID $sid could not be translated" 
        return $currentSid
    }
}
 
# to find the index of an element in an array
function Get-IndexOf {
    Param (
        [object[]]$array, $element
    )
 
    $line = 0..($array.length - 1) | where {$array[$_] -eq $element}
    return $line
}
 
# Parse the text file from the secdump and outputs an array of policies
function Parse-SecdumpFileToObject {
    Param (
        [String]$file
    )
 
    # The array that will be returned
    $policies = @()
 
    # put the text file to an array
    $fileContent = Get-Content $file
 
    # Find the delimitations of the security policies
    $start = IndexOf $fileContent "[Privilege Rights]"
    $end = IndexOf $fileContent "[Version]"
 
    # Extract the security policies between those delimitations
    For ($i = $start+1; $i -lt $end; $i++) {
        $policy = New-Object Object
        $line = $fileContent[$i].split(" =")
 
        # Add policy name to the policy
        Add-Member -memberType NoteProperty -name name -value $line[0] -inputObject $policy
        # Extract array of members, translate the SIDs, and add the members array to the policy
        $members = $line[3].split(",")
        For ($j = 0; $j -lt $members.Count; $j++) {
            if ($members[$j] -like "``**") {
                $members[$j] = Get-NameFromSid $members[$j]
            }
        }
        Add-Member -memberType NoteProperty -name members -value $members -inputObject $policy
 
        # Add the policy to the "policies" array
        $policies += $policy
    }
    return $policies
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptName $sScriptName -ScriptVersion $sScriptVersion

# open database connection

$connString = "Data Source=Q19466\SQLEXPRESS; Initial Catalog=PowerShellServerInventory; Integrated Security=True"
$sqlConnection = Connect-Database $connString
Log-Write -LogPath $sLogFile -LineValue "Database connection to $connString"
$sqlConnection.Open()
$sqlCommand = $sqlConnection.CreateCommand()
Log-Write -LogPath $sLogFile -LineValue "SqlCommand objec created"
$colComputers = ListFile	
$computerCount = $colComputers.Count
Log-Write -LogPath $sLogFile -LineValue "List of $computerCount computers to query collected" #`n"

$serversNotResponding = ""
$nbError = 0
$nbSuccess = 0
$nbTot = $computerCount 

foreach ($strComputer in $colComputers){    
    $items = ""
    $queryText = "Select count(*) as recordCount FROM ServerAudited"
    $nbServer = Count-Record($queryText)
    $strComputer = $strComputer.ServerName
    $serverName = $strComputer
    Write-Progress -Activity "Getting general information ($strComputer)" -status "Running..." -id 1                 
    $items = gwmi Win32_ComputerSystem -Comp $strComputer | Select-Object Domain, DomainRole, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory 
    if($items) {
        $domain = $items.Domain
        $domainRole = $items.DomainRole
        $manufacturer = $items.Manufacturer
        $model = $items.Model
        $systemType = $items.SystemType
        $numberOfProcessors = $items.NumberOfProcessors
        $totalPhysicalMemory = [math]::round(($items.TotalPhysicalMemory)/1024/1024/1024, 0)    
        Write-Progress -Activity "Getting systems information ($strComputer)" -status "Running..." -id 1
        $items = ""
        $items = gwmi Win32_OperatingSystem -Comp $strComputer | Select-Object Caption, csdversion   
        $operatingSystem = $items.Caption
        $servicePackLevel = $items.csdversion
        $items = ""
        $items = gwmi Win32_BIOS -Comp $strComputer | Select-Object Name, SMBIOSbiosVersion, SerialNumber
        $biosName = $items.Name
        $biosVersion = $items.SMBIOSbiosVersion
        $hardwareSerial = $items.SerialNumber
        $items = ""
        $items = gwmi Win32_TimeZone -Comp $strComputer | Select-Object Caption
        $timeZone = $items.Caption
        $items = ""
        $items = gwmi Win32_WmiSetting -Comp $strComputer | Select-Object BuildVersion    
        $wmiVersion = $items.BuildVersion             	      
        $items = ""
        $items = gwmi Win32_PageFileUsage -Comp $strComputer | Select-Object Name, CurrentUsage, PeakUsage, AllocatedBaseSize    
        $virtualMemoryName = $items.Name
        $virtualMemoryCurrentUsage = $items.CurrentUsage
        $virtualMermoryPeakUsage = $items.PeakUsage
        $virtualMemoryAllocatedBaseSize = $items.AllocatedBaseSize

        $saveIntDomainRole = $domainRole

        Switch($domainRole) {
            0{$domainRole = "Stand Alone Workstation"}
            1{$domainRole = "Member Workstation"}
            2{$domainRole = "Stand Alone Server"}
            3{$domainRole = "Member Server"}
            4{$domainRole = "Back-up Domain Controller"}
            5{$domainRole = "Primary Domain Controller"}
            default{"Undetermined"}
        }

        $serverQueryInsert = "INSERT INTO ServerAudited (serverID,serverName,domain,role,HW_Make,HW_Model,HW_Type,cpuCount,memoryGB,operatingSystem,servicePackLevel,
                    biosName,biosVersion,hardwareSerial,timeZone,wmiVersion,virtualMemoryName,virtualMemoryCurrentUsage,virtualMermoryPeakUsage,
                    virtualMemoryAllocatedBaseSize) VALUES('$nbServer','$serverName','$domain','$domainRole','$manufacturer','$model','$systemType','$numberOfProcessors',
                    '$totalPhysicalMemory','$operatingSystem','$servicePackLevel','$biosName','$biosVersion','$hardwareSerial','$timeZone','$wmiVersion','$virtualMemoryName',
                    '$virtualMemoryCurrentUsage','$virtualMermoryPeakUsage','$virtualMemoryAllocatedBaseSize')"
        Write-Progress -Activity "Inserting server information ($strComputer)" -status "Running..." -id 1  
        Insert-IntoDatabase $sqlCommand $serverQueryInsert
        Log-Write -LogPath $sLogFile -LineValue "$serverQueryInsert"

        Write-Progress -Activity "Getting processor information ($strComputer)" -status "Running..." -id 1     
        $items = ""
        $items = gwmi Win32_Processor -Comp $strComputer | Select-Object DeviceID, Name, Description, family, currentClockSpeed, l2cacheSize, UpgradeMethod, SocketDesignation
        Write-Progress -Activity "Inserting processor information ($strComputer)" -status "Running..." -id 1  
        foreach($item in $items) {
            $deviceLocator = $item.DeviceID
            $processorName = $item.Name
            $processorDescription = $item.Description
            $processorFamily = $item.family
            $currentClockSpeed = $item.currentClockSpeed
            $l2cacheSize = $item.l2cacheSize
            $upgradeMethod = $item.UpgradeMethod
            $socketDesignation = $item.SocketDesignation
            $processorQueryInsert =  "INSERT INTO ProcessorAudited (serverID,Name,TypeP,Family,Speed,CacheSize,Interface,SocketNumber) VALUES
                                ('$nbServer','$deviceLocator','$processorName','$processorFamily','$currentClockSpeed','$l2cacheSize','$upgradeMethod','$socketDesignation')"            
            Insert-IntoDatabase $sqlCommand $processorQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$processorQueryInsert"            
        }


        Write-Progress -Activity "Getting memory information ($strComputer)" -status "Running..." -id 1
        $items = ""
        $items = gwmi Win32_PhysicalMemory -Comp $strComputer | Select-Object DeviceLocator, Capacity, FormFactor, TypeDetail
        Write-Progress -Activity "Inserting memory information ($strComputer)" -status "Running..." -id 1
        foreach($item in $items) {
            $deviceLocator = $item.DeviceLocator
            $capacity = [math]::round(($item.Capacity)/1024/1024/1024, 0)
            $formFactor = $item.FormFactor
            $typeDetail = $item.TypeDetail
            $memoryQueryInsert = "INSERT INTO MemoryAudited (serverID,Label,Capacity,Form,TypeM) VALUES ('$nbServer','$deviceLocator','$capacity','$formFactor','$typeDetail')"
            Insert-IntoDatabase $sqlCommand $memoryQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$memoryQueryInsert"
        }

        Write-Progress -Activity "Getting disks information ($strComputer)" -status "Running..." -id 1      
        $items = ""       
        $items = gwmi Win32_LogicalDisk -Comp $strComputer | Select-Object DriveType, DeviceID, Size, FreeSpace
        Write-Progress -Activity "Inserting disk information ($strComputer)" -status "Running..." -id 1  
        foreach($item in $items) {
            $driveType = $item.DriveType
            $deviceID = $item.DeviceID
            $size = [math]::round(($item.Size)/1024/1024/1024, 0)   
            $freeSpace = [math]::round(($item.FreeSpace)/1024/1024/1024, 0)    
    
            Switch($driveType) {
                2{$driveType = "Floppy"}
                3{$driveType = "Fixed Disk"}
                5{$driveType = "Removable Media"}
                default{"Undetermined"}
            }
    
            $diskQueryInsert = "INSERT INTO DriveAudited (serverID,diskType,driveLetter,capacity,freeSpace) VALUES ('$nbServer','$driveType','$deviceID','$size','$freeSpace')"
            Insert-IntoDatabase $sqlCommand $diskQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$diskQueryInsert"
        }

        Write-Progress -Activity "Getting network information ($strComputer)" -status "Running..." -id 1 
        $items = ""
        $items = gwmi Win32_NetworkAdapterConfiguration -Comp $strComputer | Where{$_.IPEnabled -eq "True"} | Select-Object Caption, DHCPEnabled, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder, FullDNSRegistrationEnabled, WINSPrimaryServer, WINSSecondaryServer, WINSEnableLMHostsLookup
        Write-Progress -Activity "Inserting network information ($strComputer)" -status "Running..." -id 1  
        foreach($item in $items) {
            $caption = $item.Caption
            $dhcpEnabled = $item.DHCPEnabled
            $ipAddress = $item.IPAddress
            $ipSubnet = $item.IPSubnet
            $defaultIPGateway = $item.DefaultIPGateway
            $dnsServerSearchOrder = $item.DNSServerSearchOrder
            $fullDNSRegistrationEnabled = $item.FullDNSRegistrationEnabled
            $winsPrimaryServer = $item.WINSPrimaryServer
            $winsSecondaryServer = $item.WINSSecondaryServer
            $winsEnableLMHostsLookup = $item.WINSEnableLMHostsLookup
            $networkQueryInsert = "INSERT INTO NetworkAudited (serverID,networkCard,dhcpEnabled,ipAddress,subnetMask,defaultGateway,dnsServers,dnsReg,primaryWins,secondaryWins,winsLookup) 
            VALUES ('$nbServer','$caption','$dhcpEnabled','$ipAddress','$ipSubnet','$defaultIPGateway','$dnsServerSearchOrder','$fullDNSRegistrationEnabled',
            '$winsPrimaryServer','$winsSecondaryServer','$winsEnableLMHostsLookup')"
            Insert-IntoDatabase $sqlCommand $networkQueryInsert    
            Log-Write -LogPath $sLogFile -LineValue "$networkQueryInsert"
        }

        Write-Progress -Activity "Getting programs installed information ($strComputer)" -status "Running..." -id 1       
        # Populate Installed Programs           
        $arrayprogramsInstalled = listProgramsInstalled "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"        
        $arrayprogramsInstalled2 = listProgramsInstalled "SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"      
        $items = ""      
        $items = $arrayprogramsInstalled + $arrayprogramsInstalled2      
        Write-Progress -Activity "Inserting installed programs information ($strComputer)" -status "Running..." -id 1  
        foreach($item in $items) {
            $displayName = $item.DisplayName
            $displayVersion = $item.DisplayVersion
            $installLocation = $item.InstallLocation
            $publisher = $item.Publisher    
            if(!([string]::IsNullOrEmpty($displayName))) {    
                $installedProgramQueryInsert = "INSERT INTO InstalledProgramAudited (serverID,displayName,displayVersion,installLocation,publisher) VALUES ('$nbServer','$displayName','$displayVersion','$installLocation','$publisher')"
                Insert-IntoDatabase $sqlCommand $installedProgramQueryInsert
                Log-Write -LogPath $sLogFile -LineValue "$installedProgramQueryInsert"
            }
        }

        # Populate Shares 
        Write-Progress -Activity "Getting shares information ($strComputer)" -status "Running..." -id 1 
        if ($shares = Get-WmiObject Win32_Share -ComputerName $strComputer) {        
            $items = @() 
	        $shares | Foreach {$items += Get-NtfsRights $_.Name $_.Path $_.__Server}
        }
        else {$shares = "Failed to get share information from {0}." -f $($_.ToUpper())}            
        Write-Progress -Activity "Inserting shares information  ($strComputer)" -status "Running..." -id 1
        $shareName = ""
        $shareNameSave = ""
        foreach ($item in $items) { 
            $shareName = $item.ShareName
            if($shareName -ne $shareNameSave) {
                $sharesQueryInsert = "INSERT INTO ShareAudited (serverID,shareName) VALUES ('$nbServer','$shareName')"        
                Insert-IntoDatabase $sqlCommand $sharesQueryInsert
                $shareNameSave = $shareName
                Log-Write -LogPath $sLogFile -LineValue "$sharesQueryInsert"
            }
            $principal = $item.Principal
            $rights = $item.Rights
            $aceFlags = $item.AceFlags
            $aceType = $item.AceType
    
            $queryText = "Select shareAuditedID as shareAuditedID FROM ShareAudited WHERE shareName LIKE '$shareName'"
            $recordReturned = Select-FromDatabase($queryText)
            $shareAuditedID = $recordReturned.shareAuditedID
            $sharesRightsQueryInsert = "INSERT INTO ShareRightsAudited (shareAuditedID,account,rights,aceFlags,aceType) VALUES ('$shareAuditedID','$principal','$rights','$aceFlags','$aceType')"        
            Insert-IntoDatabase $sqlCommand $sharesRightsQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$sharesRightsQueryInsert"
        } 

        # Populate Services   
        Write-Progress -Activity "Getting services information ($strComputer)" -status "Running..." -id 1 	
        $items = ""
        $items = Get-WmiObject win32_service -Comp $strComputer | Select-Object DisplayName, Name, StartName, StartMode, PathName, Description                 
        Write-Progress -Activity "Inserting services information ($strComputer)" -status "Running..." -id 1
        foreach ($item in $items) { 
            $displayName = $item.DisplayName
            $name = $item.Name
            $startName = $item.StartName
            $startMode = $item.StartMode
            $pathName = $item.PathName
            $description = $item.Description
            $description = $description.replace("'","")    

            $servicesQueryInsert = "INSERT INTO ServiceAudited (serverID,displayName,name,startName,startMode,servicePathName,serviceDescription) VALUES ('$nbServer','$displayName','$name','$startName','$startMode','$pathName','$description')"    
            Insert-IntoDatabase $sqlCommand $servicesQueryInsert     
            Log-Write -LogPath $sLogFile -LineValue "$servicesQueryInsert"   
        } 

        # Populate Scheduled Tasks       
        Write-Progress -Activity "Getting tasks information ($strComputer)" -status "Running..." -id 1     
        $items = @()        
        try { $schedule = new-object -comobject "Schedule.Service" ; $schedule.Connect($strComputer) }
        catch [System.Management.Automation.PSArgumentException] { throw $_ }          
        $items += getTasks("\")
        # Close com
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($schedule) | Out-Null
        Remove-Variable schedule        
        Write-Progress -Activity "Inserting Scheduled Tasks information ($strComputer)" -status "Running..." -id 1     
        foreach ($item in $items) { 
            $name = $item.Name
            $name = $name.replace("'","")    
            $path = $item.Path
            $path = $path.replace("'","")    
            $lastRunTime = $item.LastRunTime
            $nextRunTime = $item.NextRunTime
            $actions = $item.Actions
            $runAs = $item.RunAs

            $scheduledTasksQueryInsert = "INSERT INTO ScheduledTaskAudited (serverID,name,pathName,lastRunTime,nextRunTime,scheduledAction,runAs) VALUES ('$nbServer','$name','$path','$lastRunTime','$nextRunTime','$actions','$runAs')"
            Insert-IntoDatabase $sqlCommand $scheduledTasksQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$scheduledTasksQueryInsert" 
        }

        # Populate Printers     
        Write-Progress -Activity "Getting printers information ($strComputer)" -status "Running..." -id 1
        $items = ""
        $items = gwmi Win32_Printer -Comp $strComputer | Select-Object Location, Name, PrinterState, PrinterStatus, ShareName, SystemName           
        Write-Progress -Activity "Inserting Printers information ($strComputer)" -status "Running..." -id 1  
        foreach ($item in $items) {  
            $name = $item.Name
            $location = $item.Location
            $printerState = $item.PrinterState
            $printerStatus = $item.PrinterStatus
            $shareName = $item.ShareName
            $systemName = $item.SystemName

            $printerQueryInsert = "INSERT INTO PrinterAudited (serverID,name,location,printerState,printerStatus,shareName,systemName) VALUES ('$nbServer','$name','$location','$printerState','$printerStatus','$shareName','$systemName')"
            Insert-IntoDatabase $sqlCommand $printerQueryInsert    
            Log-Write -LogPath $sLogFile -LineValue "$printerQueryInsert" 
        }                 
        # Populate Process worksheet       
        Write-Progress -Activity "Getting process information ($strComputer)" -status "Running..." -id 1     
        $items = ""
        $items = gwmi win32_process -ComputerName $strComputer | select-object Name, Path, SessionId 
        Write-Progress -Activity "Inserting Process information ($strComputer)" -status "Running..." -id 1  
        foreach ($item in $items) {  
            $name = $item.Name
            $location = $item.Location
            $sessionID = $item.sessionID

            $processQueryInsert = "INSERT INTO ProcessAudited (serverID,name,location,sessionID) VALUES ('$nbServer','$name','$location','$sessionID')"
            Insert-IntoDatabase $sqlCommand $processQueryInsert    
            Log-Write -LogPath $sLogFile -LineValue "$processQueryInsert" 
        }    

        # Populate ODBC Configured 
        Write-Progress -Activity "Getting ODBC connections Configured ($strComputer)" -status "Running..." -id 1   
        if($systemType -eq "x86-based PC") {
            $odbcConfigured = "SOFTWARE\\odbc\\odbc.ini"
            $odbcDriversInstalled = "SOFTWARE\\odbc\\odbcinst.ini"
        }
        else {
            $odbcConfigured = "SOFTWARE\\wow6432Node\\odbc\\odbc.ini"
            $odbcDriversInstalled = "SOFTWARE\\wow6432Node\\odbc\\odbcinst.ini"
        }     
        Write-Progress -Activity "Formating the output - ODBC connections Configured ($strComputer)" -status "Running..." -id 1 
        $items = ""
        $items = listODBCConfigured $odbcConfigured        
        foreach ($item in $items) {  
            $dsn = $item.dsn
            $serverName = $item.serverName
            $port = $item.port
            $dataBaseFile = $item.dataBaseFile
            $dataBaseName = $item.dataBaseName
            $odbcUID = $item.odbcUID
            $odbcPWD = $item.odbcPWD
            $start = $item.start
            $lastUser = $item.lastUser
            $odbcDatabase = $item.odbcDatabase
            $defaultLibraries = $item.defaultLibraries
            $defaultPackage = $item.defaultPackage
            $defaultPkgLibrary = $item.defaultPkgLibrary
            $odbcSystem = $item.odbcSystem
            $driver = $item.driver
            $odbcDescription = $item.odbcDescription

            $odbcConfiguredQueryInsert = "INSERT INTO ODBCConfiguredAudited (serverID,dsn,serverName,port,dataBaseFile,dataBaseName,odbcUID,odbcPWD,start,lastUser,odbcDatabase,defaultLibraries,defaultPackage,defaultPkgLibrary,odbcSystem,driver,odbcDescription) 
            VALUES ('$nbServer','$dsn','$serverName','$port','$dataBaseFile','$dataBaseName','$odbcUID','$odbcPWD','$start','$lastUser','$odbcDatabase','$defaultLibraries','$defaultPackage','$defaultPkgLibrary','$odbcSystem','$driver','$odbcDescription')"    
            Insert-IntoDatabase $sqlCommand $odbcConfiguredQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$odbcConfiguredQueryInsert"
        }                   
        # Populate ODBC Drivers Installed               
        Write-Progress -Activity "Getting ODBC Drivers Installed ($strComputer)" -status "Running..." -id 1 
        $items = ""
        $items = listODBCInstalled $odbcDriversInstalled   
        Write-Progress -Activity "Formating the output - ODBC Drivers Installed ($strComputer)" -status "Running..." -id 1 
        foreach ($item in $items) {      
            $driver = $item.Driver
            $driverODBCVer = $item.DriverODBCVer
            $fileExtns = $item.FileExtns
            $setup = $item.Setup

            $odbcInstalledQueryInsert = "INSERT INTO ODBCInstalledAudited (serverID,driver,driverODBCVer,fileExtns,setup) VALUES ('$nbServer','$driver','$driverODBCVer','$fileExtns','$setup')"
            Insert-IntoDatabase $sqlCommand $odbcInstalledQueryInsert    
            Log-Write -LogPath $sLogFile -LineValue "$odbcInstalledQueryInsert"   
        }   

        Write-Progress -Activity "Getting local users information ($strComputer)" -status "Running..." -id 1                 
        $items = ""
        $items = getLocalUsersInGroup  
        Write-Progress -Activity "Inserting local users information ($strComputer)" -status "Running..." -id 1  
        foreach($item in $items) {
            $group = $item.Group
            $user = $item.User
            $localUsersQueryInsert = "INSERT INTO LocalGroupAudited (serverID,localGroup,userNested) VALUES ('$nbServer','$group','$user')"
            Insert-IntoDatabase $sqlCommand $localUsersQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$localUsersQueryInsert"
        }

        Write-Progress -Activity "Getting OS Privileges information ($strComputer)" -status "Running..." -id 1   
        Run-WmiRemoteProcess $computername 'secedit.exe /export /cfg c:\secdump.txt' | Wait-Process
        Start-Sleep -Seconds 3  # wait for file to be created

        [string]$strScriptPath = Split-Path $MyInvocation.MyCommand.Pathwhoami
        $file = ($strScriptPath + "secdump.txt")
        try {

        $fileTocopy = "\\$computername\c$\secdump.txt"

        Copy-Item $fileTocopy $file
        }
        catch{
            $_.Exception
        }

        $dumpResult = Parse-SecdumpFileToObject $file
        Start-Sleep -Seconds 1

        Remove-Item \\$computername\c$\secdump.txt
        Remove-Item $file

        # convert the dump to XML to a test file
        $XMLDump = $dumpResult | ConvertTo-XML -NoTypeInformation
        # Save Dump Data in the Output File
        $XMLDump.Save("secdump.xml")

        $xmlPath = "$scriptPath\logging\secdump.xml"
        $nodes = ""
        $nodes = Select-Xml -Path $xmlPath -XPath "//Property" | Select-Object -ExpandProperty Node

        $arrayPrivilege = @{}

        $nbNode = 0
        $nodes | ForEach-Object {
            $name = ""
            $name = $_.Name   
            if($name -eq "name") {
                $privilegeName = $_ | Select '#text'
                $privilegeName = $privilegeName.'#text'
            }
            if($name -eq "members") {
                $members = $_ | Select 'Property'        
                $members = $members.property
                $arrayPrivilege.Add($privilegeName, $members) 
            }    
         
            $nbNode++
        }
        
        foreach($privilege in $arrayPrivilege.keys) {
            $strategy = $privilege
            $securityParameters = $arrayPrivilege.item($privilege)        
            $OSPrivilegeQueryInsert = "INSERT INTO OSPrivilegeAudited (serverID,strategy,securityParameter) VALUES ('$nbServer','$strategy','$securityParameters')"              
            Insert-IntoDatabase $sqlCommand $OSPrivilegeQueryInsert
            Log-Write -LogPath $sLogFile -LineValue "$localUsersQueryInsert"
        }

        $nbSuccess++           
    }
    else {

        Log-Write -LogPath $sLogFile -LineValue "WMI connection to $strComputer failed`n"
        

        $serversNotResponding += "$strComputer `r`n"
        $nbError++
    }
}
$sqlConnection.Close()

$printErrorEncountered = ""

if($nbError -gt 0) {
    $printErrorEncountered = "`r`n The script encountered $nbError error `r`n $serversNotResponding"       
}

Log-Write -LogPath $sLogFile -LineValue "`r`n****************************************************** $printErrorEncountered `r`n $nbSuccess / $nbTot server(s) answer WMI requests `r`n $nbError / $nbTot server(s) NOT answer WMI requests `r`n ****************************************************** `n "

Log-Write -LogPath $sLogFile -LineValue "Database connection closed"



Log-Finish -LogPath $sLogFile