#Requires -Modules Pester
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


Describe "Test-IsThisPasswordHaveBeenPwnd" {
  Context "When Password is 'Passw0rd123456'" {
    Mock Invoke-RestMethod {
            return "00EA5B4A1F59DDC8296ED29F24BBFCD8F43:1
263AFCD372802C5BC5E71A0FC93B70A9828:1
26850297C3AF234196271AFA1DFF7D9BCDC:1
26B9743E72128CDE3370C992A86B49E011E:5
26D17F2E7CEC134698A864C43E5CFBD84ED:50
26F2ECA536A2752D509258781BE4FD08F6A:23
2722CE42DBE70685BBAC0EFADB5E76D98F2:2
276222744A017CFB757924F76814C3C5820:3
2772FF587C44A48B0850F192189EC1CD182:1
27CB1DA8A3EBE5D50F05128739BE0DF287F:49
280D579AB5A7974B27005623093FFEBBC69:5"
    }
    it "find that the password have been powned, at least 23 time" {
        Test-IsThisPasswordHaveBeenPwnd -Password 'Passw0rd123456' | should be $true
    }
  }
  Context "When Password is 'Correct Horse Battery Staple'" {
    Mock Invoke-RestMethod {
            return "1112E7514BC4A89C7F300675BC5D178122C:1
11F509408B11336BFDBEFE9686E1E7A3C7D:2
12235B5CADCB7712B3FEF972CE597A9C51E:1
123473FCCE58D358A16005E731783255FAA:2
137EECE2E17D54388DFB36537FE1DF894E0:1
1383F497EF7CA2164C6681A0D0578827D20:44
13A901CCD6B55903D58C6CC6B9348DEBF21:39
13F5B7D74DE3744F9DEA8C6E4224BD683B5:1
140F91FE3EADCD217647061D07BB15A776F:2"
    }
    it "find that the password have not been powned" {
        $ret = Test-IsThisPasswordHaveBeenPwnd -Password "Correct Horse Battery Staple"
        Assert-MockCalled Get-StringHash -Scope It -Time 1
        $ret | should be $false
    }
  }
}

