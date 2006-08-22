# $Id: 200-AutoBuild.t,v 1.3 2005/12/30 15:05:04 danpb Exp $

use Test::More tests => 2;
use warnings;
use strict;
use Log::Log4perl;

BEGIN { 
  use_ok("Test::AutoBuild");
}

use Config::Record;
Log::Log4perl::init("t/log4perl.conf");

my $ab = Test::AutoBuild->new(config => "t/auto-build.conf");

isa_ok($ab, "Test::AutoBuild");


# Local Variables:
# mode: cperl
# End:
