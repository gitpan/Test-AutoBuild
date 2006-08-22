# -*- perl -*-
#
# Test::AutoBuild::Stage::GetSource
#
# Daniel Berrange <dan@berrange.com>
# Dennis Gregorovic <dgregorovic@alum.mit.edu>
#
# Copyright (C) 2004 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# $Id: GetSource.pm,v 1.15 2006/02/02 10:30:48 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Stage::GetSource - The base class for an AutoBuild stage

=head1 SYNOPSIS

  use Test::AutoBuild::Stage::GetSource


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Stage::GetSource;

use base qw(Test::AutoBuild::Stage);
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use File::Path;
use Log::Log4perl;


sub process {
    my $self = shift;
    my $runtime = shift;
    my $module = shift;

    my @modules = defined $module ? ($module) : $runtime->modules();

    my $log = Log::Log4perl->get_logger();
    #----------------------------------------------------------------------
    # Export code from source repository

    # $source_root is where we check out the source to (at least for CVS).
    my $source_root = $runtime->source_root();
    unless (-e $source_root) {
        eval {
            mkpath($source_root);
        };
        if ($@) {
            die "could not create directory '$source_root': $@";
        }
    }
    chdir $source_root or die "chdir: " . $source_root . ": $!";

    my @repositories = $runtime->repositories();
    
    my @fail;
    # Check out code
    MODULE: foreach my $name (@modules) {
        $log->debug("Checking out $name");
        foreach my $depend (@{$runtime->module($name)->depends}) {
            if ($runtime->module($depend)->build_status() eq 'failed') {
                $log->info("skipping $name");
                next MODULE;
            }
        }
        my $module = $runtime->module($name);
        my %changes;
	my @mod_fail;
        foreach my $entry (@{$module->sources()}) {
            my $repository = $runtime->repository($entry->{repository});
            if (!defined $repository) {
                $self->fail("cannot find repository definition '" . 
			    $entry->{repository} ."' for module " . $module->label);
		next;
            }
	    
	    my $path = $entry->{path};
	    my $src;
	    my $dst;
	    if ($path =~ /^\s*(\S+)\s*->\s*(\S+)\s*$/) {
		$src = $1;
		$dst = catfile($module->dir, $2);
	    } else {
		$src = $path;
		$dst = $module->dir;
	    }

            my ($changed, $changes);
            eval {
                ($changed, $changes) = $repository->export($runtime, $src, $dst);
            };
            if ($@) {
                push @mod_fail, "Failed to checkout $name from '" . $repository->name . "': $@";
                $log->warn("Failed to checkout $name from '" . $repository->name . "': $@");
		next;
            }
	    if ($changed) {
		$module->changed(1);
	    }
	    if (defined $changes) {
		foreach (keys %{$changes}) {
		    $changes{$_} = $changes->{$_};
		}
	    }
        }

	if (@mod_fail) {
	    push @fail, @mod_fail;
	} else {
	    $module->changes(\%changes);
        }
    }
    if (@fail) {
	$self->fail(join("\n", @fail));
    }
}

1 # So that the require or use succeeds.

__END__

=back

=head1 AUTHORS

Daniel Berrange <dan@berrange.com>
Dennis Gregorovic <dgregorovic@alum.mit.edu>

=head1 COPYRIGHT

Copyright (C) 2004 Red Hat, Inc.

=head1 SEE ALSO

C<perl(1)>, L<Test::AutoBuild::Stage> 

=cut
