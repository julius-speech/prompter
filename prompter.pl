#!/usr/bin/perl
#
# Usage: prompter.pl
#

use utf8;
use Tcl;
use Tkx;
use Encode;
use Time::HiRes qw( usleep gettimeofday tv_interval );

############# user configuration #############

# Julius host name
my $host = "localhost";
# Julius module port number (default is 10500)
my $port = 10500;
# text height of the caption area
my $lines = 3;
# default text size
my $textsize = 30;
# initial message on caption
my $mes = ">> Prompter, a fancy recognition result for Julius";
# initial window location
my $windowloc = "700x250+0+0";
# font name
my $fontname = "ＭＳ ゴシック";
# foreground color
my $fgcolor = '#FFFFFF';
# background fgcolor
my $bgcolor = '#000000';
# color of progressive result
my $progcolor = "#999999";

############# system configuration #############

# connection retry interval msec
my $ConnectRetryIntervalMSec = 300;

# max num of connection retry
my $maxConnectRetry = 20;

# maximum number of chars to execute log purge (for large caption, use larger value for safe)
my $maxlinelen = 100;

# julius output character code
my $incode = 'utf8';


###########################################
###########################################
###########################################

#### making window

my $mw = Tkx::widget->new(".");
$mw->g_wm_geometry($windowloc);
my $text = $mw->new_text(
    -foreground => $fgcolor,
    -background => $bgcolor,
    -cursor => 'man',
    -font => [$fontname, $textsize],
    -height => $lines,
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

#### avoid error on dialog window, instead call function when $isInConnect is 1
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

# change text size
sub setscale () {
    $text->configure(-font => [$fontname, $textsize]);
}

# retry connection
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

# data receiving process
sub start_process {
    $_ = Tkx::gets($socket);
    if ($_ eq "") {
        # error
        $errorcount++;
        if ($errorcount >= 20) {
            # enter retry mode
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
    } elsif (/WHYPO/) {
        ($w) = ($_ =~ /WORD=\"(.*)\"\/\>/);
        if ($pass == 1) {
            $str1 .= $w;
        } else {
            $str2 .= $w;
        }
    } elsif (/\<\/PHYPO>/) {
        if ($str1 ne "") {
            # 1st pass progressive result
            $str1 = &formatStringJP($str1);
            if ($fpflag == 1) {
                $fpflag = 0;
            } else {
                $text->delete("prog.first", "prog.last");
            }
            $text->insert_end($str1, "prog");
            $text->tag_config("prog", -foreground => $progcolor);
            $text->see("end");
        }
    } elsif (/\<SHYPO RANK/) {
        $pass = 2;
        $str2 = "";
    } elsif (/\<\/SHYPO>/ && $pass == 2) {
        # 2nd pass final result
        if ($fpflag == 0) {
            $text->delete("prog.first", "prog.last");
        }
        $str2 = &formatStringJP($str2);
        if (! $str2 =~ /^ *$/) {
            $text->insert("end", $str2);
            $text->see("end");
            # rehash old lines
            $linelen = $text->index("end - 1 chars");
            if ($linelen > "1.$maxlinelen") {
                 $text->delete("0.0", "end - $lines display lines");
            }
        }
        $fpflag = 1;
    } elsif (/\<REJECTED/) {
        # rejected
        if ($fpflag == 0) {
            $text->delete("prog.first", "prog.last");
        }
        $fpflag = 1;
    }
}

# clear text
sub resetMessage ()
{
    $pass = 1;
    $str1 = "";
    $str2 = "";
    $fpflag = 1;
    $text->delete("0.0", "end");
}

# re-format Japanese recognition result: delete symbols
sub formatStringJP()
{
    my ($str) = @_;

    if (! ($str =~ /。$/)) {
        $str .= " ";
    }
    $str =~ s/、//g;
    $str =~ s/。/ /g;

    return $str;
}