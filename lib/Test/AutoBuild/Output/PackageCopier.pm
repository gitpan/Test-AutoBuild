# -*- perl -*-
#
# Test::AutoBuild::Output::PackageCopier by %author%
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
# $Id: PackageCopier.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Output::PackageCopier - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Output::PackageCopier


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Output::PackageCopier;

use strict;
use Carp qw(confess);
use Test::AutoBuild::Output;
use File::Path;
use vars qw(@ISA);

@ISA = qw(Test::AutoBuild::Output);


=pod

=item my $???? = Test::AutoBuild::Output::PackageCopier->new(  );

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
    my $groups = shift;
    my $repositories = shift;
    my $package_types = shift;

    my $directory = $self->option("directory");
    confess "directory parameter is required" unless $directory;

    # By default, remove the old contents of the directory.  This can be overridden by setting
    # the 'clean-directory' parameter to 0
    my $clean = $self->option("clean-directory");
    $clean = 1 unless ( defined ($clean) && $clean == 0 );


    if ( $clean ) {
        my @in = ([ $directory, $directory, {} ]);
        my $out = $self->_expand_macro(\@in, "%m", "module", keys %{$modules});
        $out = $self->_expand_macro($out, "%p", "package_type", keys %{$package_types});
        foreach (@{$out}) {
            my ($src, $dst, $vars) = @{$_};
            rmtree($dst);
        }
    }

    foreach my $name (keys %{$modules}) {
	warn "Process $name\n";
        $directory = $self->option("directory");
        $directory =~ s,\%m,$name,g;
        my $packages = $modules->{$name}->packages();
        foreach my $filename (keys %{$packages}) {
            my $type = $packages->{$filename}->type->name();
            my $newdir = "$directory";
            $newdir =~ s,\%p,$type,g;
            mkpath($newdir);
	    warn "Copy $filename $newdir\n";
            Test::AutoBuild::Lib::_copy($filename,$newdir);
        }
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
