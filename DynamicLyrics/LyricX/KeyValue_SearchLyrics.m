//
//  KeyValue_SearchLyrics.m
//  DynamicLyrics
//
//  Created by Martian on 11-8-12.
//  Copyright 2011 Martian. All rights reserved.
//

#import "KeyValue_SearchLyrics.h"

@implementation KeyValue_SearchLyrics


@synthesize ID;
@synthesize AccessKey;
@synthesize LyricsTitle;
@synthesize LyricsArtist;
@synthesize LyricsDuration;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithID:(NSString*)nID initWithAccessKey:(NSString *)nLyricsAccessKey initWithTitle:(NSString*)nLyricsTitle initWithArtist:(NSString*)nLyricsArtist initWithDuration:(NSString*)nLyricsDuration
{
    self.ID = nID;
    self.AccessKey = nLyricsAccessKey;
    self.LyricsArtist = nLyricsArtist;
    self.LyricsTitle = nLyricsTitle;
    self.LyricsDuration = nLyricsDuration;
    return self;
}

@end
