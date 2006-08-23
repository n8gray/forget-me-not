//
//  FMNModuleLoader.h
//  FMN
//
//  Created by Nathaniel Gray on 8/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMNModule.h"

@interface FMNModuleLoader : NSObject {

}

// This initializes the module with initWithBundle: if the class supports it.
+ (id) moduleAtPath:(NSString *)path withProtocol:(Protocol *)proto;

+ (NSArray *) allPluginsOfBundle:(NSBundle *)bundle 
                    withProtocol:(Protocol *)proto;

@end
