//
//  X11WindowOrientation.h
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "X11Bridge.h"

@interface X11WindowOrientation : NSObject {
    X11Bridge *mX11Bridge;
    Window mWindow;
    int mX, mY, mWidth, mHeight, mBorderWidth;
}

- (id) initWithXWindow:(Window)win withBridge:(X11Bridge *)bridge;
- (void) restore;

@end
