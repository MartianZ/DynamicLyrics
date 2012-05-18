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
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainController *Controller;
    LyricsSearchWnd *SearchWindow;
    Albumfiller *AlbumfillerWindow;
    IBOutlet NSMenu *AppMenu;

}

-(IBAction)OpenLyricsSearchWindow:(id)sender;
-(IBAction)CopyCurrentLyrics:(id)sender;
-(IBAction)CopyTotalLRC:(id)sender;
-(IBAction)ExportLRC:(id)sender;
-(IBAction)OpenAlbumfillerWindow:(id)sender;
-(IBAction)CopyTotalTextLyrics:(id)sender;
-(IBAction)WriteLyricsToiTunes:(id)sender;

@end
