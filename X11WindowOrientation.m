//
//  X11WindowOrientation.m
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//
 
#import "X11WindowOrientation.h"

@implementation X11WindowOrientation

- (id) initWithXWindow:(Window)win withBridge:(X11Bridge *)bridge
{
    XWindowAttributes attrs;
    Window dummy;
    
    self = [super init];
    if (self == nil)
        return self;
    
    Display *disp = [bridge display];
    Status status = XGetWindowAttributes( disp, win, &attrs );
    if (!status) {
        NSLog(@"Couldn't get attributes of X Window 0x%x\n", win);
        [self release];
        return nil;
    }
    // The attrs.x and .y attributes are relative to the window manager frame,
    // not the root window!  We need to translate them to global coordinates,
    // removing the offset to get to the WM frame's origin.
    XTranslateCoordinates(disp, win, attrs.root,
                          -attrs.x, -attrs.y,
                          &mX, &mY, &dummy);
    mWidth = attrs.width;
    mHeight = attrs.height;
    mWindow = win;
    mX11Bridge = bridge;
    NSLog(@"Created X11 window 0x%x with orientation (%i, %i) %i x %i",
          mWindow, mX, mY, mWidth, mHeight);
    return self;
}

- (void) restore
{
    XWindowChanges values;
    unsigned int value_mask;
    values.x = mX;
    values.y = mY;
    values.width = mWidth;
    values.height = mHeight;
    value_mask = CWX | CWY | CWWidth | CWHeight;
    Display *disp = [mX11Bridge display];
    if (!XReconfigureWMWindow(disp, mWindow, DefaultScreen(disp), 
                              value_mask, &values))
        NSLog(@"Couldn't restore X11 window 0x%x to (%i, %i) %i x %i", 
              mWindow, mX, mY, mWidth, mHeight);
    else
        NSLog(@"Restored X11 window 0x%x to (%i, %i) %i x %i", 
              mWindow, mX, mY, mWidth, mHeight);
}

@end
