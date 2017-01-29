package WriterElement;
use utf8;
use strict;
use warnings;
use PDF::API2;

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
  return $self;
}

sub _size {
  my($self, $val) = @_;
  if( $val ){
    $self->{size} = $val;
  }
  return $self->{size};
}


sub _font {
  my($self, $val) = @_;
  if( $val ){
    $self->{font} = $val;
  }
  return $self->{font};
}


sub _x {
  my($self, $val) = @_;
  if( $val ){
    $self->{x} = $val;
  }
  return $self->{x};
}


sub _y {
  my($self, $val) = @_;
  if( $val ){
    $self->{y} = $val;
  }
  return $self->{y};
}


sub _grid {
  my($self, $val) = @_;
  if( $val ){
    $self->{grid} = $val;
  }
  return $self->{grid};
}

sub _currency_column {
  my($self, $val) = @_;
  if( $val ){
    $self->{currency_column} = $val;
  }
  return $self->{currency_column};
}


sub _txt {
  my($self, $val) = @_;
  if( $val ){
    $self->{txt} = $val;
  }
  return $self->{txt};
}

sub _reversed {
  my($self, $val) = @_;
  if( $val ){
    $self->{reversed} = $val;
  }
  return $self->{reversed};
}

sub _multiline {
  my($self, $val) = @_;
  if( $val ){
    $self->{multiline} = $val;
  }
  return $self->{multiline};
}

sub _write_multiline {
  my ($self) = @_;
  my @lines = split( "\n", $self->_multiline );
  my $y = $self->_y;
  for my $l (@lines){
    $self->_text->translate( $self->_x, $y );
    $self->_text->text($l);
    $y -= 15;
  }
  $self->_text->textend();
}

sub _write_currency_column {
  my ($self ) = @_;

  my $x = $self->_x;
  my $y = $self->_y;
  my $init_x = $x;

  for my $cost(@{$self->_currency_column}){
    my $c = $cost ;
    $c =~ s/[.,]//g;
    $self->_write_reversed_with_params( $x, $y, $c );
    $y -= 15.5;
    $x = $init_x;
  }
}


sub _write_reversed {
  my ($self) = @_;
  $self->_write_reversed_with_params(
    $self->_x, 
    $self->_y, 
    $self->_reversed
  );
}

sub _write_reversed_with_params {
  my ($self, $x, $y, $word) = @_;
  my @chars = split('', reverse $word);
  $self->_text->translate( $x, $y);
  for my $char (@chars){
    $self->_text->text( $char );
    $x -= 11;
    $self->_text->translate( $x, $y );
  }
}

sub _write_grid {
  my ($self) = @_;
  my @chars = split('', $self->_grid);
  my ($x, $y) = ($self->_x, $self->_y);
  $self->_text->translate( $x, $y);
  for my $char (@chars){
    $self->_text->text( $char );
    $x += 11;
    $self->_text->translate( $x, $y);
  }
}

sub _write_txt {
  my ($self) = @_;
  $self->_write_txt_with_params( $self->_x, $self->_y, $self->_txt);
}

sub _write_txt_with_params {
  my ($self, $x, $y, $txt) = @_;
  $self->_text->translate( $x, $y);
  $self->_text->text( $txt );
}

sub _text {
  my($self, $val) = @_;
  if( $val ){
    $self->{text} = $val;
  }
  return $self->{text};
}

sub pdf {
  my($self, $val) = @_;
  if( $val ){
    $self->{pdf} = $val;
  }
  return $self->{pdf};
}

sub _get_font {
  my($self) = @_;
  if( $self->_font ){
    return $self->pdf->corefont( $self->_font );
  }
  return $self->pdf->corefont( 'Courier' );
}

sub _get_size {
  my($self) = @_;
  if( $self->_size ){
    return $self->_size;
  }
  return 12;
}

sub _setup {
  my ($self) = @_;

  my $font = $self->_get_font;
  my $size = $self->_get_size;
  my $text = $self->page->text();
  $text->font( $font,$size );
  $self->_text( $text );
}

sub _write {
  my ($self) = @_;
  if( $self->_currency_column ){
    $self->_write_currency_column ;
  }
  elsif( $self->_reversed ){
    $self->_write_reversed ;
  }
  elsif( $self->_grid ){
    $self->_write_grid ;
  }
  elsif( $self->_txt ){
    $self->_write_txt ;
  }
  elsif( $self->_multiline ){
    $self->_write_multiline ;
  }
}

sub write {
  my ($self) = @_;
  $self->_setup;
  $self->_write;
}

sub page {
  my($self, $val) = @_;
  if( $val ){
    $self->{page} = $val;
  }
  return $self->{page};
}


1;
