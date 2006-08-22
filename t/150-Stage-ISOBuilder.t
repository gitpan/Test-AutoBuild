# -*- cperl -*-

use Test::More tests => 4;
use warnings;
use strict;
use Log::Log4perl;

Log::Log4perl::init("t/log4perl.conf");

BEGIN { 
  use_ok("Test::AutoBuild::Stage::ISOBuilder") or die;
  use_ok("Test::AutoBuild::Runtime") or die;
  use_ok("Test::AutoBuild::Counter::Time") or die;
}

my $runtime = Test::AutoBuild::Runtime->new(counter => Test::AutoBuild::Counter::Time->new());

TEST_ONE: {
  my $stage = Test::AutoBuild::Stage::ISOBuilder->new(name => "make-isos",
						      label => "Create ISO images",
						      options => {
								 });
  isa_ok($stage, "Test::AutoBuild::Stage::ISOBuilder");
  
  # Implement me!
  #$stage->run($runtime);
  #ok($stage->succeeded(), "stage succeeeded");
}

