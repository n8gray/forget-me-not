//
//  AXWindow.m
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AXWindow.h"


@implementation AXWindow

- (id) init { [self release]; return nil; }

- (id) initWithAXElement : (AXUIElementRef) windowElem 
                   ofApp : (AXApplication *) app
{
    if (![super init])
        return nil;
    
    CFRetain(windowElem);
    windowElement = windowElem;
    windowApp = [app retain];
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:
                 @"AX Window 0x%x of app: %@", (long)windowElement, windowApp];
}

- (NSPoint) getWindowPosition
{
    NSPoint point;
    CFTypeRef value;
    if (AXUIElementCopyAttributeValue(windowElement,kAXPositionAttribute,
        &value) != kAXErrorSuccess)
    {
        NSString *reason = 
            [NSString stringWithFormat:@"Unable get position of %@", self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                           reason : reason
                         userInfo : nil
            ];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&point))
    {
        NSString *reason = 
            [NSString stringWithFormat:@"Unable get position of %@", self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                           reason : reason
                         userInfo : nil
            ];
    }
    CFRelease(value);
    
    return point;
}

- (NSSize) getWindowSize
{
    NSSize size;
    CFTypeRef value;
    if (AXUIElementCopyAttributeValue(windowElement,kAXSizeAttribute,
        &value) != kAXErrorSuccess)
    {
        NSString *reason = 
            [NSString stringWithFormat:@"Unable get size of %@", self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : reason
                userInfo : nil
            ];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&size))
    {
        NSString *reason = 
            [NSString stringWithFormat:@"Unable get size of %@", self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : reason
                userInfo : nil
            ];
    }
    CFRelease(value);
    
    return size;
}

- (void) setWindowPosition : (NSPoint) pos Context : (NSDictionary*) context
{
    NSNumber* off_x = 
        (NSNumber*) [context objectForKey:@"com.fmn.x-coordinate-offset"];
    NSNumber* off_y = 
        (NSNumber*) [context objectForKey:@"com.fmn.y-coordinate-offset"];
        
    pos.x += [off_x floatValue];
    pos.y += [off_y floatValue];
    
    CFTypeRef value;
    value = AXValueCreate(kAXValueCGPointType,&pos);
    if(AXUIElementSetAttributeValue(windowElement,kAXPositionAttribute,value)
        != kAXErrorSuccess)
    {
        CFRelease(value);
        NSString *reason = 
            [NSString stringWithFormat:@"Unable set position to %f, %f for %@",
                pos.x, pos.y, self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                           reason : reason
                         userInfo : nil
            ];
    }
    CFRelease(value);
}

- (void) setWindowSize : (NSSize) size Context : (NSDictionary*) context
{
    CFTypeRef value;
    value = AXValueCreate(kAXValueCGSizeType,&size);
    if(AXUIElementSetAttributeValue(windowElement,kAXSizeAttribute,value)
        != kAXErrorSuccess)
    {
        CFRelease(value);
        NSString *reason = 
            [NSString stringWithFormat:@"Unable set size to %fx%f for %@",
                size.width, size.height, self];
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                           reason : reason
                         userInfo : nil
            ];
    }
    CFRelease(value);
}

- (void) setWindowSize : (NSSize) size Position : (NSPoint) pos Context : (NSDictionary*) context
{
    [self setWindowPosition : pos Context : context];
    [self setWindowSize : size Context : context];
}

- (void) dealloc
{
    if (windowElement)
    {
        CFRelease(windowElement);
    }
    if (windowApp)
    {
        [windowApp release];
    }
    
    [super dealloc];
}

@end
