#!/usr/bin/perl -w
use strict;
use WWW::Sundance;

my $sd = WWW::Sundance->new;
$sd->schedule_date('07/28/2002');
$sd->schedule;

$sd->search_text('bergman');
$sd->search;
