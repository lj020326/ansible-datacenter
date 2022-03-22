Function Outer-Method { 
	Param ( [string] $First, [string] $Second ) 
	Write-Host ("Outet-Method $First") 
	Inner-Method @PSBoundParameters 
} 

Function Inner-Method { 
	Param ( [string] $Second ) 
	Write-Host ("Inner-Method {0}!" -f $Second) 
} 

function Test1 {
	param(
		[String[]] $ArgumentList
	)
	$app_params = "$ArgumentList"
	Write-Host ("Test1 {0}!" -f $app_params) 
}

Clear-Host 
$parameters = @{ First = "Hello"; Second = "World" } 
Outer-Method @parameters

$parameters2 = "Hello", "World"
Test1 $parameters2
