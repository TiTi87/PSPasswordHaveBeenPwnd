#requires -module pester

Invoke-Pester -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru -Script Test-IsThisPasswordHaveBeenPwnd
