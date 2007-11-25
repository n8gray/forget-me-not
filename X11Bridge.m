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

// For proper handling of Leopard's launchd setup
#define kX11AppBundle "org.x.X11"
#define kLaunchDPrefix @"/tmp/launch"
#include <launch.h>

/* Define our own error handlers that don't crash the program */
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

- (void) dealloc
{
    if (mDisplayName)
        [mDisplayName release];
    [super dealloc];
}

- (id) init
{
    char *dispName;
    
    /* XXX: We should make this a preferences item */
    if (!(dispName = getenv("DISPLAY")))
        dispName = ":0";
    
    NSLog(@"X11 DISPLAY=%s", dispName);
    return [self initWithDisplayName:[NSString stringWithCString:dispName]];
}

/* Designated initializer */
- (id) initWithDisplayName:(NSString *)dispName
{
    self = [super init];
    if (!self)
        return self;

    mDisplayName = [[NSString stringWithString:dispName] retain];
    
    // I believe this only needs to be done once, even if we connect to
    // different servers in our lifetime.
    XSetErrorHandler(xErrHandler);
    XSetIOErrorHandler(ioErrHandler);
    return self;
    
}

- (void) setDisplayName:(NSString *)name
{
    NSString *tmp = [[NSString stringWithString:name] retain]; 
    if (mDisplayName)
        [mDisplayName release];
    mDisplayName = tmp;
}

- (NSMutableArray *) getRestorables
{
    id restorable = [[[X11Restorable alloc] initWithBridge:self] autorelease];
    if (restorable)
        return [NSMutableArray arrayWithObject:restorable];
    else {
        @throw( @"No X11 Restorables" );
        return nil;  // For the compiler's sake...
    }
        
}

- (Display *) display { return mDisplay; };

- (BOOL) openDisplay {
    /* In Leopard the X server is launched on demand by launchd if you connect 
     * to the DISPLAY socket.  We don't want to trigger that!  So we query 
     * launchd to find out if the server is already running
     *
     * Big thanks to Ben Byer at Apple for the patch!
     */
    NSLog(@"X11 Module: openDisplay(%@)\n", mDisplayName);
    if ([mDisplayName hasPrefix:kLaunchDPrefix]) {  // this is a launchd socket
        launch_data_t resp, msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
        launch_data_dict_insert(msg, launch_data_new_string(kX11AppBundle),
                                LAUNCH_KEY_GETJOB);
        resp = launch_msg(msg);
        launch_data_free(msg);
        
        if (resp == NULL) {
            NSLog(@"launch_msg(): %s\n", strerror(errno));
            return NO;
        }
        
        if (launch_data_get_type(resp) == LAUNCH_DATA_DICTIONARY) {
            if(!launch_data_dict_lookup(resp, LAUNCH_JOBKEY_PID)) {
                NSLog(@"Launchd says X11 is not running.\n");
                launch_data_free(resp);
                return NO;
            }
        }
        launch_data_free(resp);
    }
    
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

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:mDisplayName forKey:@"X11BdisplayName"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSString *dname = [[coder decodeObjectForKey:@"X11BdisplayName"] retain];
    return [self initWithDisplayName:dname];
}

- (void) restoreFinished
{
    // Nada
}

@end
