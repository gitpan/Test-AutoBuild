# $Id: 120-Output-ArtifactCopier.t,v 1.1.2.1 2004/08/16 09:10:55 danpb Exp $

BEGIN { $| = 1; print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }

use Test::AutoBuild::Output::ArtifactCopier;
$loaded = 1;
print "ok 1\n";

# Local Variables:
# mode: cperl
# End:
