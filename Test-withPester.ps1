#requires -module pester

Invoke-Pester -OutputFile "./Result-Pester.XML" -OutputFormat NUnitXML './Test-IsThisPasswordHaveBeenPwnd.ps1'
