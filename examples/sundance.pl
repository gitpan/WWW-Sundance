#!/usr/bin/perl -w
use strict;
use WWW::Sundance;

my $sd = WWW::Sundance->new;
$sd->schedule();              # Today's date
$sd->schedule('20020802');    # Selected date

$sd->search('bergman');       # Search - title, director or keyword
