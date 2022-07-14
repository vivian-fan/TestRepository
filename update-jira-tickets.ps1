[CmdletBinding()]
param(
[Parameter(Mandatory=$true)]
[string] $workDir,

[Parameter(Mandatory=$true)]
[string] $jiraInstance,

[Parameter(Mandatory=$true)]
[string] $jiraUser,

[Parameter(Mandatory=$true)]
[string] $jiraPassword,

[Parameter(Mandatory=$true)][ValidateSet("true", "false")]
[string]$isHotfix,

[Parameter(Mandatory=$true)]
[string] $appTickets,

[Parameter(Mandatory=$true)]
[string] $dbTickets,

[Parameter(Mandatory=$true)]
[string] $wsTickets

)

#### "====Local environment variables start====" ####

$jiraSearchString = "$workDir + /settings.xml"

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

exit 0
