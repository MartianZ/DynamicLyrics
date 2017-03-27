//
//  LyricsSearchWnd.m
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "LyricsSearchWnd.h"

@interface LyricsSearchWnd ()

@end

@implementation LyricsSearchWnd

@synthesize SongTitle;
@synthesize SongArtist;
@synthesize SongDuration;

- (id)initWithArtist:(NSString *)artist initWithTitle:(NSString *)title initWithSongDuration:(double)duration;
{
    self = [super initWithWindowNibName:@"LyricsSearchWnd"];
    if (self){
        if (!title)
            return self;
        self.SongTitle = title;
        self.SongArtist = artist;
        self.SongDuration = duration;
        self.window.level = NSFloatingWindowLevel;
        [self.window makeKeyAndOrderFront:self];

    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window center];
    [IB_Text_Artist setStringValue:self.SongArtist];
    [IB_Text_Title setStringValue:self.SongTitle];
    [IB_Text_Duration setStringValue:[NSString stringWithFormat:@"%.3f", self.SongDuration]];
    
    [IB_TableView setTarget:self];
    [IB_TableView setDoubleAction:@selector(TableViewDoubleClick:)];
}


-(IBAction)SearchLyrics:(id)sender
{
    [IB_Array_Controller removeObjects:[IB_Array_Controller arrangedObjects]];
    if ([[IB_Text_Title stringValue] isEqualToString:@""])
        return;
    [KugouLyrics getLyricsListByTitle:[IB_Text_Title stringValue] getLyricsListByArtist:[IB_Text_Artist stringValue] getLyricsBySongDuration:[IB_Text_Duration doubleValue] AddToArrayController:IB_Array_Controller];
}

- (void)TableViewDoubleClick:(id)sender
{
    KeyValue_SearchLyrics *key_value = [[IB_Array_Controller selectedObjects] objectAtIndex:0];
    NSString *lrc = [KugouLyrics getLyricsByID:[key_value ID] getLyricsByAccesskey:[key_value AccessKey]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:lrc] forKey:[NSString stringWithFormat:@"%@%@",self.SongArtist,self.SongTitle]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.SongTitle,@"SongTitle",self.SongArtist,@"SongArtist",[key_value LyricsTitle],@"ServerSongTitle",[key_value LyricsArtist],@"ServerSongArtist", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLyricsChanged" object:nil userInfo:dict];
    [self.window orderOut:self];
}

@end
