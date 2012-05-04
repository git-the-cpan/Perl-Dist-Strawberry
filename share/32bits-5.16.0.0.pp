### job description for building strawberry-perl-5.14.3.0

# <package_url>   is placeholder for http://strawberryperl.com/package
# <dist_sharedir> is placeholder for Perl::Dist::Strawberry's distribution sharedir
# <image_dir>     is placeholder for c:\strawberry
{
  version => '5.14.3.0',
  bits => 32,
  stage_zip_steps => [
    ### STEP 1 ###########################
    {
        plugin  => 'Perl::Dist::Strawberry::Step::BinaryToolsAndLibs',
        install_packages => {
            'dmake'         => '<package_url>/kmx/32_tools/32bit_dmake-SVN20091127-bin_20111107.zip',
            'mingw-make'    => '<package_url>/kmx/32_tools/32bit_gmake-3.82-bin_20110503.zip',
            'pexports'      => '<package_url>/kmx/32_tools/32bit_pexports-0.44-bin_20100110.zip',
            'patch'         => '<package_url>/kmx/32_tools/32bit_patch-2.5.9-7-bin_20100110_UAC.zip',
            'gcc-toolchain' => { url=>'<package_url>/kmx/32_gcctoolchain/mingw64-w32-gcc4.4.7-pre_20111101.zip', install_to=>'c' },
            'gcc-license'   => '<package_url>/kmx/32_gcctoolchain/mingw64-w32-gcc4.4.7-pre_20111101-lic.zip',
            'libdb'         => '<package_url>/kmx/32_libs/5.14/32bit_db-5.1.25-bin_20110506.zip',
            'libexpat'      => '<package_url>/kmx/32_libs/5.14/32bit_expat-2.0.1-sezero20110428-bin_20110506.zip',
            'freeglut'      => '<package_url>/kmx/32_libs/5.14/32bit_freeglut-2.6.0-bin_20110506.zip',
            'libfreetype'   => '<package_url>/kmx/32_libs/5.14/32bit_freetype-2.4.4-bin_20110506.zip',
            'libgd'         => '<package_url>/kmx/32_libs/5.14/32bit_gd-2.0.35(OLD-jpg-png)-bin_20110506.zip',
            'libgdbm'       => '<package_url>/kmx/32_libs/5.14/32bit_gdbm-1.8.3-bin_20110506.zip',
            'libgif'        => '<package_url>/kmx/32_libs/5.14/32bit_giflib-4.1.6-bin_20110506.zip',
            'gmp'           => '<package_url>/kmx/32_libs/5.14/32bit_gmp-5.0.1-bin_20110506.zip',
            'libjpeg'       => '<package_url>/kmx/32_libs/5.14/32bit_jpeg-8c-bin_20110506.zip',
            'libxpm'        => '<package_url>/kmx/32_libs/5.14/32bit_libXpm-3.5.9-bin_20110506.zip',
            'libiconv'      => '<package_url>/kmx/32_libs/5.14/32bit_libiconv-1.13.1-sezero20110428-bin_20110506.zip',
            'libpng'        => '<package_url>/kmx/32_libs/5.14/32bit_libpng-1.5.2-bin_20110506.zip',
            'libssh2'       => '<package_url>/kmx/32_libs/5.14/32bit_libssh2-1.2.8-bin_20110506.zip',
            'libxml2'       => '<package_url>/kmx/32_libs/5.14/32bit_libxml2-2.7.8-bin_20110506.zip',
            'libxslt'       => '<package_url>/kmx/32_libs/5.14/32bit_libxslt-1.1.26-bin_20110506.zip',
            'mpc'           => '<package_url>/kmx/32_libs/5.14/32bit_mpc-0.9-bin_20110506.zip',
            'mpfr'          => '<package_url>/kmx/32_libs/5.14/32bit_mpfr-3.0.1-bin_20110506.zip',
            'libmysql'      => '<package_url>/kmx/32_libs/5.14/32bit_mysql-5.1.44-bin_20100304.zip',
            'libopenssl'    => '<package_url>/kmx/32_libs/5.14/32bit_openssl-1.0.0d-bin_20110506.zip',
            'libpostgresql' => '<package_url>/kmx/32_libs/5.14/32bit_postgresql-9.0.4-bin_20110506.zip',
            'libtiff'       => '<package_url>/kmx/32_libs/5.14/32bit_tiff-3.9.5-bin_20110506.zip',
            'libxz'         => '<package_url>/kmx/32_libs/5.14/32bit_xz-5.0.2-bin_20110506.zip',
            'zlib'          => '<package_url>/kmx/32_libs/5.14/32bit_zlib-1.2.5-bin_20110506.zip',
        },
    },
    ### STEP 2 ###########################
    {
        plugin   => 'Perl::Dist::Strawberry::Step::InstallPerlCore',
        url      => 'http://perl5.git.perl.org/perl.git/snapshot/76b80f303d1af358e809523ad84510169ea3bce2.tar.gz',
        cf_email => 'strawberry-perl@project',
        patch    => { #DST paths are relative to the perl src root
            '<dist_sharedir>/perl-5.16/win32_config.gc.tt'      => 'win32/config.gc',
            '<dist_sharedir>/perl-5.16/win32_config.gc64nox.tt' => 'win32/config.gc64nox',
            '<dist_sharedir>/perl-5.16/win32_config_H.gc'       => 'win32/config_H.gc',
            '<dist_sharedir>/perl-5.16/win32_config_H.gc64nox'  => 'win32/config_H.gc64nox',
            '<dist_sharedir>/perl-5.16/win32_FindExt.pm'        => 'win32/FindExt.pm',
            '<dist_sharedir>/perl-5.16/NDBM_MSWin32.pl'         => 'ext/NDBM_File/hints/MSWin32.pl',
            '<dist_sharedir>/perl-5.16/ODBM_MSWin32.pl'         => 'ext/ODBM_File/hints/MSWin32.pl',
        },
        license => { #SRC paths are relative to the perl src root
            'Readme'   => '<image_dir>/licenses/perl/Readme',
            'Artistic' => '<image_dir>/licenses/perl/Artistic',
            'Copying'  => '<image_dir>/licenses/perl/Copying',
        },
    },
    ### STEP 3 ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::SetupPerlToolchain',
        install_files => {
            '<dist_sharedir>/perl-5.16/CPAN_Config.pm.tt' => '<image_dir>/perl/lib/CPAN/Config.pm',
            '<dist_sharedir>/perl-5.16/CPANPLUS_Config.pm.tt' => '<image_dir>/perl/lib/CPANPLUS/Config.pm',
        }
    },
    ### STEP 4 ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::UpgradeCpanModules',
        # no config at the moment
    },
    ### STEP 5 ###########################
    {
        plugin => 'Perl::Dist::Strawberry::Step::InstallModules',
        modules => [
            # term related
            'http://search.cpan.org/CPAN/authors/id/S/ST/STSI/TermReadKey-2.30.02.tar.gz', # special version needed - on CPAN marked as ** UNAUTHORIZED RELEASE **
            #qw/ Term::ReadLine::Perl /, # XXX-TODO not sure about this, do not know how to make the installation non-interactive
            { module=>'Term::ReadLine::Perl', env=>{ PERL_MM_NONINTERACTIVE=>1 } },
        
            # compression
            qw/ Archive-Zip IO-Compress-Lzma Compress-unLZMA/,

            # file related
            { module=>'File-Slurp', ignore_testfailure=>1 }, #XXX-TODO: File-Slurp-9999.19 test FAILS
            qw/ File-Find-Rule          File-HomeDir            File-Listing            File-Remove
                File-ShareDir           File-Which              File-Copy-Recursive /,

            # database stuff
            qw/ DBI DBD-ODBC DBD-SQLite DBD-Pg DBIx-Simple /,
            { module=>'DBD-ADO', ignore_testfailure=>1 }, #XXX-TODO: DBD-ADO-2.99 test FAILS
            { 
              module => 'http://strawberryperl.com/package/kmx/perl-modules-patched/DBD-mysql-4.020_patched_h.tar.gz', 
              #the following does not work
              #module => 'http://strawberryperl.com/package/kmx/perl-modules-patched/DBD-mysql-4.020_patched.tar.gz', 
              #makefilepl_param => '--mysql_config=mysql_config',
            },
            #XXX FIXME - makefilepl_param does not work
            #perl z:\strawberry_build\BR_Perl-Dist-Strawberry\share\utils\CPANPLUS_install_module.pl -module http://strawberryperl.com/package/kmx/perl-modules-patched/DBD-mysql-4.020_patched.tar.gz -makefilepl_param "--mysql_config=mysql_config"

            # math related
            qw/ Math-BigInt-GMP Math-GMP Math-MPC Math-MPFR Math-Pari /,

            # crypto
            'http://strawberryperl.com/package/kmx/perl-modules-patched/Crypt-IDEA-1.08_patched.tar.gz',
            'http://strawberryperl.com/package/kmx/perl-modules-patched/Crypt-Blowfish-2.12_patched.tar.gz',
            #'Crypt-DH',
            'Crypt-OpenPGP',
            { module => 'Module-Signature' }, #XXX-TODO skip on64bit

            # network
            qw/ LWP-Protocol-https LWP::UserAgent /,
            
            # digests
            qw/ Digest-BubbleBabble Digest-HMAC Digest-MD2 Digest-SHA1 /,

            # SSL & SSH
            qw/ Net-SSLeay Crypt-SSLeay Net-SSH2 IO-Socket-SSL Net-SMTP-TLS /,


            # win32 related
            { module=>'Win32API-Registry', ignore_testfailure=>1 }, #XXX-TODO: Win32API-Registry-0.32 test FAILS
            { module=>'Win32-TieRegistry', ignore_testfailure=>1 }, #XXX-TODO: Win32-TieRegistry-0.26 test FAILS
            qw/ Win32-API               Win32-EventLog          Win32-Exe               Win32-OLE
                Win32-Process           Win32-WinError          Win32-File-Object       Win32-UTCFileTime /,

            # graphics
            'http://strawberryperl.com/package/kmx/perl-modules-patched/GD-2.46_patched.tar.gz',
            qw/ Imager                  Imager-File-GIF         Imager-File-JPEG        Imager-File-PNG
                Imager-File-TIFF        Imager-Font-FT2         Imager-Font-W32 /,

            # XML
            qw/ XML-LibXML XML-LibXSLT XML-Parser XML-SAX XML-Simple SOAP-Lite /,

            # YAML, JSON & co.
            { module=>'YAML', ignore_testfailure=>1 }, #XXX-TODO: YAML-LibYAML-0.38 test FAILS
            qw/ JSON JSON::XS YAML::XS YAML-Tiny /,

            # dbm related
            qw/ BerkeleyDB DB_File DBM-Deep /,

            # utils
            qw/ pler App-local-lib-Win32Helper /,
            { module=>'pip', ignore_testfailure=>1 }, #XXX-TODO: test fails - The directory 'C:\strawberry\cpan\sources' does not exist

            # par & ppm
            qw/ PAR PAR::Dist::FromPPD PAR::Dist::InstallPPD PAR::Repository::Client/,
            'http://svn.ali.as/cpan/trunk/Perl-Dist-Strawberry/share/modules/PPM-0.01_03.tar.gz',
            
            # tiny
            qw/ Capture-Tiny /,
            
            # misc
            qw/ CPAN::SQLite Alien-Tidyp Data-Dump FCGI Text-Diff Text-Patch /,
            qw/ IO-stringy IO::String String-CRC32 Sub-Uplevel Convert-PEM/,
            qw/ IPC-Run3 IPC-Run IPC-System-Simple /,
            
            # strawberry extras
            'http://strawberryperl.com/package/kmx/perl-modules-patched/App-module-version-1.003.tar.gz',

        ],
    },
    ### STEP 6 ###########################
    {
       plugin => 'Perl::Dist::Strawberry::Step::FilesAndDirs',

       commands => [
         { apply_tt     => [ 'src.tt', 'destination_file', {e=>1, f=>2} ] },
         { apply_patch  => [ 'src.diff', 'destination_file' ] },
         { apply_sed    => [ 'destination_file', 'pattern1', 'pattern2' ] },
         { removefile   => [ 'file1', 'file2' ] },
         { copyfile     => [ 'from', 'to' ] },
         { removedir    => [ 'dir1', 'dir2' ] },
         { createdir    => [ 'dir1', 'dir2' ] },
         { copydir      => [ 'from', 'to' ] },
       ],
    },
  ],
}