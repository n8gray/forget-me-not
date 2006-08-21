//
//  X11Bridge.m
//  FMN
//
//  Created by Nathaniel Gray on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "X11Bridge.h"
#import "X11WindowOrientation.h"
#import "X11Restorable.h"

/* Define our own error handlers that don't crash DM */
int xErrHandler( Display *d, XErrorEvent *error ) {
    char message[1024];
    XGetErrorText(d, error->error_code, message, 1024);
    message[1023] = '\0';
    NSLog( @"%s", message );
    return 0;
}

/* 
* For some reason this often gets called twice when the server dies.  
 * Surprisingly, it all works out ok despite that.
 */
int ioErrHandler( Display *d ) {
    NSLog( @"X11Bridge: I/O Error.  Perhaps the X Server Died.\n" );
    // If this function returns then our process dies.  :-(
    @throw( @"X11 IO Error" );
}

@implementation X11Bridge

- (id) init
{
    char *dispName;
    self = [super init];
    if (!self)
        return self;
    
    /* XXX: We should make this a preferences item */
    if (!(dispName = getenv("DISPLAY")))
        dispName = ":0";
    
    mDisplayName = [[NSString stringWithCString:dispName] retain];
    
    // I believe this only needs to be done once, even if we connect to
    // different servers in our lifetime.
    XSetErrorHandler(xErrHandler);
    XSetIOErrorHandler(ioErrHandler);
    return self;
}

- (void) setDisplayName:(NSString *)name
{
    NSString *tmp = [name retain]; 
    if (mDisplayName)
        [mDisplayName release];
    mDisplayName = tmp;
}

- (NSMutableArray *) getRestorables
{
    return [NSMutableArray 
            arrayWithObject:[[X11Restorable alloc] initWithBridge:self]];
}

- (Display *) display { return mDisplay; };

- (BOOL) openDisplay {
    mDisplay = XOpenDisplay([mDisplayName cString]);
    if (!mDisplay) {
        NSLog (@"Couldn't open X11 display %@", mDisplayName);
        return NO;
    }
    return YES;
}

- (int) closeDisplay {
    int i = XCloseDisplay(mDisplay);
    mDisplay = NULL;
    return i;
}

@end
