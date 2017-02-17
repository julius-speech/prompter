# Prompter for Julius

![Screenshot](/screenshot.png)

Prompter is a perl/Tkx based tiny program that displays recognition results sent from [Julius](http://github.com/julius-speech/julius), like a scrolling caption.

# Requirement

Perl and Tkx extension is reuired to run this program.
Developed and tested on ActivePerl/win32.

# HowTo

First, modify the hard-coded Julius server name in "prompter.pl", then:

1. Start prompter.pl.
2. Run Julius with `-module -progout -outcode Ww`.  (Also make sure your Julius output is UTF-8)
3. After starting Julius, push "Connect" button to connect to Julius.

When connection was failed or lost, prompter will automatically continue retrying to connect for every 3 seconds, maximum at 60 seconds in total.
