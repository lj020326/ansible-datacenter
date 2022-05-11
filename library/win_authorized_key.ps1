#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.Helper

#Requires -Version 2.0

$ErrorActionPreference = "Stop"

$result = @{ }

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$diff_mode = Get-AnsibleParam -obj $params -name "_ansible_diff" -type "bool" -default $false

$user = Get-AnsibleParam -obj $params -name "user" -type "str" -failifempty $true -resultobj $result
$key = Get-AnsibleParam -obj $params -name "key" -type "str" -failifempty $true -resultobj $result
$path = Get-AnsibleParam -obj $params -name "path" -type "path" -failifempty $false
$manage_dir = Get-AnsibleParam -obj $params -name "manage_dir" -type "bool" -failifempty $false -default $true
$state = Get-AnsibleParam -obj $params "state" -type "str" -default "present" -validateSet "present", "absent" -resultobj $result
$key_options = Get-AnsibleParam -obj $params -name "key_options" -type "str" -failifempty $false
$exclusive = Get-AnsibleParam -obj $params -name "exclusive" -type "bool" -failifempty $false -default $false
$comment = Get-AnsibleParam -obj $params -name "comment" -type "str" -failifempty $false
$validate_certs = Get-AnsibleParam -obj $params -name "validate_certs" -type "bool" -failifempty $false -default $true
$follow = Get-AnsibleParam -obj $params -name "follow" -type "bool" -failifempty $false -default $false

$set_args = @{
    key         = $key
    user        = $user
    ErrorAction = "Stop"
    check_mode  = $check_mode
    diff_mode   = $diff_mode
}

if ($null -ne $path) {
    $set_args += @{ path = $path }
}

if ($null -ne $manage_dir) {
    $set_args += @{ manage_dir = $manage_dir }
}

if ($null -ne $state) {
    $set_args += @{ state = $state }
}

if ($null -ne $key_options) {
    $set_args += @{ key_options = $key_options }
}

if ($null -ne $exclusive) {
    $set_args += @{ exclusive = $exclusive }
}

if ($null -ne $comment) {
    $set_args += @{ comment = $comment }
}

if ($null -ne $validate_certs) {
    $set_args += @{ validate_certs = $validate_certs }
}

if ($null -ne $follow) {
    $set_args += @{ follow = $follow }
}

# Localized messages
data LocalizedData {
    # culture="en-US"
    ConvertFrom-StringData @'
    InvalidKeySpecified             = invalid key specified: {0}
    FailedToWriteToFile             = Failed to write to file {0}
    ErrorGettingKeyFrom             = Error getting key from: {0}
    ErrorImportOpenSSHUtils         = Failed to import OpenSSHUtils Module! Halting!
    UserMustExistCheckMode          = Either user must exist or you must provide full path to key file in check mode
    FailedToLookupUser              = Failed to lookup user {0}
'@
}



function Get-pwnam {
    param (
        $user
    )
    if ($user -Notmatch '(?<domain>\w+)\\(?<username>\w+)') {
        $user = "*\$user"
    }

    $UserProfiles = Get-CimInstance -Class Win32_UserProfile -Filter Special=FALSE

    $userProfile = $UserProfiles | ForEach-Object -Begin { $ErrorActionPreference = 'Stop' } {
        try {
            $sid = $_.SID
            $id = New-Object System.Security.Principal.SecurityIdentifier($sid)
            $translate = $id.Translate([System.Security.Principal.NTAccount]).Value
            if ($translate -like $user) { $PSItem }
        }
        catch {
            Write-Warning -Message "Failed to translate $sid! $_"
        }
    }

    return $userProfile
}

function keyfile {
    <#
    .DESCRIPTION
    Calculate name of authorized keys file, optionally creating the
    directories and file, properly setting permissions.

    :param str user: name of user in passwd file
    :param bool write: if True, write changes to authorized_keys file (creating directories if needed)
    :param str path: if not None, use provided path rather than default of '~user/.ssh/authorized_keys'
    :param bool manage_dir: if True, create and set ownership of the parent dir of the authorized_keys file
    :param bool follow: if True symlinks will be followed and not replaced
    :return: full path string to authorized_keys for use
    #>
    [OutputType([string])]
    param (
        $user,
        $write = $False,
        $path = $null,
        $manage_dir = $true,
        $follow = $false,
        $check_mode = $false
    )

    [string]$keysfile = ""

    if ($check_mode -and $path) {
        $keysfile = $path
        if ($follow) {
            $keysfile = [IO.Path]::GetFullPath($path)
        }
        return $keysfile
    }

    $user_entry = Get-pwnam -user $user

    if (($null -eq $user_entry) -and [string]::IsNullOrEmpty($path)) {
        if ($check_mode) {
            $result = @{ }
            Fail-Json -obj $result -Message ($LocalizedData.UserMustExistCheckMode);
        }
        $result = @{ }
        Fail-Json -obj $result -Message ($LocalizedData.FailedToLookupUser -f $user);
    }

    if ([string]::IsNullOrEmpty($path)) {
        $homedir = $user_entry.LocalPath
        $sshdir = Join-Path -Path $homedir -ChildPath ".ssh"
        $keysfile = Join-Path -Path $sshdir -ChildPath "authorized_keys"
    }
    else {
        $sshdir = Split-Path -Parent $path
        $keysfile = $path
    }

    if ($follow) {
        $keysfile = [IO.Path]::GetFullPath($keysfile)
    }

    if (-not $write -or $check_mode) {
        return $keysfile
    }

    if ($manage_dir) {
        if (-not (Test-Path -Path $sshdir)) {
            New-Item -Path $sshdir -ItemType Directory | Out-Null
        }
    }

    if (-not (Test-Path -Path $keysfile)) {
        $basedir = Split-Path -Parent $keysfile

        if (-not (Test-Path -Path $basedir)) {
            New-Item -Path $basedir -ItemType Directory | Out-Null
        }

        if (-not (Test-Path -Path $keysfile)) {
            $name = Split-Path -Leaf $keysfile
            $file = New-Item -Path $basedir -name $name -ItemType File -Value ""
            $keysfile = $file.FullName
        }
    }
    return $keysfile
}

function parseoptions {
    <#
    .DESCRIPTION
    reads a string containing ssh-key options
    and returns a dictionary of those options
    #>
    param (
        [string]
        $options
    )

    $options_dict = [ordered]@{ } # ordered dict
    if ($options) {
        # the following regex will split on commas while
        # ignoring those commas that fall within quotes
        $pattern = "((?:[^,`"']|`"[^`"]*`"|'[^']*')+)"

        if ($options -match $pattern) {
            $parts = $options | Select-String $pattern -AllMatches
            $parts | ForEach-Object {
                [string]$part = $_
                if ($part -match '=') {
                    $idx = $part.IndexOf('=')
                    [string]$key = $part.Substring(0, $idx)
                    [string]$value = $part.Substring($idx + 1)
                    $options_dict.$key = $value
                }
                elseif ($_ -ne ',') {
                    $options_dict.$part = $null
                }
            }
        }

    }
    return $options_dict
}

function parsekey {
    <#
    .DESCRIPTION
    parses a key, which may or may not contain a list
    of ssh-key options at the beginning
    rank indicates the keys original ordering, so that
    it can be written out in the same order.
    #>
    param (
        [string]
        $raw_key,
        [int]
        $rank = 0
    )

    $VALID_SSH2_KEY_TYPES = @(
        'ssh-ed25519',
        'ecdsa-sha2-nistp256',
        'ecdsa-sha2-nistp384',
        'ecdsa-sha2-nistp521',
        'ssh-dss',
        'ssh-rsa'
    )

    $options = $null   # connection options
    $key = $null   # encrypted key string
    $key_type = $null   # type of ssh key
    $type_index = $null   # index of keytype in key string|list

    # remove comment yaml escapes
    $raw_key = $raw_key -replace '\#', '#'

    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    $key_parts = $raw_key.split(' ', $option)

    if ($key_parts -and $key_parts[0] -eq '#') {
        # comment line, invalid line, etc.
        return @{
            key      = $raw_key
            key_type = 'skipped'
            options  = $null
            comment  = $null
            rank     = $rank
        }
    }

    for ($i = 0; $i -le $key_parts.Count; $i++) {
        if ($key_parts[$i] -in $VALID_SSH2_KEY_TYPES) {
            $type_index = $i
            $key_type = $key_parts[$i]
            break
        }
    }

    # check for options
    if ($null -eq $type_index) {
        return $null
    }
    elseif ($type_index -gt 0) {
        $options = $key_parts[0..($type_index - 1)] -join " "
    }

    # parse the options (if any)
    $options = parseoptions -options $options

    # get key after the type index
    $key = $key_parts[$type_index + 1]

    # set comment to everything after the key
    if ($key_parts.Count -gt $type_index + 1) {
        $comment = $key_parts[($type_index + 2)..($key_parts.Count - $type_index + 2)] -join " "
    }

    return @{
        key      = $key
        key_type = $key_type
        options  = $options
        comment  = $comment
        rank     = $rank
    }
}

function readfile {
    param (
        [string]
        $fileName
    )
    if (-not (Test-Path -path $fileName)) {
        return ""
    }
    try {
        return (Get-Content -Path $fileName -Raw)
    }
    catch {
        return ""
    }
}

function parsekeys {
    param (
        [string]
        $lines
    )

    $keys = [ordered]@{ }
    $rank_index = 0
    $all_lines = $lines.Split("`r`n|`r|`n") | Where-Object { -not [String]::IsNullOrWhiteSpace($_) }

    foreach ($line in $all_lines) {
        $key_data = parsekey -raw_key $line -rank $rank_index
        if ($key_data) {
            $keys.$($key_data.key) = $key_data
        }
        else {
            # for an invalid line, just set the line
            # dict key to the line so it will be re-output later
            $keys.$line = @{
                key      = $line
                key_type = 'skipped'
                options  = $null
                comment  = $null
                rank     = $rank_index
            }
        }
        $rank_index++
    }
    return $keys
}

function writefile {
    param (
        [string]
        $filePath,
        [string]
        $content
    )
    try {
        $content | out-file -FilePath $filePath -Encoding utf8
    }
    catch {
        $result = @{ }
        Fail-Json -obj $result -Message ($LocalizedData.FailedToWriteToFile -f $filePath);
    }

    $fullPath = (Resolve-Path $filePath).Path
    $profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    $profileItem = Get-ChildItem $profileListPath  -ErrorAction SilentlyContinue | Where-Object {
        $properties = Get-ItemProperty $_.pspath  -ErrorAction SilentlyContinue
        $userProfilePath = $null

        if ($properties) {
            $userProfilePath = $properties.ProfileImagePath
        }
        $userProfilePath = $userProfilePath.Replace("\", "\\")
        if ( $properties.PSChildName -notmatch '\.bak$') {
            $fullPath -match "^$userProfilePath\\[\\|\W|\w]+authorized_keys$"
        }
    }

    $OSBits = ([System.IntPtr]::Size * 8) #Get-ProcessorBits

    #On 64-bit, always favor 64-bit Program Files no matter what our execution is now (works back past XP / Server 2003)
    If ($env:ProgramFiles.contains('x86')) {
        $PF = $env:ProgramFiles.replace(' (x86)', '')
    }
    Else {
        $PF = $env:ProgramFiles
    }

    $OpenSSHPSUtilityScriptDir = "$PF\OpenSSH-Win$($OSBits)"

    $modulePath = "$OpenSSHPSUtilityScriptDir\OpenSSHUtils.psm1"
    if (Test-Path -Path $modulePath) {

        if ($(Get-Module).Name -contains "OpenSSHUtils") {
            Remove-Module OpenSSHUtils
        }
        Import-Module -Name $modulePath

        if ($(Get-Module).Name -notcontains "OpenSSHUtils") {
            $result = @{ }
            Fail-Json -obj $result -Message ($LocalizedData.ErrorImportOpenSSHUtils -f $key);
        }
    }

    if ($profileItem) {
        Repair-AuthorizedKeyPermission -FilePath $filePath -Confirm:$false | Out-Null
    }
    else {
        Repair-SshdHostKeyPermission -FilePath $filePath -Confirm:$false | Out-Null
    }
}

function serialize {
    [OutputType([string])]
    param (
        $keys
    )
    $lines = @()
    $new_keys = $keys.Values
    $ordered_new_keys = $new_keys | Sort-Object { $_.rank }

    # order the new_keys by their original ordering, via the rank item in the tuple
    foreach ($key in $ordered_new_keys) {
        try {

            $keyhash = $key.key
            $key_type = $key.key_type
            $options = $key.options
            $comment = $key.comment

            $option_str = ""
            if ($options.Count -gt 0) {
                $option_strings = @()
                foreach ($option in $options.GetEnumerator()) {
                    $option_key = $option.Name
                    $value = $option.Value
                    if ($value -eq [String]::IsNullOrWhiteSpace) {
                        $option_strings += $option_key
                    }
                    else {
                        $option_strings += ("{0}={1}" -f $option_key, $value)
                    }
                }
                $option_str = $option_strings -join ","
                $option_str += " "
            }

            # comment line or invalid line, just leave it
            if (-not $key_type) {
                $key_line = $key
            }

            if ($key_type -eq 'skipped') {
                $key_line = $key.key
            }
            else {
                $key_line = "{0}{1} {2} {3}`r`n" -f $option_str, $key_type, $keyhash, $comment
            }
        }
        catch {
            $key_line = $key
        }
        $lines += $key_line
    }
    return $lines -join ""
}

function enforce_state {
    <#
    .SYNOPSIS
    Adds or removes an SSH authorized key.
    .DESCRIPTION
    Adds or removes SSH authorized keys for particular user accounts.
    .PARAMETER user
    The username on the remote host whose authorized_keys file will be modified.
    .PARAMETER key
    The SSH public key(s), as a string or url
    .PARAMETER path
    Alternate path to the authorized_keys file. (default: $home/.ssh/authorized_keys)
    .PARAMETER manage_dir
    Whether this module should manage the directory of the authorized key file.
    .PARAMETER state
    Whether the given key (with the given key_options) should or should not be in the file.
    .PARAMETER key_options
    A string of ssh key options to be prepended to the key in the authorized_keys file.
    .PARAMETER exclusive
    Whether to remove all other non-specified keys from the authorized_keys file.
    .PARAMETER comment
    Change the comment on the public key.
    .PARAMETER follow
    Follow path symlink instead of replacing it.
    .PARAMETER validate_certs
    This only applies if using a https url as the source of the keys. If set to $false, the SSL certificates will not be validated.
    .PARAMETER diff_mode
    .PARAMETER check_mode
    #>
    param(
        [string]
        $user,
        [string]
        $key,
        [string]
        $path = '',
        [boolean]
        $manage_dir = $true,
        [string]
        $state = 'present',
        [string]
        $key_options = '',
        [boolean]
        $exclusive = $false,
        [string]
        $comment = '',
        [boolean]
        $follow = $false,
        [boolean]
        $validate_certs = $true,
        [boolean]
        $diff_mode = $false,
        [boolean]
        $check_mode = $false
    )

    $params = @{
        user        = $user
        key         = $key
        path        = $path
        manage_dir  = $manage_dir
        state       = $state
        key_options = $key_options
        exclusive   = $exclusive
        comment     = $comment
        follow      = $follow
        changed     = $false
    }

    if ($key.StartsWith("http", "CurrentCultureIgnoreCase")) {

        if ($validate_certs -eq $false) {
            Disable-ServerCertificateValidation
        }

        try {
            $resp = invoke-webrequest -method head -uri $key -UseBasicParsing
            $statusCode = $resp.statuscode
            if ($statusCode -ne 200) {
                $result = @{ }
                Fail-Json -obj $result -Message ($LocalizedData.ErrorGettingKeyFrom -f $key);
            }
            else {
                $wrq = (invoke-webrequest -uri $key -Method Get -UseBasicParsing)
                $content = $wrq.Content
                $encoding = $null
                # http://en.wikipedia.org/wiki/Mime_type
                # http://technet.microsoft.com/en-us/library/dd347719.aspx
                if ($wrq.Headers['Content-Type'] -eq "application/octet-stream") {
                    $encoding = [System.Text.Encoding]::ASCII
                    $key = $encoding.GetString($content)
                }
                else {
                    $key = $content
                }
            }
        }
        catch {
            $result = @{ }
            Fail-Json -obj $result -Message ($LocalizedData.ErrorGettingKeyFrom -f $key);
        }
    }

    # extract individual keys into an array, skipping blank lines and comments
    $new_keys = $key.Split("`r`n|`r|`n") | Where-Object { -not [String]::IsNullOrWhiteSpace($_) } | Where-Object { $_.Trim() -NotMatch '^#' }

    # check current state -- just get the filename, don't create file
    $do_write = $false
    $keyfile = keyfile -user $user -write $do_write -path $path -manage_dir $manage_dir
    $params.keyfile = $keyfile

    $existing_content = readfile -FileName $keyfile
    $existing_keys = parsekeys -lines $existing_content

    # Add a place holder for keys that should exist in the state=present and
    # exclusive=true case
    $keys_to_exist = @()

    # we will order any non exclusive new keys higher than all the existing keys,
    # resulting in the new keys being written to the key file after existing keys, but
    # in the order of new_keys
    $max_rank_of_existing_keys = $existing_keys.Count

    $rank_index = 0
    # Check our new keys, if any of them exist we'll continue.
    foreach ($new_key in $new_keys) {
        $parsed_new_key = parsekey -raw_key $new_key -rank $rank_index

        if (-not $parsed_new_key) {
            $result = @{ }
            Fail-Json -obj $result -Message ($LocalizedData.InvalidKeySpecified -f $new_key);
        }

        if (-not [string]::IsNullOrEmpty($key_options)) {
            $parsed_options = parseoptions -options $key_options
            # rank here is the rank in the provided new keys, which may be unrelated to rank in existing_keys
            $parsed_new_key.options = $parsed_options
        }

        if (-not [string]::IsNullOrEmpty($comment)) {
            $parsed_new_key.comment = $comment
        }

        $matched = $False
        $non_matching_keys = @()

        if ($existing_keys.Contains($parsed_new_key.key)) {
            # Then we check if everything (except the rank at index 4) matches, including
            # the key type and options. If not, we append this
            # existing key to the non-matching list
            # We only want it to match everything when the state
            # is present
            $existing_key = $existing_keys.$($parsed_new_key.key)

            $diff_options = Compare-Hashtable -Left $parsed_new_key.options -Right $existing_key.options | Where-Object { $_.Side -eq '=>' -or $_.Side -eq '<=' }

            if ($state -eq 'present' -and (($parsed_new_key.key_type -ne $existing_key.key_type) -or ($diff_options.Count -gt 0) -or ($parsed_new_key.comment -ne $existing_key.comment))) {
                $non_matching_keys += $existing_key
            }
            else {
                $matched = $true
            }
        }

        # handle idempotent state=present
        if ($state -eq 'present') {
            $keys_to_exist += $parsed_new_key.key
            if ($non_matching_keys.Count -gt 0) {
                foreach ($non_matching_key in $non_matching_keys) {
                    if (-not ($existing_keys.Contains($non_matching_key))) {
                        $existing_keys.Remove($non_matching_key)
                        $do_write = $true
                    }
                }
            }

            # new key that didn't exist before. Where should it go in the ordering?
            if (-not $matched) {
                # We want the new key to be after existing keys if not exclusive (rank > max_rank_of_existing_keys)
                $total_rank = $max_rank_of_existing_keys + $parsed_new_key.rank
                # replace existing key tuple with new parsed key with its total rank
                $existing_keys[$parsed_new_key.key] = @{
                    key      = $parsed_new_key.key
                    key_type = $parsed_new_key.key_type
                    options  = $parsed_new_key.options
                    comment  = $parsed_new_key.comment
                    rank     = $total_rank
                }
                $do_write = $true
            }
        }
        elseif ($state -eq 'absent') {
            if (-not $matched) {
                continue
            }
            $existing_keys.Remove($parsed_new_key.key)
            $do_write = $true
        }

        $rank_index++
    }

    #remove all other keys to honor exclusive
    # for 'exclusive', make sure keys are written in the order the new keys were
    if ($state -eq 'present' -and $exclusive) {
        $to_remove = Compare-Hashtable -Left $existing_keys -Right $keys_to_exist | Where-Object { $_.Side -eq '=>' } | Select-Object -Property lvalue
        foreach ($key in $to_remove) {
            $existing_keys.Remove($key)
            $do_write = $true
        }
    }

    if (-not $do_write) {
        if ((Get-FileEncoding -Path $keyfile) -ne 'UTF8') {
            $do_write = $true
        }
    }

    if ($do_write) {
        $filename = keyfile -user $user -write $do_write -path $path -manage_dir $manage_dir -follow $follow -check_mode $check_mode
        $new_content = serialize -keys $existing_keys

        $diff = $null

        if ($diff_mode) {
            $diff = @{
                before_header = $params.keyfile
                after_header  = $filename
                before        = $existing_content
                after         = $new_content
            }
            $params.diff = $diff
        }

        if ($check_mode) {
            $result = @{
                changed = $true
                diff    = $diff
            }
            Exit-Json -obj $result
        }

        writefile -filePath $filename -content $new_content
        $params.changed = $true
    }
    else {
        if ($check_mode) {
            $result = @{
                changed = $false
            }
            Exit-Json -obj $result
        }
    }

    return $params
}

$result = enforce_state @set_args

Exit-Json -obj $result
