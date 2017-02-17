# Prompter

![Screenshot](/screenshot.png)

This tiny script receives recognition result from [Julius](http://github.com/julius-speech/julius), and displays them as a scrolling caption.

# Requirement

Perl and its Tkx extension.  Tested on ActivePerl/win32.

# HowTo

1. Run Julius with `-module -progout -outcode Ww`.  Also make sure your Julius outputs the results in UTF-8 encoding.
2. After starting Julius, push "Connect" button to connect to Julius.

