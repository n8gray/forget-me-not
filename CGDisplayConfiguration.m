//
//  CGDisplayConfiguration.m
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CGDisplayConfiguration.h"
#import "CGDisplay.h"

@implementation CGDisplayConfiguration

- (id) init { [self release]; return nil; }

- (id) initWithCurrent
{
    if (![super init])
        return nil;
    
    mainDisplay = 0;
    displays = 0;
    
    int i;
    unsigned int screen_count = CG_MAX_DISPLAYS;
    NSMutableData* screenList = [NSMutableData dataWithCapacity: screen_count * 
        sizeof(CGDirectDisplayID)];
    CGDirectDisplayID* screenList_p = 
        (CGDirectDisplayID*)[screenList mutableBytes];
    
    if(CGGetActiveDisplayList(screen_count, screenList_p, &screen_count))
    {
        [self release];
        return nil;
    }
    
    displays = [[NSMutableArray arrayWithCapacity:screen_count] retain];
    
    for(i=0; i<screen_count; ++i)
    {
        [displays addObject: [[[CGDisplay alloc] initWithDisplayID: 
            screenList_p[i]] autorelease]];
        if(CGDisplayIsMain(screenList_p[i]))
            mainDisplay = [[CGDisplay alloc] initWithDisplayID: 
                screenList_p[i]];
    }
    [displays sortUsingSelector : @selector(compare:)];
    
    return self;
}

+ (FMNDisplayConfigurationRef) configWithCurrent
{
    return [[[CGDisplayConfiguration alloc] initWithCurrent] autorelease];
}

- (unsigned) getDisplayCount
{
    return [displays count];
}

- (FMNDisplayRef) getDisplay : (unsigned) i
{
    return [displays objectAtIndex : i];
}

- (FMNDisplayRef) getMainDisplay
{
    return mainDisplay;
}

- (BOOL) isEqual : (id) obj
{
    //return [self hash] == [obj hash];

    if (![obj conformsToProtocol: @protocol(FMNDisplayConfiguration)])
    {
        return NO;
    }
    
    FMNDisplayConfigurationRef display = (FMNDisplayConfigurationRef) obj;

    int display_count = [self getDisplayCount];
    if ([display getDisplayCount] != display_count)
    {
        return NO;
    }
    
    int i;
    
    if(![[self getMainDisplay] isEqual : [display getMainDisplay]])
        return NO;
    
    for(i=0; i<display_count; ++i)
    {
        if(![[self getDisplay : i] isEqual : [display getDisplay : i]])
        {
            return NO;
        }
    }

    return YES;
}

- (unsigned) hash
{
    int display_count = [self getDisplayCount];
    int i,ret = 0;
    
    for(i=0; i<display_count; ++i)
    {
        ret ^= [[self getDisplay : i] hash];
    }
    
    return ret;
}

- (NSString*) description
{
    return [NSString stringWithFormat:
        @"CGDisplayConfiguration with %i displays, displays = %@, hash = %d", 
        [self getDisplayCount], displays, [self hash]];
}

- (id) copyWithZone : (NSZone *) zone
{
    return [self retain];
}

- (void) dealloc
{
    if(mainDisplay)
    {
        [mainDisplay release];
    }

    if(displays)
    {
        [displays release];
    }
    
    [super dealloc];
}

@end
