# -*- perl -*-
#
# Test::AutoBuild::Repository::Disk by %author%
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
# $Id: Disk.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Repository::Disk - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Repository::Disk


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Repository::Disk;

use strict;
use vars qw(@ISA);
use Carp qw(confess);
use Test::AutoBuild::Repository;
use Test::AutoBuild::Lib;

@ISA = qw(Test::AutoBuild::Repository);


=pod

=item my $???? = Test::AutoBuild::Repository::Disk->new(  );

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    bless $self, $class;

    return $self;
}


sub export {
    my $self = shift;

    my $name = shift;		# Name of the module to export.
    my $module = shift;		# Module object.

    # Don't support checking out multiple paths yets
    my $path= $module->paths->[0];

    Test::AutoBuild::Lib::_copy($path,$name);

    1;				# Don't support change-checking yet.
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
