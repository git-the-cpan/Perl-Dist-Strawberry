package Perl::Dist::Strawberry::Step::SetupPerlToolchain;

use 5.012;
use warnings;
use base 'Perl::Dist::Strawberry::Step';

use File::Spec::Functions  qw(catdir catfile rel2abs catpath splitpath);
use File::Path             qw(make_path remove_tree);
use IO::Capture;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  return $self;
}

sub run {
  my $self = shift;
  
  $self->boss->message(2, "SetupPerlToolchain started\n");
  
  my @d = ( catdir($self->global->{image_dir}, qw/cpan/),
            catdir($self->global->{image_dir}, qw/cpanplus/) );
  for (@d) { make_path($_) unless -d $_; }

  #XXX_FIXME duplicate
  my $image_dir = $self->global->{image_dir};
  (my $idq = $image_dir) =~ s|\\|\\|g;
  (my $idu = $image_dir) =~ s|\\|/|g;
  my $tt_vars = {
        image_dir_quotemeta => $idq,
        image_dir_url       => "file://$idu",
        image_dir           => $image_dir,
  };
   
   my $patch = $self->{config}->{install_files};
  if ($patch) {
    while (my ($new, $dst) = each %$patch) {
      $self->_patch_file($self->boss->resolve_name($new), $self->boss->resolve_name($dst), $tt_vars, 1); # 1 = no backup
    }
  }
}
            
sub _xxx_prepare {
       my $self = shift;

       # Squash all output that CPAN might spew during this process
       my $stdout = IO::Capture::Stdout->new();
       my $stderr = IO::Capture::Stderr->new();
       $stdout->start();
       $stderr->start();

       # Load the CPAN client
       require CPAN;
       CPAN->import();

       # Load the latest index
       if (
              eval {
                     local $SIG{__WARN__} = sub {1};
                     if ( not $CPAN::Config_loaded++ ) {
                            CPAN::HandleConfig->load();
                     }
                     $CPAN::Config->{'urllist'}    = [ $self->_get_cpan() ];
                     $CPAN::Config->{'use_sqlite'} = q[0];
                     CPAN::Index->reload();
                     1;
              } )
       {
              $stdout->stop();
              $stderr->stop();
              return 1;
       } else {
              $stdout->stop();
              $stderr->stop();
              return 0;
       }
}

sub _xxx_run {
       my $self = shift;

       # Squash all output that CPAN might spew during this process
       my $stdout = IO::Capture::Stdout->new();
       my $stderr = IO::Capture::Stderr->new();
       $stdout->start();
       $stderr->start();

       if ( not $CPAN::Config_loaded++ ) {
              CPAN::HandleConfig->load();
       }
       $CPAN::Config->{'urllist'}    = [ $self->_get_cpan() ];
       $CPAN::Config->{'use_sqlite'} = q[0];
       $stdout->stop();
       $stderr->stop();

       foreach
         my $name ( @{ $self->_get_modules( $self->_get_perl_version() ) } )
       {

              # Shortcut if forced
              if ( $self->_force_exists($name) ) {
                     $self->_push_dists( $self->_get_forced_dist($name) );
                     next;
              }

              # Get the CPAN object for the module, covering any output.
              $stdout->start();
              $stderr->start();
              my $module = CPAN::Shell->expand( 'Module', $name );
              $stdout->stop();
              $stderr->stop();

              if ( not $module ) {
                     ## no critic (RequireCarping RequireUseOfExceptions)
                     die "Failed to find '$name'";
              }

              # Ignore modules that don't need to be updated
              my $core_version = $self->_get_corelist($name);
              if ( defined $core_version and $core_version =~ /_/ms ) {

                     # Sometimes, the core contains a developer
                     # version. For the purposes of this comparison
                     # it should be safe to "round down".
                     $core_version =~ s{_.+}{}ms;
              }
              my $cpan_version = $module->cpan_version;
              if ( not defined $cpan_version ) {
                     next;
              }
              if ( defined $core_version and $core_version >= $cpan_version ) {
                     next;
              }

              # Filter out already seen dists
              my $file = $module->cpan_file;
              $file =~ s{\A [[:upper:]] / [[:upper:]][[:upper:]] /}{}msx;
              $self->_push_dists($file);
       }

       # Remove duplicates
       my %seen = ();
       my @dists = $self->_grep_dists( sub { !$seen{$_}++ } );

       $self->_empty_dists();
       $self->_push_dists(@dists);

       return 1;
}

1;