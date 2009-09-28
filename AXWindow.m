//
//  AXWindow.m
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AXWindow.h"
#import "FMNDisplayConfiguration.h"
#import "FMNDisplay.h"


@implementation AXWindow

- (id) init { [self release]; return nil; }

- (id) initWithAXElement : (AXUIElementRef) windowElem 
                   ofApp : (AXApplication *) app
                  origin : (NSPoint) inOrigin
{
    if (![super init])
        return nil;
    
    CFRetain(windowElem);
    windowElement = windowElem;
    windowApp = [app retain];
    origin = inOrigin;
    
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
        [NSException raise:FMNWindowException 
                    format:@"Unable get position of %@", self];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&point))
    {
        [NSException raise:FMNWindowException 
                    format:@"Unable get position of %@", self];
    }
    CFRelease(value);
    
    // HACK: XXX: Work around accessibility API bogosity in Leopard
    // For now I'm discarding anything with x = -40, but should filter on
    // screen height as well.  But need to find out *which* screen height...
    if ((point.x == -40.0))// && (point.y == ...))
        [NSException raise:FMNWindowException
                    format:@"Got bogus position for %@", self];
    point.x -= origin.x;
    point.y -= origin.y;
    return point;
}

- (NSSize) getWindowSize
{
    NSSize size;
    CFTypeRef value;
    if (AXUIElementCopyAttributeValue(windowElement,kAXSizeAttribute,
        &value) != kAXErrorSuccess)
    {
        [NSException raise:FMNWindowException 
                    format:@"Unable get size of %@", self];
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&size))
    {
        [NSException raise:FMNWindowException 
                    format:@"Unable get size of %@", self];
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
        CFRelease(value);
        [NSException raise:FMNWindowException 
                    format:@"Unable set position to %f, %f for %@",
                            pos.x, pos.y, self];
    }
    NSPoint afterPos = [self getWindowPosition];
    if (afterPos.x != pos.x || afterPos.y != pos.y)
    {
        NSLog(@"Failed to set position of %@ ((%f, %f) != (%f, %f)), and Accessibility API lied.",
              self, pos.x, pos.y, afterPos.x, afterPos.y);
        //NSLog(@"x-offset = %f, y-offset = %f",[off_x floatValue], [off_y floatValue]);
    }
    CFRelease(value);
    
}

- (void) setWindowPosition : (NSPoint) pos Context : (NSDictionary*) context
{
    [self setWindowPosition:pos];
}

- (void) setWindowSize : (NSSize) size Context : (NSDictionary*) context
{
    CFTypeRef value;
    value = AXValueCreate(kAXValueCGSizeType,&size);
    if(AXUIElementSetAttributeValue(windowElement,kAXSizeAttribute,value)
        != kAXErrorSuccess)
    {
        CFRelease(value);
        [NSException raise:FMNWindowException 
                    format:@"Unable set size to %fx%f for %@",
                            size.width, size.height, self];
    }
    NSSize afterSize = [self getWindowSize];
    if (afterSize.width != size.width || afterSize.height != size.height)
    {
        NSLog(@"Failed to set size of %@ ((%f, %f) != (%f, %f)), and Accessibility API lied.",
              self, size.width, size.height, afterSize.width, afterSize.height);
    }
    CFRelease(value);
}

- (BOOL) sanityCheckForSize:(NSSize)size 
                   Position:(NSPoint)pos 
                    Context:(NSDictionary*) context
{
    FMNDisplayConfigurationRef dc = [context objectForKey:@"fmn_new_display_configuration"];
    NSLog(@"Checking %.2fx%.2f window at (%.2f, %.2f)",
          size.width, size.height, pos.x, pos.y);
    if (dc != nil) {
        NSRect winRect;
        winRect.origin = pos; winRect.size = size;
        float onArea = 0.0;
        float winArea = size.width * size.height;
        int i=0;
        for (; i < [dc getDisplayCount]; ++i) {
            /* BUG: This assumes screens don't overlap. */
            FMNDisplayRef dr = [dc getDisplay:i];
            NSRect screenRect = [dr getDisplayOrientation];
            NSRect onRect = NSIntersectionRect(screenRect, winRect);
            float thisArea = onRect.size.width * onRect.size.height;
            onArea += thisArea;
            NSLog(@"... %.2f%% overlap with disp %.2fx%.2f@(%.2f, %.2f)",
                  (thisArea/winArea)*100.0, screenRect.size.width, 
                  screenRect.size.height, screenRect.origin.x, screenRect.origin.y);
        }
        /* Bail out if the onscreen area would be too small */
        if (2*onArea < (winArea))
            return NO;
    } else {
        NSLog(@"Couldn't get display configuration from context. No sanity checking!");
    }
    return YES;
}

- (void) setWindowSize : (NSSize) size Position : (NSPoint) pos Context : (NSDictionary*) context
{
    if (![self sanityCheckForSize:size Position:pos Context:context]) {
        NSLog(@"Refusing to put %.2fx%.2f window at (%.2f, %.2f):  It would be over 1/2 offscreen",
              size.width, size.height, pos.x, pos.y);
        return;
    }
    /* Check to make sure the given size/pos doesn't put over half the window 
       offscreen */
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

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:windowApp forKey:@"AXWwindowApp"];
    [encoder encodeBytes:(const uint8_t*)&windowElement 
                  length:sizeof(AXUIElementRef) 
                  forKey:@"AXWwindowElement"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned dummy;
    self = [super init];
    windowApp = [[decoder decodeObjectForKey:@"AXWwindowApp"] retain];
    windowElement = *(AXUIElementRef *)[decoder decodeBytesForKey:@"AXWwindowElement"
                                                   returnedLength:&dummy];
    return self;
}

@end
