[CmdletBinding()]
param(

[Parameter(Mandatory=$true)][ValidateSet("true", "false")]
[string]$isHotfix,

[Parameter(Mandatory=$true)]
[string] $runNumber,

[Parameter(Mandatory=$true)]
[string] $appTickets,

[Parameter(Mandatory=$true)]
[string] $dbTickets,

[Parameter(Mandatory=$true)]
[string] $wsTickets

)

#### "====Local variables ====" ####

$jiraUrl = "$env:jiraUrl"
$jiraUser = "$env:jiraUser"
$jiraPassword = ConvertTo-SecureString "$env:jiraApiToken" -AsPlainText -Force

$jiraIssuesSearchString = $appTickets+$dbTickets+$wsTickets

## ============== Functions Start ============== ##

function isBuildFailure($result){
	$fail = $false
	$failString = "BUILD FAILURE"
	$successString = "BUILD SUCCESS"
	foreach ($line in $result) {
    	if ($line -match $failString) {
       		$fail = $true
       		break
      	}
      	else {
       		if ($line -match $successString) {
              	break
       		}
      	}
    }
    return $fail
}

## =========== Search for Jira Issues =========== ##

$jiraRegex = "[JEM-]+[0-9]{1,10}"

$result = $jiraIssuesSearchString | Select-String $jiraRegex -AllMatches

if ($result.Matches.count -gt 0){

    $jiraIssueSet = New-Object 'System.Collections.Generic.HashSet[String]'

    foreach($match in $result.Matches) {
        Write-Output "adding match : $match"
        [void] $jiraIssueSet.add($match)
    }
    
    Write-Output "jiraIssueSet : "
    Write-Output $jiraIssueSet
    
    ## Setup Jira Session
    Install-Module -Name JiraPS -Scope CurrentUser -Force -Verbose
    
    Set-JiraConfigServer $jiraUrl
    $jiraCred = New-Object System.Management.Automation.PSCredential ($jiraUser, $jiraPassword)
    New-JiraSession -Credential $jiraCred
    
    #Loop through set of JIRA issue numbers 
    foreach ($jiraIssue in $jiraIssueSet) {
        Write-Output "Processing $jiraIssue"
	
    }
    
    Write-Output "Processing TEST on JEM-14727"
    $ticket = "JEM-14727"
    Get-JiraIssue  $ticket | Add-JiraIssueComment "Test comment from Github Actions"
}




exit 0
