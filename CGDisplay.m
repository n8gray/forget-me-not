//
//  CGDisplay.m
//  FMN
//
//  Created by David Noblet on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CGDisplay.h"

@implementation CGDisplay

- (id) init { [self release]; return nil; }

- (id) initWithDisplayID: (CGDirectDisplayID) dID
{
    if(![super init])
        return nil;
    
    displayID = dID;
    CGRect rect = CGDisplayBounds(displayID);
    orientation.size.width = rect.size.width;
    orientation.size.height = rect.size.height;
    orientation.origin.x = rect.origin.x;
    orientation.origin.y = rect.origin.y;
    
    return self;
}

- (NSRect) getDisplayOrientation
{
    return orientation;
}

- (BOOL) isEqual : (id) obj
{
    if (![obj isMemberOfClass : [CGDisplay class]])
    {
        return NO;
    }
    
    CGDisplay* display = (CGDisplay*) obj;
    NSRect r1, r2;
    r1 = [self getDisplayOrientation];
    r2 = [display getDisplayOrientation];
    
    return memcmp(&r1,&r2,sizeof(NSRect)) == 0;
}

- (NSComparisonResult) compare : (id) obj
{
    if (![obj conformsToProtocol : @protocol(FMNDisplay)])
    {
        @throw 
            [NSException
                exceptionWithName : FMNDisplayException
                reason : @"Unable to compare a FMNDisplay with any other type of object!"
                userInfo : nil
            ];
    }
    FMNDisplayRef display = obj;

    NSRect f1, f2;
    f1 = [self getDisplayOrientation];
    f2 = [display getDisplayOrientation];

    if (f1.origin.x > f2.origin.x)
    {
        return NSOrderedDescending;
    } 
    else if (f1.origin.x < f2.origin.x)
    {
        return NSOrderedAscending;
    } 
    else if (f1.origin.x == f2.origin.x) 
    {
        if (f1.origin.y > f2.origin.y)
        {
            return NSOrderedDescending;
        }
        else if (f1.origin.y < f2.origin.y)
        {
            return NSOrderedAscending;
        }
    }
    
    return NSOrderedSame;
}

- (unsigned) hash
{
    NSRect r = [self getDisplayOrientation];

    return (int)r.origin.x ^ (int)r.origin.y ^ 
        (int)r.size.width ^ (int)r.size.height;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSString*) description
{
    NSRect r = [self getDisplayOrientation];
    
    return [NSString stringWithFormat:
            @"CGDisplay 0x%x: %fx%f at (%f, %f)", 
            (int)displayID, r.size.width, r.size.height, r.origin.x, r.origin.y];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBytes:(const uint8_t *)&displayID
                  length:sizeof(CGDirectDisplayID) 
                  forKey:@"CGDdisplayID"];
    [encoder encodeRect:orientation forKey:@"CGDorientation"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned dummy;
    self = [super init];
    displayID = *(CGDirectDisplayID *)[decoder decodeBytesForKey:@"CGDisplayID"
                                                  returnedLength:&dummy];
    orientation = [decoder decodeRectForKey:@"CGDorientation"];
    return self;
}

@end
