# -*- perl -*-
#
# Test::AutoBuild::Output::TemplateGenerator by Daniel Berrange <dan@berrange.com>
#
# Copyright (C) 2002,2004 Daniel Berrange <dan@berrange.com>
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
# $Id: TemplateGenerator.pm,v 1.1 2004/04/02 19:04:29 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Output::TemplateGenerator - what does this module do ?

=head1 SYNOPSIS

  use Test::AutoBuild::Output::TemplateGenerator


=head1 DESCRIPTION

Description

=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Output::TemplateGenerator;

use Carp qw(confess);
use Test::AutoBuild::Output;

use Template;
use File::Spec;

use strict;
use vars qw(@ISA);

@ISA = qw(Test::AutoBuild::Output);


=pod

=item my $???? = Test::AutoBuild::Output::TemplateGenerator->new(  );

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    bless $self, $class;

    return $self;
}


sub _generate_templates {
    my $self = shift;
    my $modules = shift;
    my $groups = shift;
    my $repositories = shift;
    my $package_types = shift;
    my $globalvars = shift;
    
    my $files = $self->option("files");
    $files = [ { src => "index.html", dst => "index.html" } ] unless defined $files;
    $files = $self->_expand_templates($files, $modules, $groups, $repositories, $package_types);
    
    my $path = $self->option("template-src-dir");
    my %config = (
                  INCLUDE_PATH => $path
                  );
    my $template = Template->new(\%config);

    foreach my $file (@{$files}) {
        my ($src, $dst, $localvars) = @{$file};
        
        print "Got $src, $dst: " . join (',', map {$_ . "=" . $localvars->{$_}} keys %{$localvars}) . "\n"; 
	
        my $dest = File::Spec->catfile($self->option("template-dest-dir"), $dst);
        my $fh = IO::File->new(">$dest")
	    or die "cannot  create $dest: $!";
        
	my %vars;
	foreach (keys %{$globalvars}) {
	  $vars{$_} = $globalvars->{$_};
	}
	foreach (keys %{$localvars}) {
	  $vars{$_} = $localvars->{$_};
	}
	
        # XXX globalvars
        if (!$template->process($src, \%vars, $fh)) {
	    warn $template->error->as_string;
	}

        $fh->close;
    }
}


sub _expand_templates {
    my $self = shift;
    my $files = shift;
    my $modules = shift;
    my $groups = shift;
    my $repositories = shift;
    my $package_types = shift;
    
    my @in;
    foreach (@{$files}) {
        my ($src, $dst, $name) = ($_->{src}, $_->{dst}, $_->{name});
        print "Adding $src, $dst\n";
        push @in, [ $src, $dst, { name => $name } ];
    }

    my $out = $self->_expand_macro(\@in, "%m", "module", keys %{$modules});
    $out = $self->_expand_macro($out, "%r", "repository", keys %{$repositories});
    $out = $self->_expand_macro($out, "%p", "package_type", keys %{$package_types});    
    $out = $self->_expand_macro($out, "%g", "group", keys %{$groups});
    
    return $out;
}


1 # So that the require or use succeeds.

__END__

=back 4

=head1 AUTHORS

Daniel Berrange <dan@berrange.com>

=head1 COPYRIGHT

Copyright (C) 2002,2004 Daniel Berrange <dan@berrange.com>

=head1 SEE ALSO

L<perl(1)>

=cut
