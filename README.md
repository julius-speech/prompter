# Prompter

![Screenshot](/screenshot.png)

This tiny script receives recognition result from [Julius](http://github.com/julius-speech/julius), and displays them as a scrolling caption.

# Requirement

Perl and its Tkx extension.  Tested on ActivePerl/win32.

# HowTo

Modify the Julius server name in "prompter.pl" for your environment, then:

1. Start prompter.pl
2. Run Julius with `-module -progout -outcode Ww`. 
 Also make sure your Julius outputs the results in UTF-8 encoding.
3. After starting Julius, push "Connect" button to connect to Julius.

Prompter will retry connection when connection is lost for every 3 seconds, maximum at 60 seconds in total.
