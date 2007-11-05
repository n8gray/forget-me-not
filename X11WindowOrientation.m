//
//  X11WindowOrientation.m
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//
 
#import "X11WindowOrientation.h"

@implementation X11WindowOrientation

- (id) initWithXWindow:(Window)win onDisplay:(Display *)disp
{
    XWindowAttributes attrs;
    Window dummy;
    
    self = [super init];
    if (self == nil)
        return self;
    
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
    //NSLog(@"Created X11 window 0x%x with orientation (%i, %i) %i x %i",
    //      mWindow, mX, mY, mWidth, mHeight);
    return self;
}

- (void) restoreOnDisplay:(Display *)disp
{
    XWindowChanges values;
    unsigned int value_mask;
    values.x = mX;
    values.y = mY;
    values.width = mWidth;
    values.height = mHeight;
    value_mask = CWX | CWY | CWWidth | CWHeight;
    if (!XReconfigureWMWindow(disp, mWindow, DefaultScreen(disp), 
                              value_mask, &values)) {
        NSLog(@"Couldn't restore X11 window 0x%x to (%i, %i) %i x %i", 
              mWindow, mX, mY, mWidth, mHeight);
    }
    //else
        //NSLog(@"Restored X11 window 0x%x to (%i, %i) %i x %i", 
        //      mWindow, mX, mY, mWidth, mHeight);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt64:mWindow forKey:@"X11WOwindow"];
    [coder encodeInt:mX forKey:@"X11WOx"];
    [coder encodeInt:mY forKey:@"X11WOy"];
    [coder encodeInt:mWidth forKey:@"X11WOwidth"];
    [coder encodeInt:mHeight forKey:@"X11WOheight"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    mWindow = [coder decodeInt64ForKey:@"X11WOwindow"];
    mX = [coder decodeIntForKey:@"X11WOx"];
    mY = [coder decodeIntForKey:@"X11WOy"];
    mWidth = [coder decodeIntForKey:@"X11WOwidth"];
    mHeight = [coder decodeIntForKey:@"X11WOheight"];
    return self;
}
@end
