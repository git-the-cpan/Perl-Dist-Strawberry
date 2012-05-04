package Perl::Dist::Strawberry::Step::BinaryToolsAndLibs;

use 5.012;
use warnings;
use base 'Perl::Dist::Strawberry::Step';

use Data::Dump             qw(pp);
use File::Path             qw(make_path remove_tree);
use File::Spec::Functions  qw(catdir catfile rel2abs catpath);
use File::pushd            qw();
#use File::List::Object;
use Archive::Zip           qw( AZ_OK );
use Archive::Tar           qw();
#use File::Basename             qw();
#use File::Find::Rule           qw();
#use File::Path            2.08 qw();
#use File::Slurp                qw(read_file);
#use IO::Compress::Bzip2  2.025 qw();
#use IO::Compress::Gzip   2.025 qw();

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  return $self;
}

sub check {
  my $self = shift;
  
  if ($self->global->{bits} != 32 && $self->global->{bits} != 64) { #XXX-TODO MOVE SOMEWHERE ELSE
    die "ERROR: invalid 'bits' value [".$self->global->{bits}."]\n";
  }
  
  my $pkgs = $self->{config}->{install_packages};
  my $invalid_url_found = 0;
  for my $p (keys %$pkgs) {
    my $url = ref $pkgs->{$p} ? $pkgs->{$p}->{url} : $pkgs->{$p};
    $url = $self->boss->resolve_name($url);
    if (!$self->boss->test_url($url)) {
      $self->boss->message(0, "ERROR: invalid URL '$url'\n");
      $invalid_url_found = 1;
    }
  }
  if ($invalid_url_found) {
    die "ERROR: invalid URL(s) found, cannot continue\n";
  }
  
  #XXX-FIXME add more checks
  
  return 1;
}

sub run {
  my $self = shift;

  #my %files;
  my $pkgs = $self->{config}->{install_packages};
  for my $p (keys %$pkgs) {
    my $f = $self->_install($p, $pkgs->{$p});
    #XXX remove File::List::Object
    #XXX $self->boss->message(5, "pkg='$p' files_count=".$f->count."\n");
    #XXX $files{$p} = $f;
    $self->boss->message(5, "pkg='$p'");
  }
  
  #store results
  #XXX-FIXME: $self->{data}->{output}->{files} = \%files;
}

sub _install {
  my ($self, $name, $data) = @_;
  $self->boss->message(1, "installing package '$name'\n");

  my $url        = ref $data ? $data->{url} : $data;
  my $install_to = ref $data ? $data->{install_to} : ''; # relative to image_dir
  my $licenses   = ref $data ? $data->{license} : '';

  # Download the file
  $url = $self->boss->resolve_name($url);
  my $tgz = $self->boss->mirror_url($url, $self->global->{download_dir});

  # Unpack the archive
  my @files;
  if (ref $install_to eq 'HASH') {
    @files = $self->_extract_filemap($tgz, $install_to, $self->global->{image_dir});
  }
  elsif (!ref $install_to) {
    # unpack as a whole
    my $tgt = catdir($self->global->{image_dir}, $install_to);
    @files = $self->_extract($tgz, $tgt);
  }

  # Find the licenses
  if ($licenses) {
    push @files, $self->_extract_filemap($tgz, $licenses, catdir($self->global->{image_dir}, 'licenses'), 1);
  }

  #XXX-REMOVE File::List::Object
  #XXX my $filelist = File::List::Object->new()->load_array(@files)->filter( $self->_filters ); #XXX-FIXME reimplement without moose
  #XXX return $filelist;
}

sub _filters {
  my $self = shift;
  return [ catdir ($self->global->{working_dir}) . "\\",

           catdir ($self->global->{image_dir}, qw{ perl man         } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ perl html        } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    man         } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    doc         } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    info        } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    contrib     } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    html        } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    examples    } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    manifest    } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ cpan sources     } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ cpan build       } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    bin         startup mac   } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    bin         startup msdos } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    bin         startup os2   } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    bin         startup qssl  } ) . "\\",
           catdir ($self->global->{image_dir}, qw{ c    bin         startup tos   } ) . "\\",

           catfile($self->global->{image_dir}, qw{ c    COPYING     } ),
           catfile($self->global->{image_dir}, qw{ c    COPYING.LIB } ),
           catfile($self->global->{image_dir}, qw{ c    bin         gccbug  } ),
           catfile($self->global->{image_dir}, qw{ cpan FTPstats.yml  } ),
           catfile($self->global->{image_dir}, qw{ cpan cpandb.sql    } ),
  ];
}

1;