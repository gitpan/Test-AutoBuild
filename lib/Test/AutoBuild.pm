# -*- perl -*-
#
# Test::AutoBuild by Dan Berrange, Richard Jones
#
# Copyright (C) 2002 Dan Berrange, Richard Jones
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
# $Id: AutoBuild.pm,v 1.6 2004/05/06 16:35:05 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild - Automated build engine

=head1 SYNOPSIS

  use Test::AutoBuild;
  use Config::Record;

  my $config = new Config::Record (file => $filename);
  my $builder = new Test::AutoBuild (config => $config [, verbose => 1]);

  my $status = $builder->run;

  exit $status;

=head1 DESCRIPTION

This module provides the engine of the automated build system.
It hooks together all the other modules to provide a structured
workflow process for running the build. In a future release of
autobuild, this module will be re-written to allow the workflow
to be defined through the configuration file.

=head1 METHODS

=over 4

=cut

package Test::AutoBuild;

use strict;
use BSD::Resource;
use Carp qw(confess);
use Test::AutoBuild::Cache;
use Test::AutoBuild::Lib;
use Fcntl ':flock';
use File::Path;
use File::Spec;
use POSIX qw(strftime);
use Sys::Hostname;

use vars qw($VERSION);
$VERSION = '1.0.0';

=pod

=item $builder = Test::AutoBuild->(config => $config [, verbose => 1]);

Creates a new autobuild runtime object. C<$config> is a configuration 
file (instance of C<Config::Record>).

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    my %params = @_;

    $self->{config} = exists $params{config} ? $params{config} :
        confess "config parameter is required";
    $self->{verbose} = exists $params{verbose} ? $params{verbose} : 0;

    bless $self, $class;

    return $self;
}

=pod

=item $config = $builder->config([$name, [$default]]);

If invoked with no arguments returns the Config::Record object
storing the builder configuration. If invoked with a single
argument, returns the configuration value with the matching
name. An optional default value can be provided in the second
argument

=cut

sub config
{
    my $self = shift;

    if (@_) {
        my $name = shift;
        return $self->{config}->param($name, @_);
    }
    return $self->{config};
}

=pod

=item $builder-run();

Executes the build process.

=cut

sub run
{
    my $self = shift;

    my $debug = $self->config("debug", 0);
    my $checkout = $self->config("checkout-source", 1);
    my $nice_level = $self->config("nice-level", 20);

    my $control_file = $self->config("control-file", "rollingbuild.sh");
    my $cvsweb_url = $self->config("cvsweb-url", undef);
    my $abort_on_fail = $self->config("abort-on-fail", 0);
    my $hostname = $self->config("hostname", hostname());

    my $lockfile = $self->config("lock.file", "$ENV{HOME}/.build.mutex");
    my $flocking = $self->config("lock.use-flock", "0");

    my $use_cache = $self->config("build.cache", "0");
    my $cache_timestamp = $self->config("build.cache-timestamp", "0");
    my $cache_dir = $self->config("build.cache-dir", "$ENV{HOME}/.build-cache");
    my $cache = undef;

    if ($use_cache) {
        $cache = Test::AutoBuild::Cache->new(cache_root => $cache_dir,
					     timestamp => $cache_timestamp);
    }

    # $build_home is where we check out the source to (for CVS). Pretty
    # much unused for Perforce builds.
    my $build_home = $self->config("build.home", "$ENV{HOME}/build_home");

    # $build_root can be used as the fake "root" directory for
    # configure --prefix $AUTO_BUILD_ROOT/usr (if you wish).
    my $build_root = $self->config("build.root", "$ENV{HOME}/.build");

    my $package_dir = $self->config("package.dir", "$ENV{HOME}/public_html");

    my $repositories
        = Test::AutoBuild::Lib::load_repositories($self->{config});
    my $outputs
        = Test::AutoBuild::Lib::load_outputs($self->{config});
    my $groups
        = Test::AutoBuild::Lib::load_groups($self->{config});

    # %$package_types maps "name" => PackageType objects, where "name"
    # is a string like "rpm" or "pkg".
    my $package_types
        = Test::AutoBuild::Lib::load_package_types($self->{config});

    # %$modules maps "name" => Module objects, where "name" is the name
    # of a module (eg. "auto-ccm-core-trunk").
    my $modules
        = Test::AutoBuild::Lib::load_modules($self->{config});

    my $tmpdir = $self->config("tmp-dir", "/var/tmp");

    my $log_file_dir = "$tmpdir/buildlogs";
    my $cvs_log_file = "$log_file_dir/cvs";
    my $tsort_input_file = "$tmpdir/tsort.in";

    #----------------------------------------------------------------------
    # Grab the global build lock.

    # print "Getting exclusive lock $flocking\n" if $debug;
    if ($flocking) {
        open LOCKFILE, ">$lockfile" or die "cannot open $lockfile: $!";

        flock (LOCKFILE, LOCK_EX | LOCK_NB) or exit 1;
    } else {
        # Note: There really isn't a race condition here.
        # since this script is only invoked every 5 mins
        if ( -f $lockfile ) {
            exit 1;
        }

        open LOCKFILE, ">$lockfile" or die "cannot open $lockfile: $!";
        close LOCKFILE;
    }
    print "Got exclusive lock\n" if $debug;

    #----------------------------------------------------------------------
    # Initialize a couple of random things

    chdir $build_home or die "chdir: $build_home: $!";

    my $start_time = time;              # NB: Also used for epoch number.

    #----------------------------------------------------------------------
    # Make our log file directory.

    if (-d $log_file_dir) {
        rmtree($log_file_dir);
    }
    mkdir $log_file_dir, 0755 or die "cannot create log file directory: $log_file_dir $!";

    #----------------------------------------------------------------------
    # Global environment overrides
    my $env = $self->config("env");
    local %ENV = %ENV;
    if (defined $env) {
        foreach (keys %{$env}) {
            $ENV{$_} = $env->{$_};
        }
    }

    #----------------------------------------------------------------------
    # Renice ourselves so we don't monopolise the machine
    print "Renicing to level $nice_level\n" if $debug;
    setpriority PRIO_PROCESS, $$, $nice_level
        or die "cannot renice to $nice_level: $!";

    #----------------------------------------------------------------------
    # Export code from source repository

    $0 = "Exporting code from source repositories";

    if ($checkout) {
        foreach my $name (keys %{$modules}) {
            my $module = $modules->{$name};

            my $repository = $repositories->{$module->repository()};
            die "cannot find repository definition for module " . $module->label
                unless defined $repository;

            print "Adding module $name to repository " . $repository->label() . "\n" if $debug;
            $repository->module($name, $module);
        }

        foreach my $name (keys %{$repositories}) {
            my $repo = $repositories->{$name};
            print "Initializing repository " . $repo->label() . "\n" if $debug;
            $repo->init();
        }

        foreach my $name (sort keys %{$modules}) {
            my $module = $modules->{$name};

            if ($debug) {
                print "Checking out $name\n";
            }

            my $repository = $repositories->{$module->repository()};
            die "cannot find repository definition for module " . $module->label
                unless defined $repository;

            my $changed = $repository->export ($name, $module, $groups);
	    if ($changed) {
		print "Module $module changed, so clearing cache\n" if $debug;
		$cache->clear($module->name());
	    }
        }
    } else {
        if ($debug) {
            print "Skipping checkout of source code\n";
        }
    }

    my $order = Test::AutoBuild::Lib::sort_modules $modules;

    #----------------------------------------------------------------------
    # Clean up old packages directories (if specified).

    foreach my $name (keys %$package_types) {
        $package_types->{$name}->do_clean;
    }

    #----------------------------------------------------------------------
    # Do the build.

    # Set up the environment for the build.

    rmtree($build_root);
    mkdir $build_root, 0775 or die "mkdir $build_root: $!";

    foreach my $name (@$order) {
        my $module = $modules->{$name};
        my $module_build_root = $module->real_build_root();
        if (defined $module_build_root) {
            rmtree($module_build_root);
            mkdir $module_build_root, 0775 or die "mkdir $module_build_root: $!";
        } else {
	    # We need to explicitly set each module's build root so
	    # that in the case that it has to load its files from
	    # cache, they don't get added to the calling module's
	    # build root
	    $module->build_root($build_root);
	}
    }

    if ($debug) {
        print "build roots cleaned\n";
    }

    # A unique integer counter for this build,
    # allowing person calling us to override its value
    unless (exists $ENV{AUTO_BUILD_COUNTER}) {
        $ENV{AUTO_BUILD_COUNTER} = time;
    }

    # @$order contains a suitable build ordering. Now go and build it.

    if ($debug) {
        print "Build order:\n";
        foreach my $module (@$order) {
            print "  $module\n";
        }
        print "End\n";
    }

    foreach my $name (@$order) {
        print "Building $name (" . Test::AutoBuild::Lib::pretty_date(time()) . ")\n" if $debug;
        my $module = $modules->{$name};
        my $before =
            Test::AutoBuild::Lib::package_snapshot ($package_types);

        $0 = "Building: $name"; # Change our name to reflect what we're doing.

        my $depends = $module->dependencies();
        my $skip = 0;
        foreach my $depend (@{$depends}) {
            if ($modules->{$depend}->build_status() ne 'success' &&
                $modules->{$depend}->build_status() ne 'cache' ) {
                if ($debug) {
                    print "Skipping " . $module->label() . " because " .
                        $modules->{$depend}->label() . " failed\n";
                }
                $skip = 1;
            }
        }
        if ($skip) {
            $module->build_status("skipped");
            next;
        }

        if (defined $module->real_build_root()) {
            $ENV{AUTO_BUILD_ROOT} = $module->real_build_root();
        } else {
            $ENV{AUTO_BUILD_ROOT} = $build_root;
        }

        my $start = time;
        $module->build($cache, $modules);
        my $end = time;
        $module->build_time($end - $start);

        if ($module->build_status() eq 'failed' && $abort_on_fail) {
            last;
        }

        print "Done Building $name (" . Test::AutoBuild::Lib::pretty_date(time()) . ")\n" if $debug;

        my $after
            = Test::AutoBuild::Lib::package_snapshot ($package_types);

        # %$packages maps "filename" => Package objects, where "filename"
        # is the absolute path of each package built during this run
        # (eg. the filename of an RPM file).
        my $packages
            = $module->packages
            (Test::AutoBuild::Lib::new_packages ($before, $after), $package_types);
        if ($debug) {
            foreach (keys %{$packages}) {
                print "Found package: $_\n";
            }
        }
    }

    #----------------------------------------------------------------------
    # Run the output modules

    foreach my $name (sort keys %{$outputs}) {
        my $output = $outputs->{$name};
        print "Running output module " . ref($output) . "\n" if $debug;
        $0 = "Running: " . ref($output); # Change our name to reflect what we're doing.
        $output->process ($modules, $groups, $repositories, $package_types);
    }

    #----------------------------------------------------------------------
    # Release the lock.

    unless ($flocking) {
        print "Removing lockfile\n" if $debug;
        unlink $lockfile or die "unlink: $lockfile: $!";
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
