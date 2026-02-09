# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe "Arithmetic operator overflow behavior" -Tags "CI" {
    Context "Int32 overflow" {
        It "Int32 + Int32 overflow promotes to Double" {
            $result = [Int32]::MaxValue + [Int32]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([Int32]::MaxValue)
        }

        It "Int32 - Int32 underflow promotes to Double" {
            $result = [Int32]::MinValue - [Int32]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeLessThan ([Int32]::MinValue)
        }

        It "Int32 * Int32 overflow promotes to Double" {
            $result = [Int32]::MaxValue * 2
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([Int32]::MaxValue)
        }
    }

    Context "Int64 overflow" {
        It "Int64 + Int64 overflow promotes to Double" {
            $result = [Int64]::MaxValue + [Int64]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([Int64]::MaxValue)
        }

        It "Int64 - Int64 underflow promotes to Double" {
            $result = [Int64]::MinValue - [Int64]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeLessThan ([Int64]::MinValue)
        }

        It "Int64 * Int64 overflow promotes to Double" {
            $result = [Int64]::MaxValue * 2
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([Int64]::MaxValue)
        }
    }

    Context "UInt64 overflow" {
        It "UInt64 + UInt64 overflow promotes to Double" {
            $result = [UInt64]::MaxValue + [UInt64]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([UInt64]::MaxValue)
        }

        It "UInt64 * UInt64 overflow promotes to Double" {
            $result = [UInt64]::MaxValue * 2
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([UInt64]::MaxValue)
        }
    }

    Context "Int128 overflow" {
        It "Int128 + Int128 overflow promotes to Double" {
            $result = [Int128]::MaxValue + [Int128]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([double][Int128]::MaxValue)
        }

        It "Int128 - Int128 underflow promotes to Double" {
            $result = [Int128]::MinValue - [Int128]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeLessThan ([double][Int128]::MinValue)
        }

        It "Int128 * Int128 overflow promotes to Double" {
            $result = [Int128]::MaxValue * 2
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([double][Int128]::MaxValue)
        }

        It "Int128 arithmetic without overflow stays Int128" {
            $result = ([Int128]100) + ([Int128]200)
            $result.GetType().Name | Should -Be "Int128"
            $result | Should -Be 300
        }
    }

    Context "UInt128 overflow" {
        It "UInt128 + UInt128 overflow promotes to Double" {
            $result = [UInt128]::MaxValue + [UInt128]::MaxValue
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([double][UInt128]::MaxValue)
        }

        It "UInt128 - UInt128 underflow promotes to Double" {
            $result = [UInt128]::MinValue - [UInt128]1
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeLessThan ([double][UInt128]::MinValue)
        }

        It "UInt128 * UInt128 overflow promotes to Double" {
            $result = [UInt128]::MaxValue * 2
            $result.GetType().Name | Should -Be "Double"
            $result | Should -BeGreaterThan ([double][UInt128]::MaxValue)
        }

        It "UInt128 arithmetic without overflow stays UInt128" {
            $result = ([UInt128]100) + ([UInt128]200)
            $result.GetType().Name | Should -Be "UInt128"
            $result | Should -Be 300
        }
    }

    Context "Mixed Int128/UInt128 operations" {
        It "Int128 + UInt128 uses appropriate type" {
            $result = ([Int128]100) + ([UInt128]200)
            $result | Should -Be 300
        }

        It "UInt128 + Int128 uses appropriate type" {
            $result = ([UInt128]200) + ([Int128]100)
            $result | Should -Be 300
        }
    }
}
