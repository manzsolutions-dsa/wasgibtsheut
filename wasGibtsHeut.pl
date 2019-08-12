#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use CAM::PDF;
use HTML::Entities;

my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
#print "$mday $months[$mon] $days[$wday]\n";

my $ua = LWP::UserAgent->new;


#ronnie
my $res = $ua->request(HTTP::Request->new(GET => "https://www.wasgibtsheut.at/was-gibt-s-heut/ronacher/"));
if ($res->is_success) {
   print "ronnie\n";
   my $date = sprintf("%02d.%02d.%04d", $mday, ($mon+1), ($year+1900));
   my $string_small = $res->content;
   $string_small =~ s/[\r\n\t\f\v]+//g;
   #print "$string_small\n";
   if ($string_small =~ qr/$date.*?<span style="text-align: start;">(.*?)<\/span>\s*<br[^>]*>\s*<span style="text-align: start;">(.*?)<\/span>/) {
      print cleanWhitespaces($1) . cleanWhitespaces($2);
   }
   else {
      print "not found :(\n";
   }
}
else {
   print "Failed: ", $res->status_line, "\n";
}


#1516
$res = $ua->request(HTTP::Request->new(GET => "https://www.1516brewingcompany.com/daily-special/"));
if ($res->is_success) {
   print "\n1516\n";
   my $date = sprintf("%02d.%02d", $mday, ($mon+1));
   my $string_small = $res->content;
   $string_small =~ s/[\r\n\t\f\v]+//g;
   if ($string_small =~ qr/$date.*?<strong>(.*?)<\/strong>/) {
      print cleanWhitespaces($1);
   }
   else {
      print "not found :(\n";
   }
}
else {
   print "Failed: ", $res->status_line, "\n";
}


#elissar
$res = $ua->request(HTTP::Request->new(GET => "https://www.elissar.at/wp-content/uploads/2017/09/mittagsmenu.pdf"));
if ($res->is_success) {
   print "\nelissar\n";
   my $pdf = CAM::PDF->new($res->content);
   my $text = $pdf->getPageText(1);
   $text =~ s/\s+/ /g;
   #print "$text\n";
   if ($text =~ qr/Montag \- Freitag.*?$days[$wday].*?Men. I(.*?)Men. II(.*?)(${days[$wday + 1]}|Johannesgasse)/) {
      print cleanWhitespaces($1) . cleanWhitespaces($2);
   }
   else {
      $text =~ s/\s+//g;
      if ($text =~ qr/Montag-Freitag.*?${days[$wday]}.*?Men.I(.*?)Men.II(.*)(${days[$wday + 1]}|Johannesgasse)/) {
         print cleanWhitespaces($1) . cleanWhitespaces($2);
      }
      else {
         print "not found :(\n";
      }
   }
}
else {
   print "Failed: ", $res->status_line, "\n";
}


#josi
$res = $ua->request(HTTP::Request->new(GET => "https://jonathan-sieglinde.com/mittags-speiseplan/"));
if ($res->is_success) {
   #print "\njosi\n";
   my $url = decode_entities($res->content);
   if ($url =~ qr/pdf-embedder url="(.*?)"/) {
      $res = $ua->request(HTTP::Request->new(GET => $1));
      if ($res->is_success) {
         my $pdf = CAM::PDF->new($res->content);
         my $text = $pdf->getPageText(1);
         #$text =~ s/\s+/ /g;
         #print $text;
      }
      else {
         $res = $ua->request(HTTP::Request->new(GET => sprintf("https://jonathan-sieglinde.com/wp-content/uploads/%04d/%02d/Mittags-Menüplan%d-%2d.pdf", ($year + 1900), ($mon + 1), ($mon + 1), ($year - 100))));
         if ($res->is_success) {
            my $pdf = CAM::PDF->new($res->content);
            my $text = $pdf->getPageText(1);
            #$text =~ s/\s+/ /g;
            #print $text;
         }
         else {
            print "Failed 2: ", $res->status_line, "\n";
         }
      }
   }
}
else {
   print "Failed 1: ", $res->status_line, "\n";
}


sub cleanWhitespaces {
   my ($string) = @_;
   $string =~ s/^\s+//;
   $string =~ s/\s+$//;
   $string = decode_entities($string);
   return "$string\n";
}