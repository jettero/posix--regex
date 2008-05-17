# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 02_simple_matching.t,v 1.1 2006/08/18 19:50:18 jettero Exp $

use strict;
use Test;

plan tests => 5;

use POSIX::Regex;

my $r1 = new POSIX::Regex('cd');

ok( scalar $r1->match("abcd"), 1 );
ok( scalar $r1->match("dcba"), 0 );

# NOTE: BSD doesn't have \| on "obsolete" basic REs for some reason
my $r2 = new POSIX::Regex($^O =~ m/bsd/i ? 'a\([ab]\)c' : 'a\(a\|b\)c');

ok( scalar $r2->match("aac"), 1 );
ok( scalar $r2->match("abc"), 1 );
ok( scalar $r2->match("azc"), 0 );
