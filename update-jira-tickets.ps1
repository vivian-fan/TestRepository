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

Write-Output "result matches :"
$result.Matches | Out-String | Write-Output
Write-Output "result matches count :"
$result.Matches.count | Out-String | Write-Output
Write-Output "result matches value :"
$result.Matches.Value | Out-String | Write-Output

if ($result.Matches.count -gt 0){
      
    Write-Output "Matches GT 0"   

    $jiraIssueSet = New-Object 'System.Collections.Generic.HashSet[String]'

    foreach($match in $result.Matches) {
         Write-Output "adding match : $match"
        [void] $jiraIssueSet.add(${$match.value})
    }
    
    Write-Output "jiraIssueSet : $jiraIssueSet"
    
    ## Setup Jira Session
    Install-Module JiraPS -Scope CurrentUser -Force -Confirm
    Set-JiraConfigServer $jiraUrl
    $jiraCred = New-Object System.Management.Automation.PSCredential ($jiraUser, $jiraPassword)
    New-JiraSession -Credential $jiraCred
    
    #Loop through set of JIRA issue numbers 
    foreach ($jiraIssue in $jiraIssueSet) {
        Write-Output "Processing : $jiraIssue"
    }
}




exit 0
