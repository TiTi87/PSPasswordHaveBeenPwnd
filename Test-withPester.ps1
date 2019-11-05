#requires -module pester

Invoke-Pester -OutputFile "./Result-Pester.XML" -OutputFormat NUnitXML -CodeCoverage './Test-IsThisPasswordHaveBeenPwnd.ps1'
