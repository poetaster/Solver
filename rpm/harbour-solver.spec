#
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
#

Name:  harbour-solver

# >> macros
%define _binary_payload w2.xzdio
%define __provides_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
%define __requires_exclude_from ^%{_datadir}/%{name}/lib/.*\\.so\\>
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Summary:    Solver
Version:    0.4.1
Release:    1
Group:      Qt/Qt
License:    GPLv3
URL:        http://github.com/poetaster/Solver
Source0:    %{name}-%{version}.tar.bz2
Requires:   libsailfishapp-launcher
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.2
%if "%{?vendor}" == "chum"
Requires:   python3-sympy
%endif
BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  python3-devel
BuildRequires:  python3-rpm-macros
BuildRequires:  python3-setuptools


%description
Solver - Calculation of mathematical derivatives, integrals, limits and Solvers using Python & SymPy module

%if "%{?vendor}" == "chum"
PackageName: Solver
Type: desktop-application
Categories:
 - Science
 - Utility
DeveloperName: Mark Washeim (poetaster)
Custom:
 - Repo: https://github.com/github.com/poetaster/Solver
Icon: https://raw.github.com/poetaster/Solver/main/icons/172x172/harbour-solver.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/Solver/main/screenshot-002.png
 - https://raw.githubusercontent.com/poetaster/Solver/main/screenshot-003.png
 - https://raw.githubusercontent.com/poetaster/Solver/main/screenshot-001.png
Url:
  Donation: https://www.paypal.me/poetasterFOSS
%endif

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop


cd %{buildroot}%{_datadir}/%{name}/lib/sympy-1.9
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf  %{buildroot}%{_datadir}/%{name}/lib/sympy-1.9

cd %{buildroot}/%{_datadir}/%{name}/lib/mpmath-1.2.1
python3 setup.py install --root=%{buildroot} --prefix=%{_datadir}/%{name}/
rm -rf %{buildroot}/%{_datadir}/%{name}/lib/mpmath-1.2.1

rm -rf %{buildroot}/%{_datadir}/%{name}/share
rm -rf %{buildroot}/%{_datadir}/%{name}/bin

cd %_builddir


%files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
