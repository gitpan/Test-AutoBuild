# $Id: 200-AutoBuild.t,v 1.1 2004/04/02 19:04:30 danpb Exp $

BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }

use Test::AutoBuild;
$loaded = 1;
print "ok 1\n";

# Local Variables:
# mode: cperl
# End:
