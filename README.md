REST Toolbox
============

A small collection of commands making life easier when interacting with REST services.

Open Standard Input in the Right Application
--------------------------------------------

openstdin(1) is a simple script that allows one to open standard input in an
appropriate application as determined by open(1).

It can automatically determine the proper file extension to use
for open to pick an application. In order to do so it relies on file(1)
and a mime.types file (either Apache's or CUPS's mime.types(5) can
be used).

