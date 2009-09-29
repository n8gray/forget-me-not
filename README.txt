Forget-Me-Not
by Nathaniel Gray & David Noblet

FMN is Obsolete:
===============

Forget-Me-Not does not work reliably on any OS X since Leopard was released.  I
make the source available in hopes that somebody with more time than myself will
be able to make it work again.  Many of the failures are revealed when using
Spaces.  Others appear if your laptop screen is configured on one side of your
external monitor but not the other.  I mention this so that you don't get too
excited if it works for you -- that doesn't mean it'll work for everyone.

HOWEVER, there are those who say they've been using it on Leopard and it's
worked well enough.  I myself do use it -- it doesn't *always* help, but it
sometimes does and it doesn't seem to hurt.

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

If you have any problems with Forget-Me-Not, please open an issue at github.
You can also send an e-mail to
    n8gray <at> n8gray /dot/ org
but I'm notorious about dropping these things on the floor if there isn't an
issue report to remind me.

Source Code:
===========

You can get the source code for FMN by using GIT (http://git-scm.com).  Our
code is hosted at github:  http://github.com/n8gray/forget-me-not

License:
=======

Forget-Me-Not is licensed under the GNU Lesser GPL.  See the LICENSE.txt file
for details.
