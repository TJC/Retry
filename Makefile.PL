#!/usr/bin/env perl
use inc::Module::Install;

name 'Retry';
all_from 'lib/Retry.pm';

requires 'Moose' => 1.01; # Probably fine with .92 onwards though.
build_requires 'Test::More' => 0.88;

WriteAll;
