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
    NSString *LyricsTitle;
    NSString *LyricsArtist;
}


@property (readwrite, copy) NSString *ID;
@property (readwrite, copy) NSString *LyricsTitle;
@property (readwrite, copy) NSString *LyricsArtist;


-(id)initWithID:(NSString*)nID initWithTitle:(NSString*)nLyricsTitle initWithArtist:(NSString*)nLyricsArtist;

@end
