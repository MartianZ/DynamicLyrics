//
//  LyricXAppDelegate.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"
#import "LyricsSearchWnd.h"
#import "Albumfiller.h"
#import "AppPrefsWindowController.h"
#import "EditLyricsWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainController *Controller;
    LyricsSearchWnd *SearchWindow;
    EditLyricsWindowController *EditLyricsWindow;
    Albumfiller *AlbumfillerWindow;
    IBOutlet NSMenu *AppMenu;
    IBOutlet NSMenuItem *currentDelay;

}

-(IBAction)OpenLyricsSearchWindow:(id)sender;
-(IBAction)CopyCurrentLyrics:(id)sender;
-(IBAction)CopyTotalLRC:(id)sender;
-(IBAction)exportLRC:(id)sender;
-(IBAction)OpenAlbumfillerWindow:(id)sender;
-(IBAction)CopyTotalTextLyrics:(id)sender;
-(IBAction)WriteLyricsToiTunes:(id)sender;
-(IBAction)WriteArtwork:(id)sender;
- (IBAction)adjustLyricsDelay:(id)sender;
- (IBAction)resetLyricsDelay:(id)sender;


- (IBAction)DisabledMenuBarLyrics:(id)sender;
- (IBAction)DisabledDesktopLyrics:(id)sender;
OSStatus myHotKeyHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData);
@end
