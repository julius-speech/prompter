# Prompter for Julius

![Screenshot](/screenshot.png)

Prompter is a perl/Tkx based tiny program that displays recognition results sent from [Julius](http://github.com/julius-speech/julius), like a scrolling caption.

# Requirement

Perl and Tkx extension is reuired to run this program.
Developed and tested on ActivePerl/win32.

# Usage

First, look at the header of the script and set Julius server name in "prompter.pl".
You can also change caption size, window location, colors, fonts, etc. 
Then,

1. Start prompter.pl.
2. Run Julius with `-module -progout -outcode Ww`.
3. After starting Julius, push "Connect" button to connect to Julius.

When connection was failed or lost, prompter will automatically continue retrying to connect for every 3 seconds, maximum at 60 seconds in total.

If text clutters, make sure the Julius outputs text in UTF-8 encoding!
  
