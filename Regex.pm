package POSIX::Regex;

use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;
use base 'Exporter';

our %EXPORT_TAGS = ( all => [qw(
    REG_EXTENDED
    REG_ICASE REG_NEWLINE
    REG_NOTBOL REG_NOTEOL
)]);

our @EXPORT_OK = ( @{$EXPORT_TAGS{all}} );
our @EXPORT = qw();

our $VERSION = '0.90.6';

# AUTOLOAD {{{
sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&POSIX::Regex::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}
# }}}

require XSLoader;
XSLoader::load('POSIX::Regex', $VERSION);

sub new {
    my $class = shift;
    my $this  = bless {}, $class;
       $this->{rt} = shift || "";

    my $opts = 0;
       $opts |= $_ for @_;

    $this->regcomp($this->{rt}, $opts);

    return $this;
}

sub match {
    my $this = shift;
    my $str  = shift;

    my $opts = 0;
       $opts |= $_ for @_;

    return @{$this->regexec_wa( $str, $opts )} if wantarray;
    return $this->regexec( $str, $opts );
}

sub DESTROY { my $this = shift; $this->cleanup_memory; }

1;

__END__

=head1 NAME

POSIX::Regex - OO interface for the gnu regex engine

=head1 SYNOPSIS

    use POSIX::Regex qw(:all);

    my $reg = new POSIX::Regex('a\(a\|b\)\(c\)');

    print "You win a toy!\n" if $reg->match("aac");

    if( my @m = $reg->match("abc") ) { # returns the matches
        print "entire match: ", shift @m, "\n";
        print "\tgroup match: $_\n" for @m;

    } else {
        print "No toy for you!\n";
    }

=head1 REGULAR OPTIONS

(All of the following text was plagarized without edit from 'man 3 regex'.)

If you choose to import :all then you will have the following regular options
that you may optionally pass to new() (aka regcomp).

=head2 REG_ICASE

Do  not differentiate case.  Subsequent regexec() searches using this pattern
buffer will be case insen- sitive.

=head2 REG_EXTENDED

Use POSIX Extended Regular Expression syntax when interpreting regex.  If not
set, POSIX  Basic  Regular Expression syntax is used.

=head2 REG_NEWLINE

Match-any-character operators don't match a newline.

A non-matching list ([^...])  not containing a newline does not match a newline.

Match-beginning-of-line operator (^) matches the empty string immediately after
a newline, regardless of whether eflags, the execution flags of regexec(),
contains REG_NOTBOL.

Match-end-of-line operator ($) matches the empty string immediately  before  a
newline,  regardless  of whether eflags contains REG_NOTEOL.

=head2 REG_NOTBOL

The match-beginning-of-line operator always fails to match  (but see  the
compilation  flag  REG_NEWLINE above) This flag may be used when different
portions of a string are passed to regexec() and the beginning of the string
should not be interpreted as the beginning of the line.

=head2 REG_NOTEOL

=head1 AUTHOR

Jettero Heller <japh@voltar-confed.org>

Jet is using this software in his own projects...  If you find bugs, please
please please let him know. :) Actually, let him know if you find it handy at
all.  Half the fun of releasing this stuff is knowing that people use it.

Additionally, he is aware that the documentation sucks.  Should you email him
for help, he will most likely try to give it.

=head1 COPYRIGHT

GPL! (and/or whatever license the gnu regex engine is under)

Though, additionally, I will say that I'll be tickled if you were to include
this package in any commercial endeavor.  Also, any thoughts to the effect that
using this module will somehow make your commercial package GPL should be washed
away.

I hereby release you from any such silly conditions -- if possible while still
matching the license from gnu regex.

This package and any modifications you make to it must remain GPL.  Any programs
you (or your company) write shall remain yours (and under whatever copyright you
choose) even if you use this package's intended and/or exported interfaces in
them.

(again, if possible)

=head1 SEE ALSO

perl(1), man 3 regex

=cut
