# Copyright (c) 2002 Douglas Sparling. All rights reserved. This program is free
# software; you can redistribute it and/or modify it uner the same terms
# as Perl itself.

package WWW::Sundance;

use strict;
use Carp;
use LWP::Simple;
use LWP::UserAgent;
use HTML::TokeParser;
use vars qw($VERSION);

$VERSION = '0.02';

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};

    $self->{base_url} = 'http://www.sundancechannel.com';
    $self->{schedule} = "$self->{base_url}/schedule/index.php";
    $self->{film_finder} = "$self->{base_url}/film_finder/index.php";

    bless($self, $class);
    return $self;
}

sub schedule {
    my($self) = shift;
    my $schedule;

    # Example
    #my $schedule = "$self->{schedule}?schedDate=04%2F04%2F2002+06%3A00%3A00";
    #my $schedule = "$self->{schedule}?schedDate=04/04/2002+06:00:00";
    #my $schedule = "$self->{schedule}"; # Current

    my $sched_date = shift;
    if( $sched_date ) {
        my $year = substr($sched_date,0,4);
        my $month = substr($sched_date,4,2);
        my $day = substr($sched_date,6,2);
        $sched_date = "$month/$day/$year+06:00:00";
        $schedule = "$self->{schedule}?schedDate=$sched_date";
    } else {
        $schedule = "$self->{schedule}";
    }

    my $html = get($schedule);

    if (defined $html) {
        my $parser = HTML::TokeParser->new(\$html) or croak "Can't open HTML: $!";

        my $flag = 0;
        my $date;
        while (my $token = $parser->get_token()) {
            #<div class=left><b><span class=subtitle>
            $date = $token->[1] if $token->[1] =~ /\w+,\s+\w+\s+\d+,\s+\d+/;
            last if $token->[1] =~ /START SHOW LISTING/;
        }

        print "SCHEDULE FOR: $date\n"; 

        while(my $tag = $parser->get_tag()) {
            if ($flag) {
                $parser->get_tag('tr');
            } else {
                $flag = 1;
            }
            $parser->get_tag('td');
            $parser->get_tag('b');
            my $time = $parser->get_text;
            $parser->get_tag('td');
            $parser->get_tag('b');
            my $title = $parser->get_text;
            $parser->get_tag('td');
            $parser->get_tag('b');
            my $director = $parser->get_text;
            $parser->get_tag('td');
            $parser->get_tag('b');
            my  $genre = $parser->get_text;

            print "TIME: $time\n" if $time;
            print "TITLE: $title\n" if $title;
            print "DIR: $director\n" if $director;
            print "GENRE: $genre\n" if $genre;
        }
    } else {
        croak "Error getting $schedule\n";
    }

}

sub search {
    my($self) = shift;

    my $search_text = shift;
    return undef unless defined $search_text;

    my $ua = LWP::UserAgent->new;

    my $request = HTTP::Request->new(POST => $self->{film_finder});
    $request->content_type('application/x-www-form-urlencoded');
    $request->content("searchtext=$search_text&searchrun=1");
    my $response = $ua->request($request);

    my $html;
    if ($response->is_success) {
        $html = $response->content; 
    } else {
        croak "Error getting document: ", $response->status_line, "\n";
    }


    print "SEARCH: $search_text\n";

    my $parser = HTML::TokeParser->new(\$html) or croak "Can't open HTML: $!";

    while (my $token = $parser->get_token()) {
        #print "T: $token->[1]\n";
        if ($token->[1] =~ /SHOW\s+MODULE/) {

            #print "$token->[1]\n";

            while(my $tag = $parser->get_tag()) {
                #$parser->get_tag('tr');
                $parser->get_tag('td');
                $parser->get_tag('img');
                $parser->get_tag('font');
                $parser->get_tag('a');
                $parser->get_tag('b');
                my $title = $parser->get_text;
                #$parser->get_tag('td');
                #$parser->get_tag('font');
                $parser->get_tag('b');
                my $director = $parser->get_text;
                $parser->get_tag('b');
                my $category = $parser->get_text;
          
                if( $title ) {
                    print "TITLE: $title\n";
                    print "DIR: $director\n";
                    print "CAT: $category\n";
                }
            }
        }

    }

}

1;

__END__

=head1 NAME

WWW::Sundance - Get movie schedules/info from Sundance.

=head1 SYNOPSIS

  use WWW::Sundance;
  my $sd = WWW::Sundance->new;
  $sd->schedule();              # Today's date
  $sd->schedule('20020802');    # Selected date (yyyymmdd)

  $sd->search('bergman');       # Search - title, director or keyword

=head1 DESCRIPTION

C<WWW::Sundance> is used to fetch movie schedules and info from the Sundance web site.

=head1 CONSTRUCTOR

=over 4

=item new ()

This is the contructor for a new WWW:Sundance object;

=back

=head1 METHODS

=over 4

=item schedule ( [DATE] )

This method will fetch the schedule for the schedule_date.
Format for DATE is YYYYMMDD.
If schedule_date is not set, then schedule for current date will be fetched.

=item search ( [SEARCH_TEXT] )

This method will fetch all entries matching search_text.

=back

=head1 AUTHOR

Doug Sparling, doug@dougsparling.com

=head1 COPYRIGHT

Copyright (c) 2002 Douglas Sparling. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself;

=cut
