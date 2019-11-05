#requires -module pester

$testFile = './Test-IsThisPasswordHaveBeenPwnd.ps1'
Invoke-Pester -CodeCoverage $testFile -OutputFile "./Result-Pester.XML" -OutputFormat NUnitXML $testFile
