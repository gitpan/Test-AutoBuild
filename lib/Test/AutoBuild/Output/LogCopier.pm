# -*- perl -*-
#
# Test::AutoBuild::Output::LogCopier by %author%
#
# Copyright (C) 2002 %author%
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
# $Id: LogCopier.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Output::LogCopier - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Output::LogCopier


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Output::LogCopier;

use strict;
use Carp qw(confess);
use Test::AutoBuild::Output;
use File::Path;
use vars qw(@ISA);

@ISA = qw(Test::AutoBuild::Output);


=pod

=item my $???? = Test::AutoBuild::Output::LogCopier->new(  );

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    bless $self, $class;

    return $self;
}


sub process {
    my $self = shift;
    my $modules = shift;

    my $directory = $self->option("directory");
    confess "directory parameter is required" unless $directory;

    # By default, remove the old contents of the directory.  This can be overridden by setting
    # the 'clean-directory' parameter to 0
    my $clean = $self->option("clean-directory");
    $clean = 1 unless ( defined ($clean) && $clean == 0 );
    if ( $clean ) {
        if ( $directory =~ m,\%m, ) {
            foreach my $name (keys %{$modules}) {
                $directory = $self->option("directory");
                $directory =~ s,\%m,$name,g;
                rmtree($directory);
            }
        } else {
            rmtree($directory);
        }
    }

    foreach my $name (keys %{$modules}) {

        $directory = $self->option("directory");
        $directory =~ s,\%m,$name,g;

        mkpath($directory);

        my $log_filename = $modules->{$name}->build_log_filename();
        open (LOG, "> $directory/$log_filename") or die "Could not open $directory/$log_filename";

        my $build_log = $modules->{$name}->build_log();
        print LOG $build_log;
    }
}



1 # So that the require or use succeeds.

__END__

=back 4

=head1 AUTHORS

%author%

=head1 COPYRIGHT

Copyright (C) 2002 %author%

=head1 SEE ALSO

L<perl(1)>

=cut
