use strict;
use warnings;
use File::Temp qw/tempdir/;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use Plack::Util;
use Plack::Test;
use Cwd;
use Test::More;
use App::Prove;

&main; done_testing; exit;

sub main {
    my $old_cwd = Cwd::cwd;
        &main_test;
    chdir $old_cwd;
}

sub main_test {
    my $dir = tempdir(CLEANUP => 1);
    chdir $dir or die $!;
    unshift @INC, File::Spec->catfile($dir, 'Hello', 'lib');

    my $setup = File::Spec->catfile($FindBin::Bin, '..', 'script', 'amon-setup.pl');
    my $libdir = File::Spec->catfile($FindBin::Bin, '..', 'lib');
    !system $^X, '-I', $libdir, $setup, 'Hello' or die $!;
    chdir 'Hello' or die $!;

    my $app = App::Prove->new();
    $app->process_args('-Ilib', '-I'.File::Spec->catfile($FindBin::Bin, '..', 'lib'), <t/*.t>, <xt/*.t>);
    ok($app->run);
}
