package Perl::Dist::Bootstrap;

=pod

=head1 NAME

Perl::Dist::Bootstrap - A Perl distribution for building Perl distributions

=head1 DESCRIPTION

Bootstrap Perl is a subclass and variant of Strawberry Perl that installs
into a different directory (C:\bootperl) than Strawberry Perl so that
it won't be "in the way" when building Strawberry and other Perls.

It also comes prepackaged with a number of additional modules that are
dependencies of Perl::Dist and Perl::Dist::WiX.

=cut

use 5.008001;
use strict;
use warnings;
use parent                  qw( Perl::Dist::Strawberry );
use File::Spec::Functions   qw( catfile catdir         );
use File::ShareDir          qw();

our $VERSION = '2.1001';
$VERSION =~ s/_//ms;



#####################################################################
# Configuration

# Apply some default paths
sub new {

	if ($Perl::Dist::Strawberry::VERSION < 2.10) {
		PDWiX->throw('Perl::Dist::Strawberry version is not high enough.')
	}
	if ($Perl::Dist::WiX::VERSION < 1.200) {
		PDWiX->throw('Perl::Dist::WiX version is not high enough.')
	}

	shift->SUPER::new(
		app_id            => 'bootperl',
		app_name          => 'Bootstrap Perl',
		app_publisher     => 'Vanilla Perl Project',
		app_publisher_url => 'http://vanillaperl.org/',
		image_dir         => 'C:\\bootperl',
		perl_version      => '5101',

		# Tasks to complete to create Bootstrap
		tasklist => [
			'final_initialization',
			'initialize_nomsm',
			'install_c_toolchain',
			'install_strawberry_c_toolchain',
			'install_strawberry_c_libraries',
			'install_perl',
			'install_perl_toolchain',
			'install_cpan_upgrades',
			'install_strawberry_modules_1',
			'install_strawberry_modules_2',
			'install_strawberry_modules_3',
			'install_strawberry_modules_4',
			'install_strawberry_modules_5',
			'install_bootstrap_modules_1',
			'install_bootstrap_modules_2',
			'install_win32_extras',
			'install_strawberry_extras',
			'remove_waste',
			'create_distribution_list',
			'regenerate_fragments',
			'write',
		],

		# Build msi version only. Do not create a merge module.
		msi               => 1,
		zip               => 0,
		msm               => 0,

		@_,
	);
}



# Lazily default the file name
# Supports building multiple versions of Perl.
sub output_base_filename {
	$_[0]->{output_base_filename} or
	'bootstrap-perl' 
	. '-' . $_[0]->perl_version_human() 
	. '.' . $_[0]->build_number()
	. ($_[0]->beta_number() ? '-beta-' . $_[0]->beta_number : '');
}



#####################################################################
# Customisations for Perl assets

sub patch_include_path {
	my $self  = shift;

	# Find the share path for this distribution
	my $share = File::ShareDir::dist_dir('Perl-Dist-Strawberry');
	my $path  = catdir( $share, 'bootstrap' );
	unless ( -d $path ) {
		PDWiX->throw("Directory $path does not exist");
	}

	# Prepend it to the default include path
	return [ $path,
		@{ $self->SUPER::patch_include_path },
	];
}



sub install_bootstrap_modules_1 {
	my $self = shift;
	my $share = File::ShareDir::dist_dir('Perl-Dist-Strawberry');

	# Install a "cheat" version of Alien::WiX that yells on import
	# to require a real installation.
	$self->install_distribution_from_file(
	    mod_name      => 'Alien::WiX',
	    file          => catfile($share, 'modules', 'Alien-WiX-0.300000.tar.gz'),
		buildpl_param => ['--installdirs', 'vendor'],
	);

	# Install everything required for Perl::Dist::WiX itself
	$self->install_modules( qw(
		File::Copy::Recursive
		Class::Inspector
		File::ShareDir
		File::PathList
		Error
		Cache::Cache
		LWP::UserAgent::WithCache
		Object::Tiny
		Process
		IO::Capture
		Test::LongString
		Module::ScanDeps
		Module::Install
		Module::Install::AuthorTests
		Module::Install::PerlTar
		Tie::Slurp
		File::IgnoreReadonly
		Portable::Dist
		List::MoreUtils
		AppConfig
		Template
	) );
	
	# Data::UUID needs to have a temp directory set that will
	# exist in the installation image.
	{
		local $ENV{'TMPDIR'} = $self->image_dir();
		$self->install_module( name => 'Data::UUID', );
	}

	return 1;
}



sub install_bootstrap_modules_2 {
	my $self = shift;
	
	$self->install_modules( qw(
		Sub::Install
		Data::OptList
		Sub::Exporter
		Test::Output
		Devel::StackTrace
		Class::Data::Inheritable
		Exception::Class
		Test::UseAllModules
		ExtUtils::Depends
		B::Utils
		PadWalker
		Data::Dump::Streamer
		Readonly
		Readonly::XS
		Regexp::Common
		Pod::Readme
		Algorithm::C3
		Class::C3
		MRO::Compat
		Scope::Guard
		Devel::GlobalDestruction
		Sub::Name
		Try::Tiny
		Class::MOP
		Moose
		MooseX::AttributeHelpers
		File::List::Object
		Params::Validate
		MooseX::Singleton
		MooseX::NonMoose
		Variable::Magic
		B::Hooks::EndOfScope
		Sub::Identify
		namespace::clean
		Carp::Clan
		MooseX::Types
		Path::Class
		MooseX::Types::Path::Class
		URI::FromHash
		Test::use::ok
		MooseX::Types::URI
		Email::Date::Format
		Date::Format
		Test::Pod
		Mail::Address
		MIME::Types
	) );
	# The current version of MIME::Types causes
	# MIME::Lite to fail tests.
	$self->install_module(
		name => 'MIME::Lite',
		force => 1,
	);
	$self->install_modules( qw(
		Clone
		Digest::CRC
		WiX3
		CPAN::Mini
		CPAN::Mini::Devel
	) );

	# Since we're using the "fake" Alien::WiX, we have to force here.
	$self->install_distribution(
		name     => 'CSJEWELL/Perl-Dist-WiX-1.200.tar.gz',
		mod_name => 'Perl::Dist::WiX',
		force    => 1,
		makefilepl_param => ['INSTALLDIRS=vendor'],
	);

	# Install stuff required to test Perl::Dist::Strawberry and 
	# Perl::Dist::WiX in author mode.
	$self->install_module(
		name => 'File::Finder',
		force => 1,	# fails tests.
	);
	$self->install_distribution(
		name     => 'GAM/Test-CheckChanges-0.14.tar.gz', # CPAN cannot extract.
		mod_name => 'Test::CheckChanges',
		force    => 1,
		makefilepl_param => ['INSTALLDIRS=vendor'],
	);
	$self->install_modules( qw(
		File::Find::Rule::Perl
		Test::Object
		Hook::LexWrap
		Test::SubCalls
	) );
	$self->install_distribution(
		name     => 'ADAMK/PPI-1.211_01.tar.gz',
		mod_name => 'PPI',
		makefilepl_param => ['INSTALLDIRS=vendor'],
	);		
	$self->install_modules( qw(
		Module::Manifest
		Module::Info
		Perl::Tidy
		PPIx::Regexp
		Email::Address
		B::Keywords
		Pod::Spell
		Pod::Spell::CommonMistakes
		String::Format
		PPIx::Utilities
		Config::Tiny
		Devel::Symdump
		Pod::Coverage
	) );
	$self->install_distribution(
		name     => 'GAM/Test-CheckChanges-0.14.tar.gz', # CPAN cannot extract.
		mod_name => 'Test::CheckChanges',
		force    => 1,
		makefilepl_param => ['INSTALLDIRS=vendor'],
	);
	$self->install_distribution(
		name     => 'THALJEF/Perl-Critic-1.105_03.tar.gz',
		mod_name => 'Perl::Critic',
		buildpl_param => ['--installdirs', 'vendor'],
	);
	$self->install_modules( qw(
		Perl::MinimumVersion
		Perl::Critic::More
		Test::Perl::Critic
		Test::Pod::Coverage
		Test::MinimumVersion
		Test::Fixme
		Test::HasVersion
		Test::CPAN::Meta
		Test::DistManifest
		Test::Prereq
		Test::Pod::Spelling::CommonMistakes
	) );
	
	return 1;
}

1;

=pod

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Dist-Strawberry>

Please note that B<only> bugs in the distribution itself or the CPAN
configuration should be reported to RT. Bugs in individual modules
should be reported to their respective distributions.

For more support information and places for discussion, see the
Strawberry Perl Support page L<http://strawberryperl.com/support.html>.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Curtis Jewell E<lt>csjewell@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2007 - 2009 Adam Kennedy.  

Copyright 2009 - 2010 Curtis Jewell.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
