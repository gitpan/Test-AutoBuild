# $Id: 130-Publisher.t,v 1.1.2.1 2004/08/16 09:10:55 danpb Exp $

BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }

use Test::AutoBuild::Publisher;
$loaded = 1;
print "ok 1\n";

# Local Variables:
# mode: cperl
# End:
