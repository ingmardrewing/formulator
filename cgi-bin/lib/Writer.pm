package Writer;
use utf8;
use strict;
use warnings;
use PDF::API2;

use FindBin;
use lib "$FindBin::Bin/lib";
use WriterPage;

sub new {
  my $class = shift;

  my $self = {};
  bless $self, $class;

  my $params = shift;
  return $self->_init($params);
}

sub _init {
  my ($self, $params) = @_;
  for my $k ( keys %$params ){
    $self->{$k} = $params->{$k};
  }
  $self->{pages} = [];
  return $self;
}

sub add_page {
  my ($self, $page) = @_;
  my $p = WriterPage->new( $page );
  push(@{$self->_pages}, $p);
}

sub _pages {
  my($self, $val) = @_;
  if( $val ){
    $self->{pages} = $val;
  }
  return $self->{pages};
}

sub _pdf {
  my($self, $val) = @_;
  if( $val ){
    $self->{pdf} = $val;
  }
  return $self->{pdf};
}



sub _doc_dir {
  my($self, $val) = @_;
  if( $val ){
    $self->{doc_dir} = $val;
  }
  return $self->{doc_dir};
}


sub _filename {
  my($self, $val) = @_;
  if( $val ){
    $self->{filename} = $val;
  }
  return $self->{filename};
}

sub _compress {
  my ($self, $val) = @_;
  if( $val ){
    $self->{compress} = $val;
  }
  return $self->{compress};
}

sub _write {
  my ($self) = @_;

  my $c = 0;
  for my $p ( @{ $self->_pages } ){
     $p->pdf( $self->_pdf );
     $p->write;
  }
}

sub write {
  my ($self) = @_;

  $self->_setup;
  $self->_write;
  $self->_finish;
}

sub _setup {
  my ($self) = @_;

  $self->_pdf( PDF::API2->new( -file => $self->_filename ) );
  $self->_pdf->mediabox('A4');
}

sub _finish {
  my ($self) = @_;
  $self->_pdf->save();
}



1;
