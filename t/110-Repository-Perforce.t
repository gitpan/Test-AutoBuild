# $Id: 110-Repository-Perforce.t,v 1.7 2006/04/09 02:10:00 danpb Exp $
#

use strict;
use warnings;
use Cwd;
use File::Spec::Functions;
use File::Path;
use Test::More tests => 37;
use POSIX ":sys_wait_h";
use Log::Log4perl;
Log::Log4perl::init("t/log4perl.conf");

BEGIN {
  use_ok("Test::AutoBuild::Repository::Perforce") or die;
  use_ok("Test::AutoBuild::Runtime") or die;
  use_ok("Test::AutoBuild::Module") or die;
}


my $here = getcwd;
my $build_repos = catfile($here, "t", "build-repos");
my $build_home = catfile($here, "t", "build-home");
my $archive = catfile($here, "t", "110-Repository-Perforce.tar.gz");

my $pid;

END {
  if (defined $pid) {
    my $kid = waitpid $pid, WNOHANG;
    if ($kid != $pid) {
      kill KILL => $pid;
      $kid = waitpid $pid, WNOHANG;
    }
  }
  unless (exists $ENV{DEBUG_TESTS}) {
    rmtree ($build_repos);
    rmtree ($build_home);
  }
}

rmtree ($build_repos);
rmtree ($build_home);

mkpath ([$build_repos, $build_home], 0, 0755);
system "cd $build_repos && tar zxf $archive";

my $head = Test::AutoBuild::Module->new(name => "head", 
					label => "Test head",
					sources => [
						    {
						     repository => "test",
						     path => "//depot/test/trunk/...",
						    }
						   ]
				       );
my $branch = Test::AutoBuild::Module->new(name => "branch", 
					  label => "Test branch",
					  sources => [
						      {
						       repository => "test",
						       path => "//depot/test/branch/...",
						      }
						     ]
					 );

chdir $build_home;
my $repos = Test::AutoBuild::Repository::Perforce->new(name => "test", 
						       label => "Test", 
						       env => {
							       "P4PORT" => 1666,
							       "P4HOST" => "localhost",
							       "P4USER" => "autobuild",
							       "P4CLIENT" => "autobuild"
							      });
isa_ok($repos, "Test::AutoBuild::Repository::Perforce");



SKIP: {

  my $found_p4 = 0;
  my $found_p4d = 0;
  foreach my $dir (File::Spec->path) {
    my $p4d = catfile($dir, "p4d");
    $found_p4d = 1 if -x $p4d;
    my $p4 = catfile($dir, "p4");
    $found_p4 = 1 if -x $p4;
  }
  skip "p4 binary not in path", 33 unless $found_p4;
  skip "p4d binary not in path", 33 unless $found_p4d;
  
  $pid = fork();
  
  die "cannot fork server: $!" unless defined $pid;
  
  if ($pid == 0) {
    exec "p4d", "-r", $build_repos;
    die "cannot exec server: $!";
  }
  
  # Give p4d time to start!
  sleep 5; 
  &checkout(1, $head, 1110722400, "0\n", 1, { 1 => Test::AutoBuild::Change->new(number => 1, 
									     user => "dan",
									     date => "1110722399",
									     files => ["//depot/test/trunk/a#1 add"],
									     description => "Initial checkin")});

  &checkout(2, $head, 1110722420, "1\n", 1, { 2 => Test::AutoBuild::Change->new(number => 2, 
									     user => "dan",
									     date => "1110722418",
									     files => ["//depot/test/trunk/a#2 edit"],
									     description => "First change")});
  
  &checkout(3, $head, 1110722445, "2\n", 1, { 3 => Test::AutoBuild::Change->new(number => 3, 
									     user => "dan",
									     date => "1110722440",
									     files => ["//depot/test/trunk/a#3 edit"],
									     description => "Second change")});
  
  &checkout(4, $head, 1110722470, "2\n", 0, { } );

  &checkout(5, $branch, 1110722470, "3\n", 1, { 5 => Test::AutoBuild::Change->new(number => 5, 
									       user => "dan",
									       date => "1110722469",
									       files => ["//depot/test/branch/a#2 edit"],
									       description => "Fourth change") } );
  
  &checkout(6, $head, 1110722495, "4\n", 1, { 6 => Test::AutoBuild::Change->new(number => 6, 
									     user => "dan",
									     date => "1110722494",
									     files => ["//depot/test/trunk/a#4 edit"],
									     description => "Fifth change") } );
  &checkout(7, $branch, 1110722495, "3\n", 0, {});
  
  &checkout(8, $head, 1110722515, "4\n", 0, { });
  &checkout(9, $branch, 1110722515, "5\n", 1, { 7 => Test::AutoBuild::Change->new(number => 7, 
									       user => "dan",
									       date => "1110722512",
									       files => ["//depot/test/branch/a#3 edit"],
									       description => "Sixth change") } );
  
  &checkout(10, $head, 1110722525, "6\n", 1, { 8 => Test::AutoBuild::Change->new(number => 8, 
									     user => "dan",
									     date => "1110722523",
									     files => ["//depot/test/trunk/a#5 edit"],
									     description => "Seventh change") } );
  &checkout(11, $branch, 1110722525, "5\n", 0, {});
}


sub checkout {
  my $testnum = shift;
  my $module = shift;
  my $timestamp = shift;
  my $content = shift;
  my $expect_change = shift;
  my $expected_changes = shift;

  my $runtime = Test::AutoBuild::Runtime->new(counter => Test::Counter->new,
					      timestamp => $timestamp,
					      source_root => $build_home,
					      modules => {
							  head => $head,
							  branch => $branch,
							 });
					      
  my ($changed, $changes) = $repos->export($runtime, $module->sources->[0]->{path}, $module->dir);

  is($changed, $expect_change, $module->name . " files changed (n=$testnum)");
  is_deeply($changes, $expected_changes, $module->name . " changes match (n=$testnum)");
  
  my $file = catfile($build_home, $module->name, "a");
  open FILE, $file
    or die "cannot open $file: $!";
  
  my $line = <FILE>;
  close FILE;

  is($line, $content, $module->name . " content matches (n=$testnum)");
}

package Test::Counter;
use base qw(Test::AutoBuild::Counter);

sub generate {
  return 1;
}

# Local Variables:
# mode: cperl
# End:
