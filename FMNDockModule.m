//
//  FMNDockModule.m
//  FMN
//
//  Created by David Noblet on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNDockModule.h"
#import "DockRestorable.h"

@implementation FMNDockModule

- (NSArray *) getRestorables
{
    NSMutableArray* dockRestorables = [NSMutableArray arrayWithCapacity : 1];
    DockRestorable* dockPrefs = [[DockRestorable alloc] initWithCurrent];
    [dockRestorables addObject:[dockPrefs autorelease]];
    
    return dockRestorables;
}

- (void) restoreFinished
{
    // Nothing
}

@end
