#!/usr/bin/perl -w

#
#   02.10.2013
#   Anton Doroshenko
#
#
# downloads first 2 *.exe files which are 
# the latest x86 and x64 fusioninventory agents for windows 

use strict;
use warnings;

use HTML::TreeBuilder 5 -weak; # to get and parse html page



my $wgetoptions = "";
my $savepath = "";
my $debug = 0;
my $url = 'http://forge.fusioninventory.org/projects/fusioninventory-agent-windows-installer/files';

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

unless ( $tree ) {
    my $response = $HTML::TreeBuilder::lwp_response;
    if ( $response->is_success ) {
        warn "Content of $url is not HTML, it's " . $response->content_type . "\n";
    } else {
        warn "Couldn't get $url: ", $response->status_line, "\n";
    }
    exit 1;
}

my $tbody = $tree->look_down( '_tag', 'tbody');
print qq(my $tbody = $tree->look_down( '_tag', 'tbody'); is: \n\n) if $debug;
print $tbody->dump if $debug;

my $i = 0;
for ( @{ $tbody->extract_links('a') } ) {
    my($link) = @$_;
    if ( $link =~ m/\.exe$/ ) { 
        print $link . " is pointing to exe file\n" if $debug;
        my ($lastversion) = $link =~ m/(\d\.\d\.\d(-\d)?)\.exe/;
        print "Latest version is " . $lastversion . "\n" if $debug;
        my ($filename) = $link =~ m/(fusioninventory-agent_windows-x\d\d_)/;
        # if no such file
        my $saveas = $savepath . $filename . $lastversion . ".exe";
        unless ( -e $saveas ) {
            `mkdir -p $savepath`;
            `wget -O $saveas $wgetoptions 'http://forge.fusioninventory.org'$link`;
        } else {
            print "File $saveas exists. Skipping...\n" if $debug;
        } 
        $i++;
    }
    if ( $i == 2 ) { last }
}
