//
//  GeCiMeLyrics.h
//  LyricX
//
//  Created by Martian Z on 14-4-21.
//  Copyright (c) 2014年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestSender.h"
#import "KeyValue_SearchLyrics.h"

@interface GeCiMeLyrics : NSObject {
    
}

+(NSString*)getLyricsByTitle:(NSString*)Title getLyricsByArtist:(NSString*)Artist;

+(void)getLyricsListByTitle:(NSString *)Title getLyricsListByArtist:(NSString *)Artist AddToArrayController:(NSArrayController*)array_controller Server:(NSInteger)server;

+(NSString*)getLyricsByTitle:(NSString *)Title getLyricsByArtist:(NSString *)Artist getLyricsByID:(NSString *)ID;

@end
