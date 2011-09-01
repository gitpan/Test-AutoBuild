# Automatically generated by perl-Test-AutoBuild.spec.PL

%bcond_without  fedora
%define appname Test-AutoBuild
%define with_selinux 0

# Everything on by default
%define with_bzr 1
%define with_cvs 1
%define with_darcs 1
%define with_git 1
%define with_mercurial 1
%define with_monotone 1
%define with_perforce 1
%define with_svk 1
%define with_svn 1
%define with_tla 1

# Not available in any Fedora release
%if %{?fedora}
%define with_perforce 0
%endif

# Not available since F15 onwards
%if %{?fedora} >= 14
%define with_tla 0
%endif

# Darcs won't work on arches which lack GHC
%ifnarch %{?ghc_arches}
%define with_darcs 0
%endif

# Avoid empty debug file
%define debug_package %{nil}

# This macro is used for the continuous automated builds. It just
# allows an extra fragment based on the timestamp to be appended
# to the release. This distinguishes automated builds, from formal
# Fedora RPM builds
%define _extra_release %{?dist:%{dist}}%{!?dist:%{?extra_release:%{extra_release}}}

Summary: Framework for performing continuous, unattended, automated software builds
Name: perl-%{appname}
Version: 1.2.4
Release: 1%{_extra_release}
License: GPLv2+
Group: Development/Tools
Url: http://autobuild.org/
Source: http://www.cpan.org/authors/id/D/DA/DANBERR/%{appname}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
# Technically this is a noarch package, but due to lack of ghc
# on some architecutures we need to use arch specific conditionals
# to kill off the darcs sub-RPM.
#BuildArchitectures: noarch

Requires: perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

BuildRequires: perl(BSD::Resource) >= 1.15
BuildRequires: perl(Config::Record) >= 1.1.0
BuildRequires: perl(Log::Log4perl)
BuildRequires: perl(Template)
BuildRequires: perl(IO::Scalar)
BuildRequires: perl(Date::Manip)
BuildRequires: perl(File::ReadBackwards)
BuildRequires: perl(Class::MethodMaker)
BuildRequires: perl(XML::Simple)
BuildRequires: perl(Test::More)
BuildRequires: perl(Test::Pod)
BuildRequires: perl(Test::Pod::Coverage)
BuildRequires: perl(YAML::Syck)
BuildRequires: perl(Test::YAML::Meta::Version)
BuildRequires: perl(ExtUtils::MakeMaker)
%if %{with_bzr}
BuildRequires: bzr >= 0.91
%endif
%if %{with_cvs}
BuildRequires: cvs >= 1.11
%endif
%if %{with_darcs}
BuildRequires: darcs >= 1.0.0
%endif
%if %{with_git}
BuildRequires: git >= 1.5.0.0
%endif
%if %{with_mercurial}
BuildRequires: mercurial >= 0.7
%endif
%if %{with_monotone}
BuildRequires: monotone >= 0.37
%endif
%if %{with_svk}
BuildRequires: perl-SVK >= 1.0
%endif
%if %{with_svn}
BuildRequires: subversion >= 1.0.0
%endif
%if %{with_tla}
BuildRequires: tla >= 1.1.0
%endif
BuildRequires:  fedora-usermgmt-devel
%if %{with_selinux}
BuildRequires: selinux-policy-devel
%endif

# For Test::AutoBuild::Stage::ISOBuilder
Requires: /usr/bin/mkisofs
# For Test::AutoBuild::Stage::Yum
Requires: /usr/bin/yum-arch
# For Test::AutoBuild::Stage::CreateRepo
Requires: /usr/bin/createrepo
# For Test::AutoBuild::Stage::Apt
Requires: /usr/bin/genbasedir
# For Test::AutoBuild::Publisher::XSLTransform
Requires: /usr/bin/xsltproc
# For Test::AutoBuild::Stage::RSyncStatus
Requires: /usr/bin/rsync

# Automatic RPM perl deps script misses this
Requires: perl(Class::MethodMaker)

%if %{with_selinux}
Requires(post): policycoreutils
Requires(postun): policycoreutils
%endif

%package account
Summary: User account and directory structure for running builder
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
%{?FE_USERADD_REQ}

%if %{with_selinux}
Requires(post): policycoreutils
%endif

%if %{with_bzr}
%package bzr
Summary: Bazaar source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: bzr >= 0.91
%endif

%if %{with_cvs}
%package cvs
Summary: CVS source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: cvs >= 1.11
%endif

%if %{with_darcs}
%package darcs
Summary: Darcs source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: darcs >= 1.0.0
%endif

%if %{with_git}
%package git
Summary: Git source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: git >= 1.5.0.0
%endif

%if %{with_mercurial}
%package mercurial
Summary: Mercurial source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: mercurial >= 0.7
%endif

%if %{with_monotone}
%package monotone
Summary: Monotone source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: monotone >= 0.37
%endif

%if %{with_perforce}
%package perforce
Summary: Perforce source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: perforce
%endif

%if %{with_svk}
%package svk
Summary: SVK source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: perl-SVK >= 1.0
%endif

%if %{with_svn}
%package subversion
Summary: Subversion source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: subversion >= 1.0.0
%endif

%if %{with_tla}
%package tla
Summary: GNU Arch source repository integration for autobuild engine
Group: Development/Tools
Url: http://autobuild.org/
Requires: perl-%{appname} = %{version}-%{release}
Requires: tla >= 1.1.0
%endif

%description
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds

%description account
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package creates a 'builder' user account and the directory structure
in /var/lib/builder necessary for running a builder instance using the default
example configuration file.

%if %{with_bzr}
%description bzr
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Bazaar
version control system
%endif

%if %{with_cvs}
%description cvs
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the CVS version
control system
%endif

%if %{with_darcs}
%description darcs
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Darcs
version control system
%endif

%if %{with_git}
%description git
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Git
version control system
%endif

%if %{with_mercurial}
%description mercurial
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Mercurial
version control system
%endif

%if %{with_monotone}
%description monotone
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Monotone
version control system
%endif

%if %{with_perforce}
%description perforce
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Perforce
version control system.
%endif

%if %{with_svk}
%description svk
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the SVK version
control system
%endif

%if %{with_svn}
%description subversion
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the Subversion
version control system
%endif

%if %{with_tla}
%description tla
Test-AutoBuild is a Perl framework for performing continuous, unattended,
automated software builds.

This sub-package provides the module for integrating with the GNU Arch
version control system
%endif

%prep
%setup -q -n %{appname}-%{version}
%if %{with_bzr} == 0
rm -f lib/Test/AutoBuild/Repository/Bazaar.pm
rm -f t/110-Repository-Bzr.t
%endif
%if %{with_cvs} == 0
rm -f lib/Test/AutoBuild/Repository/CVS.pm
rm -f t/110-Repository-CVS.t
%endif
%if %{with_darcs} == 0
rm -f lib/Test/AutoBuild/Repository/Darcs.pm
rm -f t/110-Repository-Darcs.t
%endif
%if %{with_git} == 0
rm -f lib/Test/AutoBuild/Repository/Git.pm
rm -f t/110-Repository-Git.t
%endif
%if %{with_mercurial} == 0
rm -f lib/Test/AutoBuild/Repository/Mercurial.pm
rm -f t/110-Repository-Mercurial.t
%endif
%if %{with_monotone} == 0
rm -f lib/Test/AutoBuild/Repository/Monotone.pm
rm -f t/110-Repository-Monotone.t
%endif
%if %{with_perforce} == 0
rm -f lib/Test/AutoBuild/Repository/Perforce.pm
rm -f t/110-Repository-Perforce.t
%endif
%if %{with_svk} == 0
rm -f lib/Test/AutoBuild/Repository/SVK.pm
rm -f t/110-Repository-SVK.t
%endif
%if %{with_svn} == 0
rm -f lib/Test/AutoBuild/Repository/Subversion.pm
rm -f t/110-Repository-Subversion.t
%endif
%if %{with_tla} == 0
rm -f lib/Test/AutoBuild/Repository/GNUArch.pm
rm -f t/110-Repository-GNUArch.t
%endif

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
%__make \
  WITH_SELINUX=%{with_selinux}

%install
%__rm -rf $RPM_BUILD_ROOT

%__make install \
  WITH_SELINUX=%{with_selinux} \
  PERL_INSTALL_ROOT=$RPM_BUILD_ROOT \
  INSTALLSYSCONF=%{_sysconfdir} \
  INSTALLSELINUX=%{_datadir}/selinux \
  INSTALLVENDORMAN5DIR=%{_mandir}/man5
find $RPM_BUILD_ROOT -name perllocal.pod -exec rm -f {} \;
find $RPM_BUILD_ROOT -name .packlist -exec rm -f {} \;
%__cp $RPM_BUILD_ROOT%{_sysconfdir}/auto-build.d/auto-build.conf \
  $RPM_BUILD_ROOT%{_sysconfdir}/auto-build.d/auto-build.conf-example

# Create various bits wanted for the -account subRPM
$RPM_BUILD_ROOT%{_bindir}/auto-build-make-root \
  $RPM_BUILD_ROOT%{_localstatedir}/lib/builder

echo "/1 :pserver:anonymous@cvs.gna.org:2401/cvs/testautobuild A" \
  >> $RPM_BUILD_ROOT%{_localstatedir}/lib/builder/.cvspass
%__chmod 0600 $RPM_BUILD_ROOT%{_localstatedir}/lib/builder/.cvspass

echo "%%_topdir %{_localstatedir}/lib/builder/package-root/rpm" \
  >> $RPM_BUILD_ROOT%{_localstatedir}/lib/builder/.rpmmacros

%check
%__make test

%clean
%__rm -rf $RPM_BUILD_ROOT

%pre account
%__id builder > /dev/null 2>&1
if [ $? == 0 ]; then
  # In case of upgrade from old version, relocate the home dir
  usermod -d %{_localstatedir}/lib/builder builder
else
  %__fe_groupadd 28 -r builder &>/dev/null || :
  %__fe_useradd  28 -r -s /sbin/nologin -d %{_localstatedir}/lib/builder -M          \
                    -c 'Test-AutoBuild build engine' -g builder builder &>/dev/null || :
fi

%if %{with_selinux}
%post
# Always run, even on upgrade so we reload it
/usr/sbin/semodule -i %{_datadir}/selinux/packages/auto-build/auto-build.pp >/dev/null
fixfiles -R %{name} restore
%endif

%postun account
%__fe_userdel builder &>/dev/null || :
%__fe_groupdel builder &>/dev/null || :

%if %{with_selinux}
%post account
fixfiles -R %{name}-account restore
%endif

%if %{with_selinux}
%postun
# Unload if last module
if [ $1 -eq 0 ]; then
  /usr/sbin/semodule -r autobuild >/dev/null
fi
%endif

%files
%defattr(-,root,root)
%doc AUTHORS README LICENSE CHANGES UPGRADING
%doc doc/*
%doc examples

# Man pages
%{_mandir}/man1/*
%{_mandir}/man3/*
%{_mandir}/man5/*

# Config
%dir %{_sysconfdir}/auto-build.d
%config(noreplace) %{_sysconfdir}/auto-build.d/auto-build.conf-example
%dir %{_sysconfdir}/auto-build.d/engine
%config(noreplace) %{_sysconfdir}/auto-build.d/engine/*.conf
%dir %{_sysconfdir}/auto-build.d/cron
%config(noreplace) %{_sysconfdir}/auto-build.d/cron/*.conf
%dir %{_sysconfdir}/auto-build.d/httpd
%config(noreplace) %{_sysconfdir}/auto-build.d/httpd/*.conf
%dir %{_sysconfdir}/auto-build.d/templates
%config(noreplace) %{_sysconfdir}/auto-build.d/templates/*

# Scripts & modules
%attr(0755,root,root) %{_bindir}/auto-build
%if %{with_selinux}
%attr(0755,root,root) %{_bindir}/auto-build-secure
%endif
%attr(0755,root,root) %{_bindir}/auto-build-make-root
%attr(0755,root,root) %{_bindir}/auto-build-clean-root
%dir %{perl_vendorlib}/Test
%{perl_vendorlib}/Test/AutoBuild.pm
%dir %{perl_vendorlib}/Test/AutoBuild
%{perl_vendorlib}/Test/AutoBuild/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Repository
%{perl_vendorlib}/Test/AutoBuild/Repository/Disk.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Stage
%{perl_vendorlib}/Test/AutoBuild/Stage/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Archive
%{perl_vendorlib}/Test/AutoBuild/Archive/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/ArchiveManager
%{perl_vendorlib}/Test/AutoBuild/ArchiveManager/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Counter
%{perl_vendorlib}/Test/AutoBuild/Counter/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Monitor
%{perl_vendorlib}/Test/AutoBuild/Monitor/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Publisher
%{perl_vendorlib}/Test/AutoBuild/Publisher/*.pm
%dir %{perl_vendorlib}/Test/AutoBuild/Command
%{perl_vendorlib}/Test/AutoBuild/Command/*.pm

%if %{with_selinux}
# SELinux policy
%{_datadir}/selinux/packages/auto-build/auto-build.pp
%endif

%if %{with_bzr}
%files bzr
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Bazaar.pm
%endif

%if %{with_cvs}
%files cvs
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/CVS.pm
%endif

%if %{with_darcs}
%files darcs
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Darcs.pm
%endif

%if %{with_git}
%files git
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Git.pm
%endif

%if %{with_mercurial}
%files mercurial
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Mercurial.pm
%endif

%if %{with_monotone}
%files monotone
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Monotone.pm
%endif

%if %{with_perforce}
%files perforce
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Perforce.pm
%endif

%if %{with_svk}
%files svk
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/SVK.pm
%endif

%if %{with_svn}
%files subversion
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/Subversion.pm
%endif

%if %{with_tla}
%files tla
%defattr(-,root,root)
%doc README
%{perl_vendorlib}/Test/AutoBuild/Repository/GNUArch.pm
%endif

%files account
%defattr(-,root,root)
%doc README
# Builder home
%config(noreplace) %{_sysconfdir}/auto-build.d/auto-build.conf
%dir %attr(-,builder,builder) %{_localstatedir}/lib/builder
%attr(-,builder,builder) %{_localstatedir}/lib/builder/*
%config(noreplace) %attr(-,builder,builder) %{_localstatedir}/lib/builder/.rpmmacros
%config(noreplace) %attr(-,builder,builder) %{_localstatedir}/lib/builder/.cvspass

%changelog