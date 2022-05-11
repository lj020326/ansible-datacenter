Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
function Get-FileEncoding {
    <#
    .SYNOPSIS
    Gets file encoding.
    .DESCRIPTION
    The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
    Based on port of C# code from http://www.west-wind.com/Weblog/posts/197245.aspx
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'}
    This command gets ps1 files in current directory where encoding is not ASCII
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII}
    Same as previous example but fixes encoding using set-content
    .LINK
    https://blogs.technet.microsoft.com/samdrey/2014/03/26/determine-the-file-encoding-of-a-file-csv-file-with-french-accents-or-other-exotic-characters-that-youre-trying-to-import-in-powershell/
    #>

    [CmdletBinding()] 
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] 
        [string] $Path
    )
 
    [byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
 

    if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
    { Write-Output 'UTF8' }
    elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
    { Write-Output 'Unicode' }
    elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
    { Write-Output 'UTF32' }
    elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
    { Write-Output 'UTF7' }
    else
    { Write-Output 'ASCII' }
}

function Disable-ServerCertificateValidation {
    <#
    .SYNOPSIS
    Allow to establish trust relationship for the SSL/TLS Secure Channel when using Invoke-WebRequest.
    .DESCRIPTION
    It basically ignores certificate validate in PowerShell allowing you to make a connection with Invoke-WebRequest.  
    All you have to do it paste this code into your PowerShell session before you run Invoke-WebRequest against a server with a Self-Signed Certificate.
    .LINK
    https://blog.ukotic.net/2017/08/15/could-not-establish-trust-relationship-for-the-ssltls-invoke-webrequest/
    .LINK 
    https://github.com/MicrosoftDocs/PowerShell-Docs/issues/1753
    #>
    
    if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
        $certCallback = @"
        using System;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public class ServerCertificateValidationCallback
        {
            public static void Ignore()
            {
                if(ServicePointManager.ServerCertificateValidationCallback ==null)
                {
                    ServicePointManager.ServerCertificateValidationCallback += 
                        delegate
                        (
                            Object obj, 
                            X509Certificate certificate, 
                            X509Chain chain, 
                            SslPolicyErrors errors
                        )
                        {
                            return true;
                        };
                }
            }
        }
"@
        Add-Type $certCallback
    }
    [ServerCertificateValidationCallback]::Ignore()

    # Workaround for SelfSigned Cert an force TLS 1.2
    Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

function Compare-Hashtable {
    <#
    .SYNOPSIS
    Compare two Hashtable and returns an array of differences.
    .DESCRIPTION
    The Compare-Hashtable function computes differences between two Hashtables. Results are returned as
    an array of objects with the properties: "key" (the name of the key that caused a difference), 
    "side" (one of "<=", "!=" or "=>"), "lvalue" an "rvalue" (resp. the left and right value 
    associated with the key).
    .PARAMETER left 
    The left hand side Hashtable to compare.
    .PARAMETER right 
    The right hand side Hashtable to compare.
    .EXAMPLE
    Returns a difference for ("3 <="), c (3 "!=" 4) and e ("=>" 5).
    Compare-Hashtable @{ a = 1; b = 2; c = 3 } @{ b = 2; c = 4; e = 5}
    .EXAMPLE 
    Returns a difference for a ("3 <="), c (3 "!=" 4), e ("=>" 5) and g (6 "<=").
    $left = @{ a = 1; b = 2; c = 3; f = $Null; g = 6 }
    $right = @{ b = 2; c = 4; e = 5; f = $Null; g = $Null }
    Compare-Hashtable $left $right
    .LINK
    https://gist.github.com/dbroeglin/c6ce3e4639979fa250cf
    #>    	
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,
    
        [Parameter(Mandatory = $true)]
        [Hashtable]$Right		
    )
        
    function New-Result($Key, $LValue, $Side, $RValue) {
        New-Object -Type PSObject -Property @{
            key    = $Key
            lvalue = $LValue
            rvalue = $RValue
            side   = $Side
        }
    }
    [Object[]]$Results = $Left.Keys | ForEach-Object {
        if ($Left.ContainsKey($_) -and !$Right.ContainsKey($_)) {
            New-Result $_ $Left[$_] "<=" $Null
        }
        else {
            $LValue, $RValue = $Left[$_], $Right[$_]
            if ($LValue -ne $RValue) {
                New-Result $_ $LValue "!=" $RValue
            }
        }
    }
    $Results += $Right.Keys | ForEach-Object {
        if (!$Left.ContainsKey($_) -and $Right.ContainsKey($_)) {
            New-Result $_ $Null "=>" $Right[$_]
        } 
    }
    return $Results 
}

# this line must stay at the bottom to ensure all defined module parts are exported
Export-ModuleMember -Alias * -Function * -Cmdlet *