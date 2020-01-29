#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use CAM::PDF;
use HTML::Entities;
use Encode;

my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag);
my @days_short = qw(So Mo Di Mi Do Fr Sa So);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time + 86400);
#print "$mday $months[$mon] $days[$wday]\n";

my $ua = LWP::UserAgent->new;


#ronnie
my $res = $ua->request(HTTP::Request->new(GET => "https://www.wasgibtsheut.at/was-gibt-s-heut/ronacher/"));
if ($res->is_success) {
   print "ronnie\n";
   my $date = sprintf("%02d.%02d.%04d", $mday, ($mon+1), ($year+1900));
   my $string_small = $res->content;
   $string_small =~ s/[\r\n\t\f\v]+//g;
   $string_small =~ s/>\s+/>/g;
   #print "$string_small\n";
   if ($string_small =~ qr/$date<[\s\S]*?>([A-Z][^<]+?)<[\s\S]*?>([A-Z][^<]+?)</) {
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
   my $date = sprintf("%02d\\.%02d", $mday, ($mon+1));
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
   $text =~ s/Donner stag/Donnerstag/g;
   #print "$text\n";
   if ($text =~ qr/Montag \- Freitag.*?$days[$wday].*?Men. I(.*?)Men. II(.*?)(${days[$wday + 1]}|Johannesgasse)/) {
      print cleanWhitespaces(encode('utf-8', $1)) . cleanWhitespaces(encode('utf-8', $2));
   }
   else {
      $text =~ s/\s+//g;
      if ($text =~ qr/Montag-Freitag.*?${days[$wday]}.*?Men.I(.*?)Men.II(.*)(${days[$wday + 1]}|Johannesgasse)/) {
         print cleanWhitespaces(encode('utf-8', $1)) . cleanWhitespaces(encode('utf-8', $2));
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
   print "\njosi\n";
   my $url = $res->content;
   if ($url =~ qr/pdf-embedder url=&quot;(.*?)&quot;/) {
      $res = $ua->request(HTTP::Request->new(GET => $1));
      if ($res->is_success) {
         my $pdf = CAM::PDF->new($res->content);
         my $text = encode('utf-8', $pdf->getPageText(1));
         #$text =~ s/\s+/ /g;
         $text = getWeekText($text);
         if ($text =~ qr/$days_short[$wday]:\s(.+)\s ¬\s+.+\s(.+)/) {
            print cleanWhitespaces("1: " . $1) . cleanWhitespaces("2: " . $2);
         }
         else {
            print "not found :(\n";
         }
      }
      else {
         print "Failed 2: ", $res->status_line, "\n";
      }
   }
}
else {
   print "Failed 1: ", $res->status_line, "\n";
}


#bettelstudent
#$res = $ua->request(HTTP::Request->new(GET => "https://www.bettelstudent.at"));
#if ($res->is_success) {
#   print "\nbettelstudent\n";
#   my $url = $res->content;
#   if ($url =~ qr/<a\s*href="([^"]*?)"[^\/]*?Wochenmenü/) {
#      $res = $ua->request(HTTP::Request->new(GET => "https://www.bettelstudent.at" . $1));
#      if ($res->is_success) {
#         my $pdf = CAM::PDF->new($res->content);
#         my $text = encode('utf-8', $pdf->getPageText(1));
#         $text =~ s/\n/, /g;
#         if ($text =~ qr/$days[$wday], (.*?), , /) {
#            print cleanWhitespaces($1);
#         }
#         else {
#            print "not found :(\n";
#         }
#      }
#      else {
#         print "Failed 2: ", $res->status_line, "\n";
#      }
#   }
#}
#else {
#   print "Failed 1: ", $res->status_line, "\n";
#}


#bürgerliche brauerei
$res = $ua->request(HTTP::Request->new(GET => "https://burgerlichebrauerei.at/mittagsmenu/"));
if ($res->is_success) {
   print "\nbürgi\n";
   my $string_small = $res->content;
   $string_small =~ s/[\r\n\t\f\v]+//g;
   if ($string_small =~ qr/$days[$wday].*?nazov-jedla">([^<]+)<\/.*?nazov-jedla">([^<]+)<\/.*?nazov-jedla">([^<]+)<\/.*?nazov-jedla">([^<]+)<\//) {
      print cleanWhitespaces($1) . cleanWhitespaces($2) . cleanWhitespaces($3) . cleanWhitespaces($4);
   }
   else {
      print "not found :(\n";
   }
}
else {
   print "Failed: ", $res->status_line, "\n";
}

sub getWeekText {
   my ($text) = @_;
   #print "$text\n";
   if ($text =~ qr/(\d+)\.(\d+\.)?-(\d+)\.\d+([\s\S]+)/) {
      if ($1 < $3) {
         if ($mday >= $1 && $mday <= $3) {
            return $4;
         }
         else {
            return getWeekText($4);
         }
      }
      else {
         if ($mday >= $1 || $mday <= $3) {
            return $4;
         }
         else {
            return getWeekText($4);
         }
      }
   }
}

sub cleanWhitespaces {
   my ($string) = @_;
   $string =~ s/^\s+//;
   $string =~ s/\s+$//;
   $string = decode_entities($string);
   return "$string\n";
}
