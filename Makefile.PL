use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'POSIX::Regex',
    VERSION_FROM      => 'Regex.pm',
    AUTHOR            => 'Paul Miller <jettero@cpan.org>',
);

my @names = (qw(
    REG_EXTENDED
    REG_ICASE REG_NEWLINE
    REG_NOTBOL REG_NOTEOL
));

use ExtUtils::Constant;
ExtUtils::Constant::WriteConstants(
    NAME         => 'POSIX::Regex',
    NAMES        => \@names,
    DEFAULT_TYPE => 'IV',
    C_FILE       => 'const-c.inc',
    XS_FILE      => 'const-xs.inc',
);
