Function Get-StringHash([String] $String, $HashName="MD5"){
<#
.SYNOPSIS 
    A simple script to hash a string using your chosen cryptography algorithm   
.EXAMPLES
    Get-StringHash "My String to  hash" "MD5"
    Get-StringHash "My String to hash" "RIPEMD160"
    Get-StringHash  "My String to hash" "SHA1"
    Get-StringHash "My String to hash" "SHA256" 
.SRC
    https://gallery.technet.microsoft.com/scriptcenter/Get-StringHash-aa843f71
    http:// jongurgul.com/blog/get-stringhash-get-filehash/ 
#>
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
    [Void]$StringBuilder.Append($_.ToString("x2"))
    } 
    $StringBuilder.ToString() 
}

Function Test-IsThisPasswordHaveBeenPwnd ([String] $Password) {
<#
.SYNOPSIS 
    A Quick Proof of concept in Powershell to use the "Pwned Passwords API" of haveibeenpwned.com and check for password compromise.
.EXAMPLES
    Test-IsThisPasswordHaveBeenPwnd "Password1234"
.SRC
    https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/#cloudflareprivacyandkanonymity
    https://haveibeenpwned.com/API/v2#PwnedPasswords
#> 
    $hash = Get-StringHash "$Password" "SHA1"

    $hash_prefix = $hash.substring(0,5)
    $matching_list = Invoke-RestMethod -Uri "https://api.pwnedpasswords.com/range/$hash_prefix"
    $matching_tab = $matching_list.Split("`n")

    foreach ($line in $matching_tab) {
        $h_suffix, $counter = $line.split(":")
        if($hash.toUpper() -eq ($hash_prefix+$h_suffix).toUpper()){
            Write-Host  "This Password Have Been Powned at least $counter time!!! Please, Change It..."
            return $true;
        }
            
    }
    Write-Host  "You're Password Seems Fine" 
    return $false; 
}
