//
//  GeCiMeLyrics.m
//  LyricX
//
//  Created by Martian Z on 14-4-21.
//  Copyright (c) 2014年 Martian. All rights reserved.
//

#import "GeCiMeLyrics.h"

@implementation GeCiMeLyrics

+(NSString*)getLyricsByTitle:(NSString *)Title getLyricsByArtist:(NSString *)Artist
{
    NSData *json = [RequestSender fetchRequest:[[NSString stringWithFormat:@"http://geci.me/api/lyric/%@/%@", Title, Artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSError* error = nil;
    
    id responseBody = [NSJSONSerialization JSONObjectWithData:json
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
    
    if (error || !responseBody) goto fail;
    NSInteger lrcCount = [[responseBody objectForKey:@"count"] integerValue];
    
    if (lrcCount <= 0) goto fail;
    
    NSString *lrcURL = [[[responseBody objectForKey:@"result"] objectAtIndex:0] objectForKey:@"lrc"];
    
    NSString *lyrics = [RequestSender sendRequest:lrcURL];
    
    if (!lyrics) goto fail;
    
    return lyrics;

    
fail:
    return @"";

}

+(void)getLyricsListByTitle:(NSString *)Title getLyricsListByArtist:(NSString *)Artist AddToArrayController:(NSArrayController*)array_controller Server:(NSInteger)server;
{
    
    [array_controller removeObjects:[array_controller arrangedObjects]];

    
    NSData *json = [RequestSender fetchRequest:[[NSString stringWithFormat:@"http://geci.me/api/lyric/%@/%@", Title, Artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSError* error = nil;
    
    id responseBody = [NSJSONSerialization JSONObjectWithData:json
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
    
    if (error || !responseBody) goto fail;
    NSInteger lrcCount = [[responseBody objectForKey:@"count"] integerValue];
    
    if (lrcCount <= 0) goto fail;
    
    for(int i = 0; i < lrcCount; i++)
    {
        NSDictionary *tempDict = [[responseBody objectForKey:@"result"] objectAtIndex:i];
        KeyValue_SearchLyrics* keyValue_SearchLyrics = [[KeyValue_SearchLyrics alloc] initWithID:[tempDict objectForKey:@"lrc"] initWithTitle:[tempDict objectForKey:@"song"] initWithArtist:@""];
        
        [array_controller addObject:keyValue_SearchLyrics];
        [keyValue_SearchLyrics release];
    }
    
    
fail:
    return;
    
}

@end
