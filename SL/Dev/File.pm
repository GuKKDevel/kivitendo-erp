package SL::Dev::File;

use strict;
use base qw(Exporter);
our @EXPORT = qw(create_scanned create_uploaded create_created get_all_count get_all get_all_versions delete_all);

use SL::DB::File;

sub create_scanned {
  my (%params) = @_;
  $params{source}    = 'scanner1';
  $params{file_type} = 'document';
  $params{file_path} = '/var/tmp/'.$params{file_name} if !$params{file_path};
  open(OUT,"> ".$params{file_path});
  print OUT $params{file_contents};
  close(OUT);
  delete $params{file_contents};
  my $file = _create_file(%params);
  unlink($params{file_path});
  return $file;
}

sub create_uploaded {
  my (%params) = @_;
  $params{source}    = 'uploaded';
  $params{file_type} = 'attachment';
  return _create_file(%params);
}

sub create_created {
  my (%params) = @_;
  $params{source}    = 'created';
  $params{file_type} = 'document';
  return _create_file(%params);
}

sub _create_file {
  my (%params) = @_;

  my $fileobj = SL::File->save(
    object_id          => 1,
    object_type        => 'sales_order',
    mime_type          => 'text/plain',
    description        => 'Test File',
    file_type          => $params{file_type},
    source             => $params{source},
    file_name          => $params{file_name},
    file_contents      => $params{file_contents},
    file_path          => $params{file_path}
  );
  return $fileobj;
}

sub get_all_count {
  my ($class,%params) = @_;
  $params{object_id}   = 1;
  $params{object_type} = 'sales_order';
  return SL::File->get_all_count(%params);
}

sub get_all {
  my ($class,%params) = @_;
  $params{object_id}   = 1;
  $params{object_type} = 'sales_order';
  SL::File->get_all(%params);
}

sub get_all_versions {
  my ($class,%params) = @_;
  $params{object_id}   = 1;
  $params{object_type} = 'sales_order';
  SL::File->get_all_versions(%params);
}

sub delete_all {
  my ($class,%params) = @_;
  $params{object_id}   = 1;
  $params{object_type} = 'sales_order';
  SL::File->delete_all(%params);
}
1;

__END__

=head1 NAME

SL::Dev::File - create file objects for testing, with minimal defaults

=head1 FUNCTIONS

=head2 C<create_scanned %PARAMS>

=head2 C<create_uploaded %PARAMS>

=head2 C<create_created %PARAMS>

=head2 C<delete_all>

=head1 AUTHOR

Martin Helmling E<lt>martin.helmling@opendynamic.deE<gt>

=cut
