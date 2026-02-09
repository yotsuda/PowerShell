# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
Describe "Using delimiters with Export-CSV and Import-CSV behave correctly" -tags "Feature" {
    BeforeAll {
        # note, we will not use "," as that's the default for CSV
        $delimiters = "/", " ", "@", "#", "$", "\", "&", "(", ")",
              "{", "}", "|", "<", ">", ";", "'",
              '"', "~", "!", "%", "^", "*", "_", "+", ":",
              "?", "-", "=", "[", "]", "."
        $defaultDelimiter = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ListSeparator
        # With CORECLR the CurrentCulture.TextInfo.ListSeparator is not writable, so
        # we need to use an entirely new CultureInfo which we can modify
        $enCulture = [System.Globalization.CultureInfo]::new("en-us")
        $d = Get-Date
        $testCases = @(
            foreach($del in $delimiters)
            {
                @{ Delimiter = $del; Data = $d; ExpectedResult = $d.Ticks }
            }
            )
        function Set-delimiter {
            param ( $delimiter )
            if ( $IsCoreCLR ) {
                $enCulture.TextInfo.ListSeparator = $delimiter
                [System.Globalization.CultureInfo]::CurrentCulture = $enCulture
            }
            else {
                [System.Globalization.cultureInfo]::CurrentCulture.TextInfo.ListSeparator = $delimiter
            }
        }
    }
    AfterEach {
        if ( $IsCoreCLR ) {
            $enCulture.TextInfo.ListSeparator = $defaultDelimiter
            [System.Globalization.CultureInfo]::CurrentCulture = $enCulture
        }
        else {
            [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ListSeparator = $defaultDelimiter
        }
        Remove-Item -Force -ErrorAction silentlycontinue TESTDRIVE:/file.csv
    }

    It "Disallow use of null delimiter" {
        $d | Export-Csv TESTDRIVE:/file.csv
        { Import-Csv -Path TESTDRIVE:/file.csv -Delimiter $null } | Should -Throw "Delimiter"
    }

    It "Disallow use of delimiter with useCulture parameter" {
        $d | Export-Csv TESTDRIVE:/file.csv
        { Import-Csv -Path TESTDRIVE:/file.csv -UseCulture "," } | Should -Throw "','"
    }

    It "Imports the same properties as exported" {
        $a = [pscustomobject]@{ a = 1; b = 2; c = 3 }
        $a | Export-Csv TESTDRIVE:/file.csv
        $b = Import-Csv TESTDRIVE:/file.csv
        @($b.psobject.properties).count | Should -Be 3
        $b.a | Should -Be $a.a
        $b.b | Should -Be $a.b
        $b.c | Should -Be $a.c
    }

    # parameter generated tests
    It 'Delimiter <Delimiter> with CSV import will fail correctly when culture does not match' -TestCases $testCases {
        param ($delimiter, $Data, $ExpectedResult)
        set-Delimiter $delimiter
        $Data | Export-Csv TESTDRIVE:\File.csv -UseCulture
        $i = Import-Csv TESTDRIVE:\File.csv
        $i.Ticks | Should -Not -Be $ExpectedResult
    }

    It 'Delimiter <Delimiter> with CSV import will succeed when culture matches export' -TestCases $testCases {
        param ($delimiter, $Data, $ExpectedResult)
        set-Delimiter $delimiter
        $Data | Export-Csv TESTDRIVE:\File.csv -UseCulture
        $i = Import-Csv TESTDRIVE:\File.csv -UseCulture
        $i.Ticks | Should -Be $ExpectedResult
    }

    It 'Delimiter <Delimiter> with CSV import will succeed when delimiter is used explicitly' -TestCases $testCases {
        param ($delimiter, $Data, $ExpectedResult)
        $Data | Export-Csv TESTDRIVE:\File.csv -Delimiter $delimiter
        $i = Import-Csv TESTDRIVE:\File.csv -Delimiter $delimiter
        $i.Ticks | Should -Be $ExpectedResult
    }

    It 'ConvertTo-Csv -UseCulture:$false uses default comma delimiter' {
        set-Delimiter ";"
        $result = [pscustomobject]@{ H1 = 'V1'; H2 = 'V2' } | ConvertTo-Csv -UseCulture:$false
        $result[0] | Should -Be '"H1","H2"'
        $result[1] | Should -Be '"V1","V2"'
    }

    It 'Export-Csv -UseCulture:$false uses default comma delimiter' {
        set-Delimiter ";"
        [pscustomobject]@{ H1 = 'V1'; H2 = 'V2' } | Export-Csv TESTDRIVE:/file.csv -UseCulture:$false
        $content = Get-Content TESTDRIVE:/file.csv
        $content[0] | Should -Be '"H1","H2"'
        $content[1] | Should -Be '"V1","V2"'
    }

    It 'Import-Csv -UseCulture:$false uses default comma delimiter' {
        "H1,H2`nV1,V2" | Set-Content TESTDRIVE:/file.csv
        $result = Import-Csv TESTDRIVE:/file.csv -UseCulture:$false
        $result.H1 | Should -Be 'V1'
        $result.H2 | Should -Be 'V2'
    }

    It 'ConvertFrom-Csv -UseCulture:$false uses default comma delimiter' {
        set-Delimiter ";"
        $result = "H1,H2`nV1,V2" | ConvertFrom-Csv -UseCulture:$false
        $result.H1 | Should -Be 'V1'
        $result.H2 | Should -Be 'V2'
    }
}
