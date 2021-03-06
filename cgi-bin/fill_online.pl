#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use POSIX qw(strftime);
use CGI qw/-utf8 :standard/;
use URI::Escape;

use FindBin;
use lib "$FindBin::Bin/lib";
use Writer;
use YAML::Tiny;

my $conf = YAML::Tiny->read('conf/conf.yaml')->[0];

my @templates = (
  $conf->{'template_1'},
  $conf->{'template_2'},
  $conf->{'template_3'},
  $conf->{'template_4'}
);

my @fields = qw(
  von_datum
  bis_datum

  sender

  addr_debeka

  vorname
  nachname
  strasse_nr
  plz_ort
  geb_dots

  service_nr
  personalnummer

  arzneimittel_1
  arzneimittel_2
  arzneimittel_3
  arzneimittel_4
  arzneimittel_5
  arzneimittel_8
  arzneimittel_7

  ambulante_behandlung_1
  ambulante_behandlung_2
  ambulante_behandlung_3
  ambulante_behandlung_4
  ambulante_behandlung_5
  ambulante_behandlung_6
  ambulante_behandlung_7
  ambulante_behandlung_8
  ambulante_behandlung_9

  krankenhaus_1
  krankenhaus_2

  zahnbehandlung_1
  zahnbehandlung_2

  sonstiges_1
  sonstiges_2

  pflege_1
  pflege_2
  pflege_3

);

# Get get parameters
my $q = CGI->new;
my $sender        = get_value('sender');
my $addr_debeka   = get_value('addr_debeka');

my $vorname    = get_value('vorname') ;
my $nachname   = get_value('nachname');
my $strasse_nr = get_value('strasse_nr');
my $plz_ort    = get_value('plz_ort') ;
my $geb_dots   = get_value('geb_dots');

my $service_nr     = get_value('service_nr')  ;
my $personalnummer = get_value('personalnummer');

my $arzneimittel         = get_avalue('arzneimittel') ;
my $ambulante_behandlung = get_avalue('ambulante_behandlung');
my $krankenhaus          = get_avalue('krankenhaus');
my $zahnbehandlung       = get_avalue('zahnbehandlung');
my $sonstiges            = get_avalue('sonstiges');
my $pflege               = get_avalue('pflege');

my $von_datum  = get_value('von_datum');
my $bis_datum  = get_value('bis_datum');

# preprare data
my $is_bevm = 1;
my $bevollmaechtigter = $is_bevm ? '_' x 13 : '' ;
my $bevollmaechtigter_debeka = $is_bevm ? '(Bevollmächtigter)' : '' ;

my $geb = join('',($geb_dots =~ m{(\d+)}g));

my $pflege_kreuz = $von_datum && $bis_datum ? '×' : '' ;
my @all_amounts  = ( @$arzneimittel, @$ambulante_behandlung,
                     @$krankenhaus,  @$zahnbehandlung,
                     @$sonstiges,    @$pflege               );
my $cent_sum = 0;
my $anzahl_belege = @all_amounts;
for my $a (@all_amounts){
  $a =~ s{[,.]}{}g;
  $cent_sum += $a;
}
my $euro_sum = (join ',',($cent_sum =~ m/(\d*)(\d\d)/));

my $datum_underscore =  strftime "%e_%m_%Y", localtime;
my $datum_dots       =  strftime "%e.%m.%Y", localtime;
my $dir         = 'filled_forms';
my $filename    = sprintf 'leistungs_antrag_%s.pdf', $datum_underscore;

# pprepare pdf generation
my $w = Writer->new({
  filename => '../filled_forms/' . $filename,
  compress => 1,
});

$w->add_page({
  template => $templates[0],
  elements => [
    { x => 50, y => 680, txt => $sender, font => 'Arial', size => 7 },
    { x => 50, y => 663, multiline => $addr_debeka, font=> 'Arial'},
  ],
});

$w->add_page({
  template => $templates[1],
  elements => [
    { x => 65,  y => 778, txt => $service_nr },
    { x => 52,  y => 760, txt => $vorname . ' ' . $nachname },
    { x => 52,  y => 742, txt => $strasse_nr },
    { x => 60,  y => 726, txt => $plz_ort },
    { x => 314, y => 680, txt => $datum_dots },
    { x => 394, y => 665, txt => $bevollmaechtigter_debeka, size => 9 },
    { x => 122, y => 494, grid => uc $vorname },
    { x => 122, y => 476, grid => $geb },
    { x => 200, y => 440, currency_column => $arzneimittel },
    { x => 200, y => 332, currency_column => $ambulante_behandlung},
    { x => 200, y => 190, currency_column => $krankenhaus  },
    { x => 200, y => 160, currency_column => $zahnbehandlung  },
    { x => 200, y => 130, currency_column => $sonstiges  },
    { x => 200, y => 98, currency_column => $pflege  },
    { x => 200, y => 36, currency_column => [$cent_sum] },
  ],
});

$w->add_page({
  template => $templates[2],
  elements => [
    { x => 68,  y => 676, txt => $sender, size => 7, font=>'Arial'},
    { x => 58,  y => 261, txt => $pflege_kreuz },
    { x => 340, y => 260, txt => $von_datum },
    { x => 475, y => 260, txt => $bis_datum },
    { x => 205, y => 188, txt => $euro_sum },
    { x => 105, y => 788, txt => $personalnummer },
    { x => 405, y => 703, txt => $vorname },
    { x => 405, y => 678, txt => $nachname },
    { x => 405, y => 653, txt => $geb_dots },
    { x => 405, y => 628, txt => $strasse_nr },
    { x => 405, y => 595, txt => $plz_ort },
    { x => 465, y => 188, txt => $anzahl_belege },
  ],
});

$w->add_page({
  template => $templates[3],
  elements => [
    { x => 85,  y => 788, txt => $personalnummer },
    { x => 335, y => 788, txt => $nachname },
    { x => 205, y => 788, txt => $vorname },
    { x => 110, y => 228, txt => $datum_dots },
    { x => 340, y => 214, txt => $bevollmaechtigter },
    { x => 440, y => 206, txt => $bevollmaechtigter },
  ],
});

# print html data
print $q->header( '-type' => 'text/html', '-charset' => 'UTF-8');
print html_output();

# create pdfs
$w->write;

sub html_output {
  my $tmpl = html_template();

  my @values = map {
    get_value( $_ );
  } @fields;

  return sprintf $tmpl, get_link(),  @values;
}

sub get_link {
  my $file_linkpath = '../filled_forms/' . $filename ;
  if( -e $file_linkpath ){
    return sprintf "<a href='%s' style='background-color:blue; color: white; font-weight: bold; display:inline-block; border-radius: 5px; padding:15px; margin-bottom: 20px; font-family: Helvetica, Verdana, Arial, sans-serif; text-decoration: none;' target='_blank'>download PDF</a><br />", $file_linkpath;
  }
  return '';
}

sub get_value {
  my( $param_name ) = @_;
  my $v = $q->param( $param_name ) // '';
  if( $v =~ m{%}){
    return uri_unescape( $v );
  }
  return $v;
}

sub get_avalue {
  my( $param_name ) = @_;
  my @v = ();
  for my $i (1..9) {
    my $p = $q->param( $param_name . '_' . $i );
    if( $p ){
      push( @v , $p );
    }
  }
  return \@v;
}

sub html_template {
  return<<'HTML';
<!doctype html>
<html>
  <head>
    <title>formulator</title>
    <style>
    body{
      margin:30px;
      font-family: Helvetica, Arial, Verdana, sans-serif;
    }
    label {
      display:inline-block;
      width: 200px;
      height: 100%;
      vertical-align: top;
    }
    div {
      margin-top: 10px;
      border-top: 1px solid lightgrey;
      padding-top: 10px;
    }
    input, textarea {
      width: 300px;
      font-size: 14px;
      padding: 5px;
    }
    td input {
      text-align: right;
    }
    input[type="checkbox"]{
      width: 30px;
    }
    textarea {
      height: 100px;
    }
    input[type="submit"]{
      background-color: blue;
      color: white;
      display: inline-block;
      padding: 15px;
      font-size: 16px;
      width: auto;
      vertical-align: middle;
      border-radius: 5px;
    }
    input + br + input {
      margin-top: 3px;
    }
    .container {
      width: 50%;
    }
    @media screen and (max-width: 768px){
      table {
        width: 100%;
      }
      tr td:first-child {
        width: 25%;
      }
      tr td:first-child + td {
        width: 75%;
      }
      .container {
        width: 100%;
      }
      input,
      textarea
      {
        width: 100%;
        font-size: 16px;
      }
    }
    </style>
  </head>
  <body>
  <div class="container">
    %s
    <form action="">
      <input type="submit" value="In PDF umwandeln"><br>

     <div><label for="von_datum">Pflege von_datum</label><input type="text" name="von_datum" value="%s"></div>
     <div><label for="bis_datum">Pflege bis_datum</label><input type="text" name="bis_datum" value="%s"></div>
     <div><label for="sender">sender</label><input type="text" name="sender" value="%s"></div>
     <div><label for="addr_debeka">addr_debeka</label><textarea type="text" name="addr_debeka">%s</textarea></div>
     <div><label for="vorname">vorname</label><input type="text" name="vorname" value="%s"></div>
     <div><label for="nachname">nachname</label><input type="text" name="nachname" value="%s"></div>
     <div><label for="strasse_nr">strasse_nr</label><input type="text" name="strasse_nr" value="%s"></div>
     <div><label for="plz_ort">plz_ort</label><input type="text" name="plz_ort" value="%s"></div>
     <div><label for="geb_dots">geb_dots</label><input type="text" name="geb_dots" value="%s"></div>
     <div><label for="service_nr">service_nr</label><input type="text" name="service_nr" value="%s"></div>
     <div><label for="personalnummer">personalnummer</label><input type="text" name="personalnummer" value="%s"></div>

     <div>
     <table>
       <tr>
       <td>
         <label for="arzneimittel_1">Arzneimittel</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_2" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_3" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_4" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_5" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_6" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="arzneimittel_7" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
     </table>
     </div>

     <div>
     <table>
       <tr>
       <td>
         <label for="ambulante_behandlung_1">Ambulante Behandlung</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_2" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_3" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_4" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_5" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_6" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_7" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_8" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="ambulante_behandlung_9" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
   </table>
     </div>

     <div>
     <table>
       <tr>
       <td>
         <label for="krankenhaus_1">Krankenhaus</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="krankenhaus_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="krankenhaus_2" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
     </table>
     </div>

     <div>
     <table>
       <tr>
       <td>
         <label for="zahnbehandlung_1">Zahnbehandlung</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="zahnbehandlung_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="zahnbehandlung_2" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
     </table>
     </div>

     <div>
     <table>
     <tr>
       <td>
         <label for="sonstiges_1">Sonstiges</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="sonstiges_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="sonstiges_2" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
     </table>
     </div>

     <div>
     <table>
     <tr>
       <td>
         <label for="pflege_1">Pflege</label>
       </td>
       <td>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="pflege_1" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="pflege_2" pattern="^\d+,\d{2}$" value="%s"><br>
         <input type="text" title="Eurbetrag mit Cents abgetrennt durch ein Komma" name="pflege_3" pattern="^\d+,\d{2}$" value="%s"><br>
       </td>
       </tr>
     </table>
     </div>

    </form>
    </div>
  </body>
</html>
HTML
}

