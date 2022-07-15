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
$jiraPassword = ConvertTo-SecureString "$env:jiraPassword" -AsPlainText -Force

$jiraIssuesSearchString = $appTickets+$dbTickets+$wsTickets

Write-Output "Jira Issue Search String : $jiraIssuesSearchString"

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

$result | Out-String | Write-Output
Write-Output "result matches : ${$result.matches}"
Write-Output "result matches count : ${$result.matches.count}"

if ($result.Matches.count > 0){


    $jiraIssueSet = New-Object 'System.Collections.Generic.HashSet[String]'

    foreach($group in $result.groups) {
        [void] $jiraIssueSet.add(${$group.value})
    }
    
    Write-Output "hjiraIssueSet : $jiraIssueSet"
    
    ## Setup Jira Session
    Import-Module JiraPS
    Set-JiraConfigServer $jiraUrl
    $jiraCred = New-Object System.Management.Automation.PSCredential ($jiraUser, $jiraPassword)
    New-JiraSession -Credential $jiraCred
    
    #Loop through set of JIRA issue numbers 
    foreach ($jiraIssue in $jiraIssueSet) {
        Write-Output "Processing : $jiraIssue"
    }
}




exit 0
