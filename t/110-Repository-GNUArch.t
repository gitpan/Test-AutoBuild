# $Id: 110-Repository-GNUArch.t,v 1.1 2004/04/06 11:21:24 danpb Exp $

BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }

use Test::AutoBuild::Repository::GNUArch;
$loaded = 1;
print "ok 1\n";

# Local Variables:
# mode: cperl
# End:
