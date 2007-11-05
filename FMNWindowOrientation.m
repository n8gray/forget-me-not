//
//  FMNWindowOrientation.m
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNWindowOrientation.h"


@implementation FMNWindowOrientation

- (id) init { [self release]; return nil; };

- (id) initWithWindow : (FMNWindowRef) win
{
    if(![super init])
        return nil;

    window = [win retain];
    
    @try
    {
        position = [window getWindowPosition];
        size = [window getWindowSize];
    }
    @catch (NSException* ex)
    {
        [self release];
        @throw ex;
    }
    //NSLog(@"SUCCESS!!!!");
    
    return self;
}

- (void) restoreWithContext : (NSDictionary*) context
{
    [window setWindowSize: size Position: position Context: context];
    NSLog(@"Restored %@", window);
}

- (int) priority
{
    return kRestorableDefaultPriority;
}

- (void) dealloc
{
    [window release];
    
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodePoint:position forKey:@"FMNWOposition"];
    [encoder encodeSize:size forKey:@"FMNWOsize"];
    [encoder encodeObject:window forKey:@"FMNWOwindow"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    position = [decoder decodePointForKey:@"FMNWOposition"];
    size = [decoder decodeSizeForKey:@"FMNWOsize"];
    window = [[decoder decodeObjectForKey:@"FMNWOwindow"] retain];
    return self;
}

@end
