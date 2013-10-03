#!/usr/bin/perl -w

#
#   02.10.2013
#   Anton Doroshenko
#
#
# downloads DoPDF

use strict;
use warnings;

use HTML::TreeBuilder 5 -weak; # to parse html page
use LWP::UserAgent; # to use different useragent when fetching web-page

use constant PROGRAM_NAME => "DoPDF";

my $wgetoptions = "";
my $savepath = "";
my $debug = 0;
my $url = 'http://www.dopdf.com/ru/download.php';
my $downloadurl = 'http://www.dopdf.com/download/setup/dopdf-7.exe';
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
my $tree = HTML::TreeBuilder->new_from_url( $url );
print $tree->dump if $debug;
my $div = $tree->look_down( '_tag' => 'div', 'class' => 'captioned_image');
print "\n\n\n#####################\n#####################\n#####################\n\n\n" if $debug;
print $div->dump if $debug; 
print "\n\n\n#####################\n#####################\n#####################\n\n\n" if $debug;

# getting number of latest version
foreach ( $div->descendants ) {
    if ( $_->tag eq "div" ) {
        ( $lastversion ) = $_->as_text =~ /\| (\d\.\d.\d{3}) \|/;
    }
}
print "Latest version is $lastversion\n" if $debug;

my $saveas = $savepath . PROGRAM_NAME . "_" . $lastversion . ".exe";
$saveas =~ s/\s/_/g;
if ( -e $saveas ) {
    print "You have latest version of ". PROGRAM_NAME ."\n";
} else {
    `mkdir -p $savepath`;
    `wget -O $saveas $wgetoptions $downloadurl`;
    print "Downloaded " . PROGRAM_NAME . " $lastversion\. Saved as $saveas\n";
}
