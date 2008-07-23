
use Module::Build;
my $build = Module::Build->new(
    module_name       => 'POSIX::Regex',
    dist_version_from => "Regex.pm",
    license           => 'lgpl',
     pm_files         => { 'Regex.pm'  => 'lib/POSIX/Regex.pm'  },
    pod_files         => { 'Regex.pod' => 'lib/POSIX/Regex.pod' },
     xs_files         => { 'Regex.xs'  => 'lib/POSIX/Regex.xs'  },
    requires          => { version => 0, },
    build_requires    => { "ExtUtils::Constant" => 0, 'ExtUtils::CBuilder' => 0, },
);
$build->create_build_script;

my @names = (qw(
    REG_EXTENDED
    REG_ICASE REG_NEWLINE
    REG_NOTBOL REG_NOTEOL
));

eval 'use ExtUtils::Constant';
if( not $@ ) {
    ExtUtils::Constant::WriteConstants(
        NAME         => 'POSIX::Regex',
        NAMES        => \@names,
        DEFAULT_TYPE => 'IV',
        C_FILE       => 'lib/POSIX/const-c.inc',
        XS_FILE      => 'lib/POSIX/const-xs.inc',
    );
}

