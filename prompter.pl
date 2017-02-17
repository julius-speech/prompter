#!/usr/bin/perl
#
# Usage: prompter.pl
#

use utf8;
use Tcl;
use Tkx;
use Encode;
use Time::HiRes qw( usleep gettimeofday tv_interval );

############# configuration #############
# Julius host name
my $host = "localhost";
# Julius module port number (default is 10500)
my $port = 10500;
# julius output code, '' for utf-8
my $incode = 'utf8';
# font name
my $fontname = "ＭＳ ゴシック";

############# global variable #############

$mes = "This is prompter, a fancy recognition result showing for Julius";
$textsize = 30;

my $maxConnectRetry = 20;
my $ConnectRetryIntervalMSec = 300;

###########################################
###########################################
###########################################

#### making window

my $mw = Tkx::widget->new(".");
$mw->g_wm_geometry("600x200+0+0");
my $text = $mw->new_text(
    -foreground => '#FFFFFF',
    -background => '#000000',
    -cursor => 'man',
    -font => [$fontname, $textsize],
    -height => 3,
    -padx => 15,
    -pady => 7,
    -state => 'normal',
    -wrap => 'char'
);
$text->g_pack();

$text->insert("1.0", $mes);

my $button = $mw->new_button(
    -text => "Connect",
    -command => sub {connectJulius();},
    );
$button->g_pack( -side => 'left');

my $sizebar = $mw->new_scale(
    -orient => 'horizontal',
    -from => 1.0, 
    -to => 100.0,
    -variable => \$textsize,
    -command => \&setscale
    );
$sizebar->g_pack( -side =>'left' );

my $button2 = $mw->new_button(
    -text => "ClearText",
    -command => sub {resetMessage();},
    );
$button2->g_pack( -side => 'left');

my $isInConnect = 0;
my $connectCount = 0;

#### make error not use dialog window
Tkx::set("perl_bgerror", sub {
    splice(@_, 0, 3);
    my $msg = shift;
    print "Error: $msg\n";
    if ($isInConnect == 1) {
        &retryConnect();
    }
});
Tkx::eval(<<'EOT');
proc bgerror {msg} {
    global perl_bgerror
    $perl_bgerror $msg
}
EOT

my $pass = 1;
my $str1 = "";
my $str2 = "";
my $w;
my $fpflag = 1;
#my $lastOutputTime = 0;
my $socket;

#### infinite main loop
Tkx::MainLoop();

sub setscale () {
    $text->configure(-font => [$fontname, $textsize]);
}

sub retryConnect() {
    $connectCount++;
    if ($connectCount < $maxConnectRetry) {
        $button->configure(-text => "Retry $connectCount", -state => 'disabled');
        Tkx::after($ConnectRetryIntervalMSec, sub {connectJulius();});
    } else {
        $connectCount = 0;
        $button->configure(-text => "Connect", -state => 'normal');            
    }
}

# create socket and connect
sub connectJulius () {
    $isInConnect = 1;
    $socket = Tkx::socket($host, $port);
    $isInConnect = 0;
    if (!$socket || $isError == 1) {
       exit;
    }
    # disable buffering 
    #$| = 1;
    #my($old) = select($socket); $| = 1; select($old);
    #$socket->blocking(0);
    resetMessage();
    Tkx::fconfigure($socket, -encoding => 'binary');
    Tkx::fileevent($socket, 'readable' => \&start_process);
    $button->configure(-text => "Connected", -state => 'disabled');
}

my $errorcount = 0;
sub start_process {
    $_ = Tkx::gets($socket);
    if ($_ eq "") {
        $errorcount++;
        if ($errorcount >= 20) {
            Tkx::close($socket);
            $connectCount = 0;
            &retryConnect();
        }
    } else {
        $errorcount = 0;
    }
    my $str = Encode::decode($incode, $_);
    $_ = $str;
    if (/\<PHYPO PASS=\"1\"/) {
        $pass = 1;
        $str1 = "";
#       if ($lastOutputTime != 0) {
#           if (tv_interval($lastOutputTime) > 2.0) {
#               $text->insert("end", "\n◆");
#               $text->see("end");
#           }
#           $lastOutputTime = 0;
#       }
    } elsif (/WHYPO/) {
        ($w) = ($_ =~ /WORD=\"(.*)\"\/\>/);
        if ($pass == 1) {
            $str1 .= $w;
        } else {
            $str2 .= $w;
        }
    } elsif (/\<\/PHYPO>/) {
        if ($str1 ne "") {
            if ($fpflag == 1) {
                $fpflag = 0;
            } else {
                $text->delete("prog.first", "prog.last");
            }
            $text->insert_end($str1, "prog");
            $text->tag_config("prog", -foreground => "#666666");
            $text->see("end");
        }
    } elsif (/\<SHYPO RANK/) {
        $pass = 2;
        $str2 = "";
    } elsif (/\<\/SHYPO>/ && $pass == 2) {
        if ($fpflag == 0) {
            $text->delete("prog.first", "prog.last");
        }
        my $s = $str2;
        $s =~ s/、//g;
        $s =~ s/。//g;
        if ($s ne "") {
            if (! ($str2 =~ /。$/)) {
                $str2 .= " ";
            }
            $str2 =~ s/、/ /g;
            $str2 =~ s/。/ /g;
            $text->insert("end", $str2);
            $text->see("end");
        }
        $fpflag = 1;
        # $lastOutputTime = [gettimeofday];
    } elsif (/\<REJECTED/) {
        if ($fpflag == 0) {
            $text->delete("prog.first", "prog.last");
        }
        $fpflag = 1;
        # $lastOutputTime = [gettimeofday];
    }
}

sub resetMessage ()
{
    $pass = 1;
    $str1 = "";
    $str2 = "";
    $fpflag = 1;
    $text->delete("0.0", "end");
}
