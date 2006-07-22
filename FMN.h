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
#import "X11Bridge.h"


@interface FMN : NSObject {
    @protected NSMutableDictionary* screenConfigurations;
    @protected FMNDisplayConfigurationRef currentDisplayConfiguration;
    @protected X11Bridge *x11Bridge;
}

- (void) awakeFromNib;

@end
