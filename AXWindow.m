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
{
    if (![super init])
        return nil;
    
    CFRetain(windowElem);
    windowElement = windowElem;
    
    return self;
}

- (NSPoint) getWindowPosition
{
    NSPoint point;
    CFTypeRef value;
    if (AXUIElementCopyAttributeValue(windowElement,kAXPositionAttribute,
        &value) != kAXErrorSuccess)
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable get AX window position"
                userInfo : nil
            ];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&point))
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable get AX window position"
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
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable get AX window size"
                userInfo : nil
            ];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&size))
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable get AX window size"
                userInfo : nil
            ];
    }
    CFRelease(value);
    
    return size;
}

- (void) setWindowPosition : (NSPoint) pos
{
    CFTypeRef value;
    value = AXValueCreate(kAXValueCGPointType,&pos);
    if(AXUIElementSetAttributeValue(windowElement,kAXPositionAttribute,value)
        != kAXErrorSuccess)
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable set AX window position"
                userInfo : nil
            ];
    }
    CFRelease(value);
}

- (void) setWindowSize : (NSSize) size
{
    CFTypeRef value;
    value = AXValueCreate(kAXValueCGSizeType,&size);
    if(AXUIElementSetAttributeValue(windowElement,kAXSizeAttribute,value)
        != kAXErrorSuccess)
    {
        @throw 
            [NSException
                exceptionWithName : FMNWindowException
                reason : @"Unable set AX window size"
                userInfo : nil
            ];
    }
    CFRelease(value);
}

- (void) dealloc
{
    if (windowElement)
    {
        CFRelease(windowElement);
    }
    
    [super dealloc];
}

@end
