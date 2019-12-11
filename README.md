# was gibts heut?
it's a lunch menu website crawler

## setup:
### install perl
### install missing modules:
```
cpan -i CAM::PDF
sudo cpan -i LWP::UserAgent
sudo cpan -i Mozilla::CA
```

### set @INC (depending on your cpan setup):
`export PERL5LIB=/Users/dsa/perl5/lib/perl5`

## output:
```
$perl wasGibtsHeut.pl
ronnie
Kürbis-Mangold-Lasagne mit Grana
Specklinsen mit Serviettenknödel

1516
Schweinenackensteak vom Grill auf Brioche-Toast mit Bacon Baked Beans, Cafe De Paris Butter & Pommes

elissar
Halloumi Salat mit Sesambrot
Shish Kafta (Rinderspieße) mit Reis und Hummus

josi
1: Gegrillte Hühnerspieße mit
2: Gegrillte Gemüsespieße,
```
