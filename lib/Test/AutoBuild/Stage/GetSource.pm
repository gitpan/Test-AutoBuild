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
# $Id: GetSource.pm,v 1.18 2007/12/10 04:44:42 danpb Exp $

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

sub prepare {
    my $self = shift;
    my $runtime = shift;
    my $context = shift;

    my $result = $self->SUPER::prepare($runtime, $context);

    if (!defined $context) {
	foreach my $name ($runtime->sorted_modules()) {
	    my $module = $runtime->module($name);
	    my $subres = Test::AutoBuild::Result->new(name => $name,
						      label => $module->label);
	    $result->add_result($subres);
	    my $key = $self->name . "." . $name;
	    $self->{results}->{$key} = $subres;
	}
    }
    return $result;
}


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

    my $failed = 0;
    # Check out code
    MODULE: foreach my $name (@modules) {
	$log->debug("Checking out $name");
	foreach my $depend (@{$runtime->module($name)->depends}) {
	    if ($runtime->module($depend)->build_status() eq 'failed') {
		$log->info("skipping $name");
		next MODULE;
	    }
	}
	$runtime->notify("beginCheckout", $name, time);
	my $module = $runtime->module($name);
	$module->checkout($runtime);
	$runtime->notify("endCheckout", $name, time, $module->checkout_status);
	if ($module->checkout_status() eq "failed") {
	    $failed = 1;
	}
    }
    if ($failed) {
        $self->fail("One or more modules failed during checkout");
    }

    # Set stage result status per module
    if (!defined $module) {
        foreach my $name ($runtime->sorted_modules()) {
            my $module = $runtime->module($name);
            my $key = $self->name . "." . $name;
            my $subres = $self->{results}->{$key};

            # XXX log summary
            #$subres->log($module->build_output_log_summary);
            $subres->log("");
            $subres->status($module->checkout_status);
            $subres->start_time($module->checkout_start_date);
            $subres->end_time($module->checkout_end_date);
        }
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
