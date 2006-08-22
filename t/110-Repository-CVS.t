# $Id: 110-Repository-CVS.t,v 1.4 2005/12/28 19:23:46 danpb Exp $
#

use strict;
use warnings;
use Cwd;
use File::Spec::Functions;
use File::Path;
use Test::More tests => 26;
use Log::Log4perl;
Log::Log4perl::init("t/log4perl.conf");

BEGIN {
  use_ok("Test::AutoBuild::Repository::CVS") or die;
  use_ok("Test::AutoBuild::Runtime") or die;
  use_ok("Test::AutoBuild::Module") or die;
}


my $here = getcwd;
my $build_repos = catfile($here, "t", "build-repos");
my $build_home = catfile($here, "t", "build-home");
my $archive = catfile($here, "t", "110-Repository-CVS.tar.gz");

END {
  rmtree ($build_repos);
  rmtree ($build_home);
}

rmtree ($build_repos);
rmtree ($build_home);

mkpath ([$build_repos, $build_home], 0, 0755);
system "cd $build_repos && tar -zxvf $archive > /dev/null";

my $head = "test";
my $branch = "test:branch";

chdir $build_home;
my $repos = Test::AutoBuild::Repository::CVS->new(name => "test", label => "Test", env => { CVSROOT => $build_repos });
isa_ok($repos, "Test::AutoBuild::Repository::CVS");

&checkout("head", $head, 1109197163, "1\n", 1);
&checkout("head", $head, 1109197165, "1\n", 0);

&checkout("head", $head, 1109197174, "2\n", 1);

&checkout("head", $head, 1109197185, "2\n", 0);
&checkout("branch", $branch, 1109197185, "3\n", 1);

&checkout("head", $head, 1109197197, "4\n", 1);
&checkout("branch", $branch, 1109197197, "3\n", 0);

&checkout("head", $head, 1109197209, "4\n", 0);
&checkout("branch", $branch, 1109197209, "5\n", 1);

&checkout("head", $head, 1109197211, "6\n", 1);
&checkout("branch", $branch, 1109197211, "5\n", 0);


sub checkout {
  my $module = shift;
  my $src = shift;
  my $timestamp = shift;
  my $content = shift;
  my $changes = shift;

  my $runtime = Test::AutoBuild::Runtime->new(counter => Test::Counter->new(),
					      timestamp => $timestamp);
    
  my $changed = $repos->export($runtime, $src, $module);
  
  is($changes, $changed, $module . " files changed");
  
  my $file = catfile($build_home, $module, "a");
  open FILE, $file
    or die "cannot open $file: $!";
  
  my $line = <FILE>;
  close FILE;
  
  is($line, $content, $module . " content matches");
}

package Test::Counter;
use base qw(Test::AutoBuild::Counter);

sub generate {
  return 1;
}

# Local Variables:
# mode: cperl
# End:
