Forget-Me-Not
by Nathaniel Gray & David Noblet

About:
=====

Forget-Me-Not is a background application that keeps track of the positions and
sizes of your windows.  When you change the configuration of your screens (e.g.
by connecting or disconnecting an external monitor from a notebook) FMN does
two things:
1.  Before the configuration changes, it saves the states (positions and sizes)
    of your windows.
2.  After the configuration changes, it moves and resizes your windows to match 
    the way they were laid out the last time you were in this configuration.

Installation:
============

Double-click on the Forget-Me-Not.prefpane file.  You should get a dialog asking
if you want to install the preference pane for yourself or all users of the 
computer.  Either choice is fine.  Now launch System Preferences.  There should
be a new preference pane at the bottom, in the "Other" section, called
Forget-Me-Not.  Click on the preference pane to launch Forget-Me-Not.

Upgrading:
=========

Before upgrading to a new version of FMN, go to the Forget-Me-Not preference
pane and click the Quit button to stop any running version of Forget-Me-Not.
Once that is done, follow the instructions above for Installation.

Reporting Problems:
==================

If you have any problems with Forget-Me-Not, please send an e-mail to
    n8gray <at> caltech /dot/ edu
and
    dnoblet <at> cs /dot/ caltech /dot/ edu

Source Code:
===========

You can get the source code for FMN by using the DARCS revision control system.
First, download and install DARCS:
    http://www.darcs.net/
Next, do a "darcs get" like this:
    darcs get http://www.n8gray.org/darcs/fmn
If you're not interested in our complete development history (which you probably
aren't!) you should do a "partial" get to save space:
    darcs get --partial http://www.n8gray.org/darcs/fmn    
You'll end up with an "fmn" directory containing the latest source code.

License:
=======

Forget-Me-Not is licensed under the GNU Lesser GPL.  See the LICENSE.txt file
for details.
