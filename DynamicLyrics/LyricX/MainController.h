//
//  MainController.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "BingTranslator.h"
#import "RegexKitLite.h"
#import "MenuBarLyrics.h"
#import "GB_BIG_Converter.h"
#import "LyricsFloatWindow.h"
#import "Constants.h"
#import "RequestSender.h"

@interface MainController : NSObject {
    
    NSUserDefaults *userDefaults;
    NSNotificationCenter *nc;
    NSDistributedNotificationCenter *dnc;
    MenuBarLyrics* MBLyrics;
    int CurrentLyric;    
    LyricsFloatWindow *LyricsWindow;
    NSMenuItem *currentDelayMenuItem;
    @public
    float LyricsDelay;

}

- (void)Anylize;
- (void)iTunesPlayerInfo:(NSNotification *)note;
- (void)WorkingThread:(NSMutableDictionary*)tmpDict;
- (id)initWithMenu:(NSMenu *)AppMenu initWithDelayItem:(NSMenuItem *)delayMenuItem;

@property(nonatomic, retain) iTunesTrack *iTunesCurrentTrack;
@property(nonatomic, retain) NSString *SongLyrics;
@property(nonatomic, retain) NSString *CurrentSongLyrics;
@property(nonatomic, retain) NSMutableArray *lyrics;

@end
