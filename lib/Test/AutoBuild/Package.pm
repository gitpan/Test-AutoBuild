# -*- perl -*-
#
# Test::AutoBuild::Package by Daniel Berrange <dan@berrange.com>
#
# Copyright (C) 2002 Daniel Berrange <dan@berrange.com>
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
# $Id: Package.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Package - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Package


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Package;

use strict;
use Carp qw(confess);
use Digest::MD5;
use File::stat;

=pod

=item my $???? = Test::AutoBuild::Package->new(  );

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    my %params = @_;

    $self->{name} = exists $params{name} ? $params{name} : confess "name parameter is required";
    $self->{type} = exists $params{type} ? $params{type} : confess "type parameter is required";
    $self->{size} = undef;
    $self->{last_modified} = undef;
    $self->{md5sum} = undef;

    bless $self, $class;

    $self->_stat();

    return $self;
}

sub name {
    my $self = shift;
    $self->{name} = shift if @_;
    return $self->{name};
}

sub type {
    my $self = shift;
    $self->{type} = shift if @_;
    return $self->{type};
}


sub size {
    my $self = shift;

    return $self->{size};
}


sub last_modified {
    my $self = shift;

    return $self->{last_modified};
}


sub md5sum {
    my $self = shift;
    $self->_md5sum() unless defined  $self->{md5sum};
    return $self->{md5sum};
}


sub _stat {
    my $self = shift;

    my $sb = stat $self->{name};

    $self->{last_modified} = $sb->mtime;
    $self->{size} = $sb->size;
}


sub _md5sum {
    my $self = shift;

    my $md5 = Digest::MD5->new();

    if ($self->{type}->filetype() eq "directory") {
        my $listing = "";
	    opendir(DIR, $self->{name}) or die("can't opendir $self->{name}: $!");
	    foreach my $file_or_dir (grep { !m/^\.$/ && !m/^\.\.$/ } readdir(DIR)) {
            my $sb = stat(File::Spec->catfile($self->{name}, $file_or_dir));
            $listing .= join ":", $sb->mode, $sb->uid, $sb->gid, $sb->size, $sb->mtime;
	    }
	    closedir DIR;
        $md5->add($listing);
    } else {
        open FILE, $self->{name} or die "cannot open $self->{name}: $!";
        $md5->addfile(\*FILE);
    }

    $self->{md5sum} = $md5->hexdigest();

    close FILE;
}

1 # So that the require or use succeeds.

__END__

=back 4

=head1 AUTHORS

Daniel Berrange <dan@berrange.com>

=head1 COPYRIGHT

Copyright (C) 2002 Daniel Berrange <dan@berrange.com>
=head1 SEE ALSO

L<perl(1)>

=cut
