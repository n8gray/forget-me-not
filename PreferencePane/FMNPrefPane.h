//
//  FMNPrefPane.h
//  FMN
//
//  Created by Nathaniel Gray on 8/1/06.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface FMNPrefPane : NSPreferencePane 
{
    id mFMNProxy;
    NSBundle *myBundle;
    NSString *mFMNPath;
    NSImage *mEnabledImage;
    NSImage *mDisabledImage;
    NSMutableArray *fmnPrefpaneModules;
    int controlYPos;
    
    IBOutlet NSButton *mLaunchQuit;
    IBOutlet NSProgressIndicator *mSpinner;
    IBOutlet NSTextField *mStatusField;
    IBOutlet NSBox *mControls;
    IBOutlet NSButton *mActivated;
    IBOutlet NSImageView *mDiagram;
    IBOutlet id mAccessWarning;
    IBOutlet id mVersionLabel;
}

- (IBAction) toggleActivated:(id)sender;
- (IBAction) launchOrQuit:(id)sender;
- (IBAction) launchWebsite:(id)sender;

- (NSString *)mainNibName;

@end
