[CmdletBinding()]
param(
[Parameter(Mandatory=$true)]
[string] $workDir,

[Parameter(Mandatory=$true)][ValidateSet("true", "false")]
[string]$isHotfix,

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
$jiraIssueSet = New-Object 'System.Collections.Generic.HashSet[String]'

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

Import-Module JiraPS
Set-JiraConfigServer $jiraUrl
$jiraCred = New-Object System.Management.Automation.PSCredential ($jiraUser, $jiraPassword)
New-JiraSession -Credential $jiraCred

exit 0
