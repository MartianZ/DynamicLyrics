//
//  MainController.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "QianQianLyrics.h"
#import "BingTranslator.h"
#import "RegexKitLite.h"
#import "MenuBarLyrics.h"
#import "GB_BIG_Converter.h"
#import "FloatPanel.h"
#import "PanelView.h"
#import "Constants.h"
#import "RequestSender.h"


@interface MainController : NSObject {
    
    NSUserDefaults *userDefaults;
    NSNotificationCenter *nc;
    NSDistributedNotificationCenter *dnc;
    int CurrentLyric;    
    NSPanel *LyricsWindow;
    

}

- (void)Anylize;
- (void)iTunesPlayerInfo:(NSNotification *)note;
- (void)WorkingThread:(NSMutableDictionary*)tmpDict;
- (id)initWithMenu:(NSMenu *)AppMenu;

@property(nonatomic, assign) iTunesTrack *iTunesCurrentTrack;
@property(nonatomic, assign) NSString *SongLyrics;
@property(nonatomic, assign) NSString *CurrentSongLyrics;
@property(nonatomic, assign) NSMutableArray *lyrics;


@end
