//
//  AppPrefsWindowController.h
//  LyricX
//
//  Created by Martian on 12-5-1.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "Constants.h"
@interface AppPrefsWindowController : DBPrefsWindowController <NSWindowDelegate> {
    IBOutlet NSView *notificationPreferenceView;
    IBOutlet NSView *advancedPreferenceView;
    IBOutlet NSView *donatePreferenceView;
    
}

- (IBAction)openFontPanel:(id)sender;
- (IBAction)DonatePaypal:(id)sender;
- (IBAction)DonateAlipay:(id)sender;
- (IBAction)DonateAmazon:(id)sender;

- (IBAction)DesktopLyricsChanged:(id)sender;
- (IBAction)LaunchAndQuitWithiTunes:(id)sender;

@end
