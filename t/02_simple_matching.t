# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 02_simple_matching.t,v 1.1 2006/08/18 19:50:18 jettero Exp $

use strict;
use Test;

plan tests => 3;

use POSIX::Regex;

my $r = new POSIX::Regex('a\(a\|b\)c');

ok( scalar $r->match("aac"), 1 );
ok( scalar $r->match("abc"), 1 );
ok( scalar $r->match("azc"), 0 );
