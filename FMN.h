//
//  FMN.h
//  FMN
//
//  Created by David Noblet on 7/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "FMNDisplayConfiguration.h"
#import "FMNServer.h"


@interface FMN : NSObject <FMNServer> {
    @protected NSMutableDictionary* screenConfigurations;
    @protected FMNDisplayConfigurationRef currentDisplayConfiguration;
    @protected NSMutableArray *fmnModules;
    @protected NSConnection *serverConnection;
    @protected BOOL isActive;
}

- (void) awakeFromNib;
- (void) postConfigTimerCB:(NSTimer *)timer;

@end
