#!/bin/sh
#\
exec tclsh "$0" "$@"

if {$argc == 0} {
    set cmd [file tail [info script]]
    puts "Usage:"
    puts "    $cmd <FORMAT> <EXPR1> <EXPR2> ..."
    puts "    $cmd <FORMAT1> <EXPR1> <FORMAT2> <EXPR2> ..."
    puts "    $cmd <FORMAT> <EXPR1> <FORMAT2> - <FORMAT3> - ..."
    puts ""
    puts "FORMAT:"
    puts "    -h     print in hex"
    puts "    -d     print in decimal"
    puts "    -b     print in binary"
    puts "    -bb    print in binary (with bit number)"
    puts ""
    puts "EXPR"
    puts "    For format of expression see \"expr\" command in "
    puts "    Tcl language documentation. See also \"man n mathfunc\"."
    puts ""
    puts "Examples:"
    puts "    $cmd -d  '0.34 * 5 + 0b1010'"
    puts "    $cmd -h  '((0b11111010 ^ 0b0101) | (0xff << 8)) & (~0x01)'"
    puts "    $cmd -bb 0x348"
    puts "    $cmd -b  '65535 / 2'"
    puts "    $cmd -h  '(345 - 4) / 2 - 1 + 0x20'"
    puts "    $cmd -d  'sqrt(abs(-36))'"
    puts "    $cmd -d  '4e-9 * 2e3 * 3.14 / 2'"
    puts "    $cmd -d  0x800 -b - -bb -"
    puts ""
    exit 0
}

set format hex

proc 2bin {st} {
    foreach char [split $st {}] {
        switch $char {
            "0" {append ret 0000}
            "1" {append ret 0001}
            "2" {append ret 0010}
            "3" {append ret 0011}
            "4" {append ret 0100}
            "5" {append ret 0101}
            "6" {append ret 0110}
            "7" {append ret 0111}
            "8" {append ret 1000}
            "9" {append ret 1001}
            "a" {append ret 1010}
            "b" {append ret 1011}
            "c" {append ret 1100}
            "d" {append ret 1101}
            "e" {append ret 1110}
            "f" {append ret 1111}
            default {append ret ####}
        }
        append ret .
    }

    set ret [string trimright $ret .]
    return $ret
}

proc 2bine {st} {
    set bits [expr {[string length $st] * 4}]

    set n 0


    foreach char [split $st {}] {
        for {set i 0} {$i < 4} {incr i} {
            set num [format %02u [incr bits -1]]
            if {([incr n] % 2) == 0} {
                append head \x1b\[32m
            } else {
                append head \x1b\[0m
            }
            append head $num
        }

        switch $char {
            "0" {append ret { 0 0 0 0}}
            "1" {append ret { 0 0 0 1}}
            "2" {append ret { 0 0 1 0}}
            "3" {append ret { 0 0 1 1}}
            "4" {append ret { 0 1 0 0}}
            "5" {append ret { 0 1 0 1}}
            "6" {append ret { 0 1 1 0}}
            "7" {append ret { 0 1 1 1}}
            "8" {append ret { 1 0 0 0}}
            "9" {append ret { 1 0 0 1}}
            "a" {append ret { 1 0 1 0}}
            "b" {append ret { 1 0 1 1}}
            "c" {append ret { 1 1 0 0}}
            "d" {append ret { 1 1 0 1}}
            "e" {append ret { 1 1 1 0}}
            "f" {append ret { 1 1 1 1}}
            default {append ret ####}
        }
        append head \x1b\[36m.\x1b\[0m
        append ret  \x1b\[36m.\x1b\[0m
    }

    append head \x1b\[0m
    set ret [string trimright $ret .]

    puts $head
    puts $ret
}

proc calc {arg format} {
    switch $format {
        dec {
            puts "[expr $arg] D"
        }
        hex {
            puts "[format %08x [expr $arg]] H"
        }
        bin {
            puts "[2bin [format %x [expr [string tolower $arg]]]] B"
        }
        bine {
            2bine [format %x [expr $arg]]
        }
        default {
            puts "unknown format \"$arg\""
        }
    }
}

if {$argc > 0} {
    foreach arg $argv {
        switch -glob $arg {
            {-d} {
                set format dec
            }
            {-h} {
                set format hex
            }
            {-b} {
                set format bin
            }
            {-bb} {
                set format bine
            }
            default {
                if {$arg eq "-"} {
                    if {[catch {
                        calc $lexp $format
                    } result]} {
                        puts $result
                    }
                } else {
                    if {[catch {
                        calc $arg $format
                        set lexp $arg
                    } result]} {
                        puts $result
                    }
                }
            }
        }
    }
}


