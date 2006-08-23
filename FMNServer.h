//
//  FMNServer.h
//  FMN
//
//  Created by Nathaniel Gray on 8/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol FMNServer

- (BOOL) activateFMN;
- (BOOL) deactivateFMN;
- (BOOL) isActiveFMN;
- (oneway void) quitFMN;

@end
