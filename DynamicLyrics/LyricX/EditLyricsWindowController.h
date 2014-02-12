//
//  EditLyricsWindowController.h
//  LyricX
//
//  Created by Zeray Rice on 2014/02/12.
//  Copyright (c) 2014年 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditLyricsWindowController : NSWindowController

@property (nonatomic, retain) NSString* SongLyrics;
@property (nonatomic, retain) NSString* SongArtist;
@property (nonatomic, retain) NSString* SongName;

- (id)initWithLyrics:(NSString *)Lyrics artist:(NSString *)artist name:(NSString *)name;

@end
