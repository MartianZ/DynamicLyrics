//
//  LyricsSearchWnd.h
//  LyricX
//
//  Created by Martian on 12-4-4.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GB_BIG_Converter.h"
#import "QianQianLyrics.h"
#import "KeyValue_SearchLyrics.h"

@interface LyricsSearchWnd : NSWindowController {
    
    @private
    IBOutlet NSTextField *IB_Text_Artist;
    IBOutlet NSTextField *IB_Text_Title;
    IBOutlet NSArrayController *IB_Array_Controller;
    IBOutlet NSComboBox *IB_ComboBox_Server;
    IBOutlet NSTableView *IB_TableView;
}

- (id)initWithArtist:(NSString *)artist initWithTitle:(NSString *)title;

@property (nonatomic, retain) NSString* SongTitle;
@property (nonatomic, retain) NSString* SongArtist;

@end
