# $Id: Makefile.PL,v 1.4 2004/05/07 14:27:43 danpb Exp $
# -*- perl -*-

use ExtUtils::MakeMaker;

WriteMakefile(
              NAME => "Test-AutoBuild",
              VERSION_FROM => 'lib/Test/AutoBuild.pm',
	      AUTHOR => "Daniel Berrange (dan[at]berrange[dot]com)",
              EXE_FILES => ['bin/auto-build.pl'],
              PREREQ_PM => {
                 'BSD::Resource' => "1.10",
                 'IO::Scalar' => "0",
                 'Net::SMTP' => "2.15",
                 'File::Copy' => '0',
                 'File::Find' => '0',
                 'File::Path' => '0',
                 'Carp' => '0',
                 'Sys::Hostname' => '0',
                 'Digest::MD5' => '0',
                 'Fcntl' => '0',
                 'Config::Record' => '1.0.1',
                 'Template' => '0',
                 'POSIX' => '0'
              },
              dist =>
              {
                  COMPRESS => 'gzip --force --best',
              },

              clean =>
              {
                  FILES => '*.bak *~',
              },

              depend => {
                  Makefile => '$(VERSION_FROM)',
                  Test-AutoBuild.spec => '$(VERSION_FROM)',
                  dist => 'Test-AutoBuild.spec',
              },

              realclean => {
                  FILES => 'Test-AutoBuild-*.tar.gz Test-AutoBuild.spec',
              },
              );

package MY;

sub libscan
{
    my ($self, $path) = @_;
    ($path =~ /\~$/) ? undef : $path;
}


sub postamble
  {
    '
sysconfdir      = $(PREFIX)/etc
pkgsysconfdir   = $(sysconfdir)/auto-build.d

install ::
	if [ -f $(pkgsysconfdir)/auto-build.conf ]; then \
	  install -c -D -m 0644 conf/auto-build.conf $(pkgsysconfdir)/auto-build.conf-example; \
	  echo "Not overwriting existing config file $(pkgsysconfdir)/auto-build.conf" ;\
	else \
	  install -c -D -m 0644 conf/auto-build.conf $(pkgsysconfdir)/auto-build.conf; \
	fi
	install -c -D -m 0644 conf/auto-build.cron $(pkgsysconfdir)/auto-build.cron;
	install -d -m 0755 $(pkgsysconfdir)/templates
	install -c -D -m 0644 templates/email.txt $(pkgsysconfdir)/templates/email.txt
	install -c -D -m 0644 templates/*.html $(pkgsysconfdir)/templates
';
  }


__END__
