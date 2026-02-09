# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
Describe "Int128 and UInt128 arithmetic overflow promotes to Double" -Tag "CI" {

    Context "Int128 overflow promotes to Double" {
        It "Int128 addition overflow should promote to Double" {
            $result = [Int128]::MaxValue + [Int128]::MaxValue
            $result | Should -BeOfType [double]
        }

        It "Int128 subtraction underflow should promote to Double" {
            $result = [Int128]::MinValue - [Int128]::MaxValue
            $result | Should -BeOfType [double]
        }

        It "Int128 multiplication overflow should promote to Double" {
            $result = [Int128]::MaxValue * 2
            $result | Should -BeOfType [double]
        }
    }

    Context "UInt128 overflow promotes to Double" {
        It "UInt128 addition overflow should promote to Double" {
            $result = [UInt128]::MaxValue + [UInt128]::MaxValue
            $result | Should -BeOfType [double]
        }

        It "UInt128 subtraction underflow should promote to Double" {
            $result = [UInt128]0 - [UInt128]1
            $result | Should -BeOfType [double]
        }

        It "UInt128 multiplication overflow should promote to Double" {
            $result = [UInt128]::MaxValue * 2
            $result | Should -BeOfType [double]
        }
    }

    Context "Int128 non-overflow stays as Int128" {
        It "Int128 addition without overflow should stay as Int128" {
            $result = [Int128]5 + [Int128]3
            $result | Should -BeOfType [Int128]
            $result | Should -Be 8
        }

        It "Int128 subtraction without underflow should stay as Int128" {
            $result = [Int128]5 - [Int128]3
            $result | Should -BeOfType [Int128]
            $result | Should -Be 2
        }

        It "Int128 multiplication without overflow should stay as Int128" {
            $result = [Int128]5 * [Int128]3
            $result | Should -BeOfType [Int128]
            $result | Should -Be 15
        }

        It "Int128 remainder should stay as Int128" {
            $result = [Int128]5 % [Int128]3
            $result | Should -BeOfType [Int128]
            $result | Should -Be 2
        }

        It "Int128 exact division should stay as Int128" {
            $result = [Int128]10 / [Int128]2
            $result | Should -BeOfType [Int128]
            $result | Should -Be 5
        }

        It "Int128 non-exact division should promote to Double" {
            $result = [Int128]10 / [Int128]3
            $result | Should -BeOfType [double]
        }
    }

    Context "UInt128 non-overflow stays as UInt128" {
        It "UInt128 addition without overflow should stay as UInt128" {
            $result = [UInt128]5 + [UInt128]3
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 8
        }

        It "UInt128 subtraction without underflow should stay as UInt128" {
            $result = [UInt128]5 - [UInt128]3
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 2
        }

        It "UInt128 multiplication without overflow should stay as UInt128" {
            $result = [UInt128]5 * [UInt128]3
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 15
        }

        It "UInt128 remainder should stay as UInt128" {
            $result = [UInt128]5 % [UInt128]3
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 2
        }

        It "UInt128 exact division should stay as UInt128" {
            $result = [UInt128]10 / [UInt128]2
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 5
        }

        It "UInt128 non-exact division should promote to Double" {
            $result = [UInt128]10 / [UInt128]3
            $result | Should -BeOfType [double]
        }
    }

    Context "Int128 edge cases" {
        It "Int128 divide by zero should throw" {
            { [Int128]5 / [Int128]0 } | Should -Throw
        }

        It "Int128 remainder by zero should throw" {
            { [Int128]5 % [Int128]0 } | Should -Throw
        }

        It "Int128 MinValue / -1 should promote to Double" {
            $result = [Int128]::MinValue / ([Int128](-1))
            $result | Should -BeOfType [double]
        }

        It "Int128 MinValue % -1 should return zero" {
            $result = [Int128]::MinValue % ([Int128](-1))
            $result | Should -Be ([Int128]0)
        }
    }

    Context "UInt128 edge cases" {
        It "UInt128 divide by zero should throw" {
            { [UInt128]5 / [UInt128]0 } | Should -Throw
        }

        It "UInt128 remainder by zero should throw" {
            { [UInt128]5 % [UInt128]0 } | Should -Throw
        }
    }

    Context "Int128 comparison operators" {
        It "Int128 -eq should work" {
            [Int128]5 -eq [Int128]5 | Should -BeTrue
            [Int128]5 -eq [Int128]3 | Should -BeFalse
        }

        It "Int128 -ne should work" {
            [Int128]5 -ne [Int128]3 | Should -BeTrue
            [Int128]5 -ne [Int128]5 | Should -BeFalse
        }

        It "Int128 -lt should work" {
            [Int128]3 -lt [Int128]5 | Should -BeTrue
            [Int128]5 -lt [Int128]3 | Should -BeFalse
        }

        It "Int128 -le should work" {
            [Int128]3 -le [Int128]5 | Should -BeTrue
            [Int128]5 -le [Int128]5 | Should -BeTrue
            [Int128]5 -le [Int128]3 | Should -BeFalse
        }

        It "Int128 -gt should work" {
            [Int128]5 -gt [Int128]3 | Should -BeTrue
            [Int128]3 -gt [Int128]5 | Should -BeFalse
        }

        It "Int128 -ge should work" {
            [Int128]5 -ge [Int128]3 | Should -BeTrue
            [Int128]5 -ge [Int128]5 | Should -BeTrue
            [Int128]3 -ge [Int128]5 | Should -BeFalse
        }
    }

    Context "Int64 overflow still works correctly" {
        It "Int64 addition overflow should promote to Double" {
            $result = [Int64]::MaxValue + [Int64]::MaxValue
            $result | Should -BeOfType [double]
        }
    }
}
