# -*- perl -*-
#
# Test::AutoBuild::Output::HTMLStatus by %author%
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
# $Id: HTMLStatus.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Output::HTMLStatus - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Output::HTMLStatus


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Output::HTMLStatus;

use Carp qw(confess);
use Test::AutoBuild::Output::TemplateGenerator;
use Test::AutoBuild::Lib;
use POSIX qw(strftime);
use strict;
use vars qw(@ISA);

@ISA = qw(Test::AutoBuild::Output::TemplateGenerator);


=pod

=item my $???? = Test::AutoBuild::Output::HTMLStatus->new(  );

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

    my $httpurl = $self->option("downloads")->{"http"};
    my $ftpurl = $self->option("downloads")->{"ftp"};
    my $logurl = $self->option("downloads")->{"log"};

    my $cycle_time = time - $self->start_time + 1;

    my @modules;

    my $overall_status = 'success';

    foreach my $name (sort { $modules->{$a}->label cmp $modules->{$b}->label } keys %{$modules}) {

        my @packs = ();
        my $packages = $modules->{$name}->packages();

        foreach my $filename (keys %{$packages}) {
            my $file = $filename;
            $file =~ s,^.*/,,;

            my $thishttpurl = $httpurl;
            my $pt = $packages->{$filename}->type()->name();
            $thishttpurl =~ s,\%m,$name,g;
            $thishttpurl =~ s,\%f,$file,g;
            $thishttpurl =~ s,\%p,$pt,g;

            my $thisftpurl = $ftpurl;
            $thisftpurl =~ s,\%m,$name,g;
            $thisftpurl =~ s,\%f,$file,g;
            $thisftpurl =~ s,\%p,$pt,g;

            my $fn = $packages->{$filename}->name;
            $fn =~ s,.*/,,;

            my $size = $packages->{$filename}->size();

            my $p = {
                'filename' => $fn,
                'size' => $size,
                'prettysize' => Test::AutoBuild::Lib::pretty_size($size),
                'md5sum' => $packages->{$filename}->md5sum,
                'httpURL' => $thishttpurl,
                'ftpURL' => $thisftpurl,
                'type' => $packages->{$filename}->type,
            };
            push @packs, $p;
        }
        @packs = sort { $a->{type}->name() cmp $b->{type}->name() or $a->{filename} cmp $b->{filename} } @packs;

        my $logfile = $modules->{$name}->build_log_filename;
        my $logfileurl = $logurl;
        $logfileurl =~ s,\%m,$name,g;
        $logfileurl =~ s,\%f,$logfile,g;

        if ($modules->{$name}->build_status() eq 'failed') {
            $overall_status = 'failed';
        }

        my $mod = {
            'name' => $name,
            'label' => $modules->{$name}->label,
            'status' => $modules->{$name}->build_status,
            'group' => $modules->{$name}->group,
            'repository' => $modules->{$name}->repository,
            'buildTime' => Test::AutoBuild::Lib::pretty_time($modules->{$name}->build_time),
            'buildDate' => scalar (Test::AutoBuild::Lib::pretty_date($modules->{$name}->build_date)),
            'logURL' => $logfileurl,
            'logFilename' => $logfile,
            'packages' => \@packs,
        };

        push @modules, $mod;
    }

    my @groups;
    foreach my $name (sort keys %{$groups}) {
        my $group = $groups->{$name};
        
        my @groupmods = grep { grep { $_ eq $name } split (',', $_->{group}) } @modules;
        print "Got $name " . scalar(@groupmods) . "\n";
        my $entry = {
            name => $name,
            label => $group->label,
            modules => \@groupmods,
        };
        
        push @groups, $entry;
    }

    my @repositories;
    foreach my $name (sort keys %{$repositories}) {
        my $repository = $repositories->{$name};
        
        my @repositorymods = grep { $_->{repository} eq $name } @modules;

        my $entry = {
            name => $name,
            label => $repository->label,
            modules => \@repositorymods,
        };
        
        push @repositories, $entry;
    }
    
    my %vars = (
                'status' => $overall_status,
                'date' => strftime ("%a %b %e %Y", gmtime),
                'time' => join ("<br>",
                                strftime ("%H:%M:%S", gmtime) . " UTC",
                                strftime ("%H:%M:%S %Z", localtime)),
                'cycleTime' => Test::AutoBuild::Lib::pretty_time($cycle_time),
                'buildCounter', $ENV{AUTO_BUILD_COUNTER},
                'modules' => \@modules,
                'groups' => \@groups,
                'repositories' => \@repositories,
                );
    $self->_generate_templates($modules, $groups, $repositories, $package_types, \%vars);
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
