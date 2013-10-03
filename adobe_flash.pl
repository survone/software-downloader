#!/usr/bin/perl -w

#
#   02.10.2013
#   Anton Doroshenko
#
#
# downloads adobe flash player

use strict;
use warnings;

use HTML::TreeBuilder 5 -weak; # to parse html page
use LWP::UserAgent; # to use different useragent when fetching web-page

use constant PROGRAM_NAME => "Adobe Flash Player";

my $wgetoptions = "";
my $savepath = "";
my $debug = 0;
my $url = 'http://get.adobe.com/ru/flashplayer/';
my $downloadurl = 'http://download.macromedia.com/pub/flashplayer/current/support/install_flash_player.exe';

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
$ua->agent( 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)' );
my $response = $ua->get( $url );

my $tree = HTML::TreeBuilder->new_from_content( $response->decoded_content );
print $tree->dump if $debug;

print "\n\n\n#####################\n#####################\n#####################\n" if $debug;
use locale;
my ( $lastversion ) = $tree->look_down( '_tag' => 'strong' )->as_trimmed_text() =~ /([\d\.]+)/;
$lastversion =~ s/\./-/g;
print "Latest version is $lastversion\n" if $debug;

my $saveas = $savepath . PROGRAM_NAME . "_" . $lastversion . ".exe";
$saveas =~ s/\ /_/g;
unless ( -e $saveas ) {
    `mkdir -p $savepath`;
    `wget -O $saveas $wgetoptions $downloadurl`;
    print "Downloaded " . PROGRAM_NAME . " $lastversion. Saved as $saveas\n";
} else {
    print "You have latest version of ". PROGRAM_NAME ."\n";
}
