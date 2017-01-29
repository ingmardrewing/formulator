package WriterPage;
use utf8;
use strict;
use warnings;
use PDF::API2;

use FindBin;
use lib "$FindBin::Bin/lib";
use WriterElement;

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

sub _elements {
  my($self, $val) = @_;
  if( $val ){
    $self->{elements} = $val;
  }
  return $self->{elements};
}

sub _template {
  my($self, $val) = @_;
  if( $val ){
    $self->{template} = $val;
  }
  return $self->{template};
}

sub pdf {
  my($self, $val) = @_;
  if( $val ){
    $self->{pdf} = $val;
  }
  return $self->{pdf};
}

sub _create_page {
  my($self) = @_;
  if( $self->_template ){
    my $templ_pdf = PDF::API2->open( $self->_template);
    $self->pdf->importpage( $templ_pdf, 1 )
  }
  else{
    $self->pdf->page();
  }
}

sub write {
  my ($self) = @_;

  $self->_create_page();
  my $page = $self->pdf->openpage(-1);
  for my $e ( @{ $self->_elements } ){
    my $we = WriterElement->new($e);
    $we->page( $page );
    $we->pdf( $self->pdf );
    $we->write;
  }
}

1;
