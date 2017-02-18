# Prompter for Julius

![Screenshot](/screenshot.png)

Prompter is a tiny program that displays recognition results of [Julius](http://github.com/julius-speech/julius) as a scrolling caption style.

## Requirement

Perl and Tkx extension is required to run.  Developed and tested on ActivePerl/win32.

## Usage

First, look at the header part of the script, and set Julius server name.

You can also change caption size, window location, fonts, colors, etc. 

Then,

1. Start prompter.pl.
2. Run Julius with `-module -progout -outcode Ww`.
3. After starting Julius, push "Connect" button to connect to Julius.

When failed to connect, or connection was lost while running, prompter will automatically retry connection for every 3 seconds, maximum at 60 seconds.

If text clutters, make sure your Julius output is UTF-8 encoding!

