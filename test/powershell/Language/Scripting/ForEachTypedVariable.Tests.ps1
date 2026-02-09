# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
Describe "ForEach loop with typed variables" -Tags "CI" {
    It "foreach with typed variable should shadow outer variable" {
        [int]$x = 1
        $results = @()
        foreach ([int]$x in 1..3) {
            $results += $x
        }
        $results | Should -Be @(1, 2, 3)
        $x | Should -Be 1
    }

    It "foreach with typed variable should work when outer variable doesn't exist" {
        $results = @()
        foreach ([int]$y in 1..3) {
            $results += $y
        }
        $results | Should -Be @(1, 2, 3)
    }

    It "foreach with typed variable should work with different types" {
        [string]$s = "outer"
        $results = @()
        foreach ([string]$s in @("a", "b", "c")) {
            $results += $s
        }
        $results | Should -Be @("a", "b", "c")
        $s | Should -Be "outer"
    }

    It "foreach with typed variable should convert values correctly" {
        [double]$d = 1.5
        $results = @()
        foreach ([double]$d in @(1, 2, 3)) {
            $results += $d
        }
        $results | Should -Be @(1.0, 2.0, 3.0)
        $d | Should -Be 1.5
    }

    It "foreach without type constraint should still work normally" {
        [int]$z = 10
        $results = @()
        foreach ($z in 1..3) {
            $results += $z
        }
        $results | Should -Be @(1, 2, 3)
        $z | Should -Be 10
    }

    It "nested foreach with typed variables should work" {
        [int]$i = 100
        [int]$j = 200
        $results = @()
        foreach ([int]$i in 1..2) {
            foreach ([int]$j in 10..11) {
                $results += "$i-$j"
            }
        }
        $results | Should -Be @("1-10", "1-11", "2-10", "2-11")
        $i | Should -Be 100
        $j | Should -Be 200
    }
}
