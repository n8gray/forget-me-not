//
//  DockRestorable.h
//  FMN
//
//  Created by David Noblet on 9/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNRestorable.h"

@interface DockRestorable : NSObject<FMNRestorable> {
    //NSDictionary* dockPrefs;
    Boolean autohidePref;
}

- (id) initWithCurrent;

@end
