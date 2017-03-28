//
//  KeyValue_SearchLyrics.h
//  DynamicLyrics
//
//  Created by Martian on 11-8-12.
//  Copyright 2011 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyValue_SearchLyrics : NSObject{
    NSString *ID;
    NSString *AccessKey;
    NSString *LyricsTitle;
    NSString *LyricsArtist;
    NSString *LyricsDuration;
}


@property (readwrite, copy) NSString *ID;
@property (readwrite, copy) NSString *AccessKey;
@property (readwrite, copy) NSString *LyricsTitle;
@property (readwrite, copy) NSString *LyricsArtist;
@property (readwrite, copy) NSString *LyricsDuration;


-(id)initWithID:(NSString*)nID initWithAccessKey:(NSString *)nLyricsAccessKey initWithTitle:(NSString*)nLyricsTitle initWithArtist:(NSString*)nLyricsArtist initWithDuration:(NSString*)nLyricsDuration;

@end
