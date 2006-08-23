//
//  FMNModuleLoader.m
//  FMN
//
//  Created by Nathaniel Gray on 8/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FMNModuleLoader.h"


@implementation FMNModuleLoader

+ (id) moduleAtPath:(NSString *)path withProtocol:(Protocol *)proto
{
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    if (![bundle load]) {
        NSLog(@"Couldn't load bundle: %@", path);
        return nil;
    }
    
    Class pc = [bundle principalClass];
    if (![pc conformsToProtocol:proto]) {
        NSLog(@"Class %@ does not conform to protocol.", pc);
        return nil;
    }
    NSLog(@"Loaded FMN module: %@", pc);
    id instance = [pc alloc];
    if ([instance respondsToSelector:@selector(initWithBundle:)]) {
        return [instance performSelector:@selector(initWithBundle:) withObject:bundle];
    } else
        return [instance init];
}

+ (NSArray *) allPluginsOfBundle:(NSBundle *)bundle 
                    withProtocol:(Protocol *)proto
{
    NSString *pluginDir = [bundle builtInPlugInsPath];
    NSArray *bundlePaths = [NSBundle pathsForResourcesOfType:@"plugin"
                                                 inDirectory:pluginDir];
    NSEnumerator *e = [bundlePaths objectEnumerator];
    NSString *path;
    NSMutableArray *modules = [NSMutableArray arrayWithCapacity:2];
    while (path = [e nextObject]) {
        id module = [FMNModuleLoader moduleAtPath:path withProtocol:proto];
        if (module != nil) {
            [modules addObject:module];
        }
    }
    return modules;
}

@end
