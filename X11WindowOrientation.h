//
//  X11WindowOrientation.h
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
/* For the X11 types */
#import "X11Bridge.h"

@interface X11WindowOrientation : NSObject<NSCoding> {
    Window mWindow;
    int mX, mY, mWidth, mHeight;
}

- (id) initWithXWindow:(Window)win onDisplay:(Display *)disp;
- (void) restoreOnDisplay:(Display *)disp;

@end
