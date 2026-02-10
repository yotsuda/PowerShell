# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe "Foreach with typed variable" -Tags "CI" {
    
    Context "Basic typed variable in foreach" {
        It "Should accept [int] type constraint on foreach variable" {
            $result = @()
            foreach ([int]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @(1, 2, 3)
        }

        It "Should accept [string] type constraint on foreach variable" {
            $result = @()
            foreach ([string]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @('1', '2', '3')
        }

        It "Should accept [double] type constraint on foreach variable" {
            $result = @()
            foreach ([double]$x in 1, 2, 3) {
                $result += $x
            }
            $result | Should -Be @(1.0, 2.0, 3.0)
        }

        It "Should accept [object] type constraint on foreach variable" {
            $result = @()
            foreach ([object]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @(1, 2, 3)
        }
    }

    Context "Reusing variable name with type constraint" {
        It "Should allow reusing variable name that was declared before foreach" {
            [int]$x = 10
            $result = @()
            foreach ([int]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @(1, 2, 3)
            # Variable should retain the value from the last iteration
            $x | Should -Be 3
        }

        It "Should handle different types between declaration and foreach" {
            [int]$x = 10
            $result = @()
            foreach ([string]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @('1', '2', '3')
            # Variable should be converted to string type
            $x | Should -BeOfType [string]
            $x | Should -Be '3'
        }

        It "Should work when variable was used before without type constraint" {
            $x = 10
            $result = @()
            foreach ([int]$x in 1..3) {
                $result += $x
            }
            $result | Should -Be @(1, 2, 3)
            $x | Should -Be 3
        }
    }

    Context "Type conversion in typed foreach" {
        It "Should convert string values to int when using [int] constraint" {
            $result = @()
            foreach ([int]$x in '1', '2', '3') {
                $result += $x
            }
            $result | Should -Be @(1, 2, 3)
            $result[0] | Should -BeOfType [int]
        }

        It "Should convert int values to string when using [string] constraint" {
            $result = @()
            foreach ([string]$x in 1, 2, 3) {
                $result += $x
            }
            $result | Should -Be @('1', '2', '3')
            $result[0] | Should -BeOfType [string]
        }

        It "Should handle conversion errors gracefully" {
            $result = @()
            try {
                foreach ([int]$x in 'a', 'b', 'c') {
                    $result += $x
                }
                throw "Should have thrown conversion error"
            } catch {
                $_.Exception.Message | Should -BeLike "*Cannot convert*"
            }
        }
    }

    Context "Complex scenarios" {
        It "Should work with nested foreach loops with typed variables" {
            $result = @()
            foreach ([int]$i in 1..2) {
                foreach ([string]$j in 'a', 'b') {
                    $result += "$i$j"
                }
            }
            $result | Should -Be @('1a', '1b', '2a', '2b')
        }

        It "Should work with foreach inside functions" {
            function Test-TypedForeach {
                param([array]$items)
                $result = @()
                foreach ([int]$x in $items) {
                    $result += $x * 2
                }
                return $result
            }
            $output = Test-TypedForeach -items 1, 2, 3
            $output | Should -Be @(2, 4, 6)
        }

        It "Should work with foreach in script blocks" {
            $sb = {
                param($items)
                $result = @()
                foreach ([string]$x in $items) {
                    $result += "Item: $x"
                }
                return $result
            }
            $output = & $sb 1, 2, 3
            $output | Should -Be @('Item: 1', 'Item: 2', 'Item: 3')
        }

        It "Should work with custom types" {
            Add-Type -TypeDefinition @"
                public class TestItem {
                    public int Value { get; set; }
                    public TestItem(int value) { Value = value; }
                }
"@ -IgnoreWarnings
            
            $items = @(
                [TestItem]::new(1),
                [TestItem]::new(2),
                [TestItem]::new(3)
            )
            
            $result = @()
            foreach ([TestItem]$item in $items) {
                $result += $item.Value
            }
            $result | Should -Be @(1, 2, 3)
        }
    }

    Context "Edge cases" {
        It "Should work with empty collection" {
            $result = @()
            foreach ([int]$x in @()) {
                $result += $x
            }
            $result.Count | Should -Be 0
        }

        It "Should work with single item" {
            $result = @()
            foreach ([int]$x in 42) {
                $result += $x
            }
            $result | Should -Be @(42)
        }

        It "Should work with $null value" {
            $result = @()
            foreach ([int]$x in $null) {
                $result += $x
            }
            $result.Count | Should -Be 0
        }

        It "Should work with pipeline input to collection" {
            $result = @()
            foreach ([int]$x in (1..3 | ForEach-Object { $_ * 2 })) {
                $result += $x
            }
            $result | Should -Be @(2, 4, 6)
        }
    }

    Context "Variable scope" {
        It "Should preserve foreach variable in outer scope after loop" {
            foreach ([int]$x in 1..3) {
                # Loop body
            }
            $x | Should -Be 3
        }

        It "Should not affect same-named variable in different scope" {
            $x = "outer"
            & {
                foreach ([int]$x in 1..3) {
                    # Loop body
                }
                $x | Should -Be 3
            }
            $x | Should -Be "outer"
        }
    }
}
