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

- (void) restore
{
    [window setWindowPosition : position];
    [window setWindowSize : size];
    NSLog(@"Window position restored");
}

- (void) dealloc
{
    [window release];
    
    [super dealloc];
}

@end
