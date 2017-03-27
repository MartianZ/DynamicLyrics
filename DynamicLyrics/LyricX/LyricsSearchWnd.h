//
//  LyricsSearchWnd.h
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KugouLyrics.h"
#import "KeyValue_SearchLyrics.h"

@interface LyricsSearchWnd : NSWindowController {
    
    @private
    IBOutlet NSTextField *IB_Text_Artist;
    IBOutlet NSTextField *IB_Text_Title;
    IBOutlet NSTextField *IB_Text_Duration;
    IBOutlet NSArrayController *IB_Array_Controller;
    IBOutlet NSTableView *IB_TableView;
}

- (id)initWithArtist:(NSString *)artist initWithTitle:(NSString *)title initWithSongDuration:(double)duration;

@property (nonatomic, retain) NSString* SongTitle;
@property (nonatomic, retain) NSString* SongArtist;
@property (nonatomic, assign) double SongDuration;

@end
