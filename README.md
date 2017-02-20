# Prompter for Julius

![Screenshot](/screenshot.png)

Prompter is a tiny program that displays recognition results of [Julius](http://github.com/julius-speech/julius) as a scrolling caption.

## Requirement

Perl and Tkx extension is required to run this program.  Developed and tested on ActivePerl/win32.

## Usage

First, look at the header part of the script, and set the server name where Julius runs.

You can also change caption size, window location, fonts, colors, etc. 

Then,

1. Start prompter.pl.
2. Run Julius with `-module -progout -outcode Ww`.
3. Push "Connect" button of the prompter to connect to Julius.

When connection was failed or lost while running, it will automatically retry connection for every 3 seconds, maximum at 60 seconds.

If output text clutters, make sure your Julius output is UTF-8 encoded!

