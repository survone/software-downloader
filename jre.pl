#!/usr/bin/perl -w

#
#   03.10.2013
#   Anton Doroshenko
#
#
# downloads JRE x86 and x64

use strict;
use warnings;

use HTML::TreeBuilder 5 -weak; # to parse html page
use LWP::UserAgent; # to use different useragent when fetching web-page

use constant PROGRAM_NAME => "Java Runtime Environment";

my $wgetoptions = "";
my $savepath = "";
my $debug = 0;
my $url = 'http://java.com/en/download/manual.jsp';
my $lastversion="";

for ( @ARGV ) {
    print "Parsing argument " . $_ . "\n" if $debug;
    if ( ( $_ =~ /^--debug$/ ) || ( $_ =~ /^-d$/ ) ) {
        $debug = 1;
    } elsif ( $_ =~ /^--wget=/ ) {
        ($wgetoptions) = $_ =~ /=(.*)$/;

    } elsif ( $_ =~ /^--base=/ ) {
        ($savepath) = $_ =~ /=(.*)$/;
    $savepath =~ s!/$!!;
    $savepath .= '/';
    }
}

print '$wgetoptions = ' . $wgetoptions . "\n" if $debug;
print '$savepath = ' . $savepath . "\n" if $debug;




print "Opening " . $url . "\n" if $debug;
# oper url as if we are useing firefox on windows
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->agent( 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Win64)' );
my $response = $ua->get( $url );
my $tree = HTML::TreeBuilder->new_from_content( $response->decoded_content );

print $tree->dump if $debug;
print "\n\n\n#####################\n#####################\n#####################\n\n\n" if $debug;

$lastversion = $tree->look_down(
    '_tag' => 'strong',
    sub { $_[0]->as_trimmed_text() =~ /Recommended Version/ } 
)->as_trimmed_text;
$lastversion =~ s/^Recommended Version (\d) ?(Update (\d+))?/$1u$3/;
print "Latest version is $lastversion\n" if $debug;

foreach ( $tree->look_down( '_tag' => 'a', sub { $_[0]->as_trimmed_text() =~ /Windows Offline/ } ) ) {
    my ( $arch ) = $_->as_trimmed_text =~ /^Windows Offline \((\d\d)/;
    my $saveas = $savepath . PROGRAM_NAME . "_$lastversion-x$arch.exe";
    $saveas =~ s/\ /_/g;
    if ( -e $saveas ) {
        print "File $saveas exists. Skipping...\n";
    } else {
        for ( @{ $_->extract_links('a') } ) {
            print "\n\n\n#####################\n#####################\n#####################\n\n\n" if $debug;
            my( $downloadurl ) = @$_;
            print $downloadurl if $debug; 
            `mkdir -p $savepath`;
            `wget -O $saveas $wgetoptions $downloadurl`;
            print "You have latest version of ". PROGRAM_NAME ."\n";
        }
    }
}
