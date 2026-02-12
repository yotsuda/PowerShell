# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe "Int128 and UInt128 Arithmetic Overflow Tests" -Tags "CI" {
    Context "Int128 overflow promotion to Double" {
        It "Int128 addition overflow promotes to Double" {
            $result = [Int128]::MaxValue + [Int128]::MaxValue
            $result | Should -BeOfType [Double]
            # Verify it's approximately twice the max value
            $result | Should -BeGreaterThan 3.4e38
        }

        It "Int128 subtraction underflow promotes to Double" {
            $result = [Int128]::MinValue - [Int128]::MaxValue
            $result | Should -BeOfType [Double]
            # Verify it's a large negative number
            $result | Should -BeLessThan -3.4e38
        }

        It "Int128 multiplication overflow (Int128 * Int128) promotes to Double" {
            $result = [Int128]::MaxValue * [Int128]2
            $result | Should -BeOfType [Double]
            # Verify it's approximately twice the max value
            $result | Should -BeGreaterThan 3.4e38
        }

        It "Int128 multiplication overflow (Int128 * Int32) promotes to Double" {
            $result = [Int128]::MaxValue * 2
            $result | Should -BeOfType [Double]
            # Verify it's approximately twice the max value
            $result | Should -BeGreaterThan 3.4e38
        }

        It "Int128 normal addition returns Int128" {
            $result = [Int128]::Parse('100') + [Int128]::Parse('200')
            $result | Should -BeOfType [Int128]
            $result | Should -Be 300
        }

        It "Int128 normal subtraction returns Int128" {
            $result = [Int128]::Parse('200') - [Int128]::Parse('100')
            $result | Should -BeOfType [Int128]
            $result | Should -Be 100
        }

        It "Int128 normal multiplication returns Int128" {
            $result = [Int128]::Parse('100') * [Int128]::Parse('2')
            $result | Should -BeOfType [Int128]
            $result | Should -Be 200
        }

        It "Int128 division with remainder promotes to Double" {
            $result = [Int128]::Parse('100') / [Int128]::Parse('3')
            $result | Should -BeOfType [Double]
            $result | Should -BeGreaterThan 33.0
            $result | Should -BeLessThan 34.0
        }

        It "Int128 exact division returns Int128" {
            $result = [Int128]::Parse('100') / [Int128]::Parse('10')
            $result | Should -BeOfType [Int128]
            $result | Should -Be 10
        }

        It "Int128 remainder returns Int128" {
            $result = [Int128]::Parse('100') % [Int128]::Parse('3')
            $result | Should -BeOfType [Int128]
            $result | Should -Be 1
        }

        It "Int128 MinValue / -1 promotes to Double" {
            $result = [Int128]::MinValue / [Int128](-1)
            $result | Should -BeOfType [Double]
        }
    }

    Context "UInt128 overflow promotion to Double" {
        It "UInt128 addition overflow promotes to Double" {
            $result = [UInt128]::MaxValue + [UInt128]::MaxValue
            $result | Should -BeOfType [Double]
            # Verify it's approximately twice the max value
            $result | Should -BeGreaterThan 6.8e38
        }

        It "UInt128 subtraction underflow promotes to Double" {
            $result = [UInt128]::MinValue - [UInt128]::MaxValue
            $result | Should -BeOfType [Double]
            $result | Should -BeLessThan 0
        }

        It "UInt128 multiplication overflow promotes to Double" {
            $result = [UInt128]::MaxValue * [UInt128]2
            $result | Should -BeOfType [Double]
            # Verify it's approximately twice the max value
            $result | Should -BeGreaterThan 6.8e38
        }

        It "UInt128 normal addition returns UInt128" {
            $result = [UInt128]::Parse('100') + [UInt128]::Parse('200')
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 300
        }

        It "UInt128 normal multiplication returns UInt128" {
            $result = [UInt128]::Parse('100') * [UInt128]::Parse('2')
            $result | Should -BeOfType [UInt128]
            $result | Should -Be 200
        }
    }

    Context "Int128 comparison operations" {
        It "Int128 greater than comparison works" {
            $result = [Int128]::Parse('100') -gt [Int128]::Parse('50')
            $result | Should -BeTrue
        }

        It "Int128 less than comparison works" {
            $result = [Int128]::Parse('50') -lt [Int128]::Parse('100')
            $result | Should -BeTrue
        }

        It "Int128 equality comparison works" {
            $result = [Int128]::Parse('100') -eq [Int128]::Parse('100')
            $result | Should -BeTrue
        }

        It "Int128 inequality comparison works" {
            $result = [Int128]::Parse('100') -ne [Int128]::Parse('50')
            $result | Should -BeTrue
        }
    }

    Context "Consistency with Int64 behavior" {
        It "Int128 overflow behavior matches Int64" {
            $int64Result = [Int64]::MaxValue + [Int64]::MaxValue
            $int128Result = [Int128]::MaxValue + [Int128]::MaxValue
            
            # Both should promote to Double
            $int64Result | Should -BeOfType [Double]
            $int128Result | Should -BeOfType [Double]
        }

        It "Int128 normal arithmetic behavior matches Int64" {
            $int64Result = [Int64]100 + [Int64]200
            $int128Result = [Int128]::Parse('100') + [Int128]::Parse('200')
            
            # Both should stay as their original types
            $int64Result | Should -BeOfType [Int64]
            $int128Result | Should -BeOfType [Int128]
        }
    }
}
