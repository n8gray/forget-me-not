//
//  AXApplication.h
//  FMN
//
//  Created by David Noblet on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "FMNWindowGroup.h"

@interface AXApplication : NSObject<FMNWindowGroup> {
    @protected AXUIElementRef appElement;
    @protected ProcessSerialNumber psn;
    @protected pid_t pid;
}

+ (id) configWithPSN : (ProcessSerialNumber) processSerialNumber;
- (id) initWithPSN : (ProcessSerialNumber) processSerialNumber;

@end
