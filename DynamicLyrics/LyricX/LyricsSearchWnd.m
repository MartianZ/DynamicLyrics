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

- (id)initWithArtist:(NSString *)artist initWithTitle:(NSString *)title;
{
    self = [super initWithWindowNibName:@"LyricsSearchWnd"];
    if (self){
        if (!title)
            return self;
        self.SongTitle = title;
        self.SongArtist = artist;
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
    
    [IB_TableView setTarget:self];
    [IB_TableView setDoubleAction:@selector(TableViewDoubleClick:)];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LyricsServer"] != 0  && [[NSUserDefaults standardUserDefaults] integerForKey:@"LyricsServer"] != 1)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"LyricsServer"];
    
    [IB_ComboBox_Server selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"LyricsServer"]];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file
}


-(IBAction)SearchLyrics:(id)sender
{
    
    [IB_Array_Controller removeObjects:[IB_Array_Controller arrangedObjects]];
    if ([[IB_Text_Title stringValue] isEqualToString:@""])
        return;
    
    GB_BIG_Converter* _convertManager = [[GB_BIG_Converter alloc] init];
    
    [QianQianLyrics getLyricsListByTitle:[_convertManager big5ToGb:[IB_Text_Title stringValue]] getLyricsListByArtist:[_convertManager big5ToGb:[IB_Text_Artist stringValue]] AddToArrayController:IB_Array_Controller Server:[IB_ComboBox_Server indexOfSelectedItem]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:[IB_ComboBox_Server indexOfSelectedItem] forKey:@"LyricsServer"];
    [_convertManager release];
}

- (void)TableViewDoubleClick:(id)sender
{
    KeyValue_SearchLyrics *key_value = [[IB_Array_Controller selectedObjects] objectAtIndex:0];
    NSString *lrc = [QianQianLyrics getLyricsByTitle:[key_value LyricsTitle] getLyricsByArtist:[key_value LyricsArtist] getLyricsByID:[key_value ID]];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:lrc] forKey:[NSString stringWithFormat:@"%@%@",self.SongArtist,self.SongTitle]];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.SongTitle,@"SongTitle",self.SongArtist,@"SongArtist",[key_value LyricsTitle],@"ServerSongTitle",[key_value LyricsArtist],@"ServerSongArtist", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLyricsChanged" object:nil userInfo:dict];
    
    [self.window orderOut:self];     
}

@end
