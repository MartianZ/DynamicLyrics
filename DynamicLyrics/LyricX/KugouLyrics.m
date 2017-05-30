//
//  KugouLyrics.m
//  LyricX
//
//  Created by LuoShihui on 2017/3/27.
//  Copyright © 2017年 Martian. All rights reserved.
//

#import "KugouLyrics.h"

@implementation KugouLyrics

+(NSString*)getLyricsByTitle:(NSString*)Title getLyricsByArtist:(NSString*)Artist getLyricsBySongDuration:(double)duration {
    double songDuration = duration * 1000;
    NSString *url = [[NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@&duration=%.0f&hash=", Title, songDuration] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *json = [RequestSender fetchRequest:url];
    NSError* error = nil;
    id responseBody = [NSJSONSerialization JSONObjectWithData:json
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
    
    if (error || !responseBody) goto fail;
    
    NSInteger status = [[responseBody objectForKey:@"status"] integerValue];
    if (status != 200) goto fail;
    
    NSArray *searchList = [responseBody objectForKey:@"candidates"];
    if (searchList.count <= 0) goto fail;
    
    float minInterval = songDuration;
    NSDictionary *bestDict;
    for (NSDictionary *dict in searchList) {
        float durationA = [[dict objectForKey:@"duration"] floatValue];
        if (fabs(durationA - songDuration) < minInterval) {
            minInterval = fabs(durationA - songDuration);
            bestDict = dict;
        }
    }
    
    if (!bestDict) goto fail;
    NSString *ID = [bestDict objectForKey:@"id"];
    NSString *accesskey = [bestDict objectForKey:@"accesskey"];
    
    NSString *lyrics = [self getLyricsByID:ID getLyricsByAccesskey:accesskey];
    
    if (!lyrics) goto fail;
    
    return lyrics;
fail:
    return @"";
}

+(NSString*)getLyricsByID:(NSString*)ID getLyricsByAccesskey:(NSString*)accesskey {
    NSData *json = [RequestSender fetchRequest:[[NSString stringWithFormat:@"http://lyrics.kugou.com/download?ver=1&client=pc&id=%@&accesskey=%@&fmt=lrc&charset=utf8", ID, accesskey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError* error = nil;
    id responseBody = [NSJSONSerialization JSONObjectWithData:json
                                                      options:NSJSONReadingMutableContainers
                                                        error:&error];
    
    if (error || !responseBody) goto fail;
    
    NSInteger status = [[responseBody objectForKey:@"status"] integerValue];
    if (status != 200) goto fail;
    
    NSString *lrcContent = [responseBody objectForKey:@"content"];
    if (lrcContent.length <= 0) goto fail;
    NSData *lyricsData = [[NSData alloc] initWithBase64EncodedString:lrcContent options:0];
    NSString *lyrics = [[NSString alloc] initWithData:lyricsData encoding:NSUTF8StringEncoding];
    if (!lyrics) goto fail;
    return lyrics;
fail:
    return @"";
}

+(void)getLyricsListByTitle:(NSString *)Title getLyricsListByArtist:(NSString *)Artist getLyricsBySongDuration:(double)duration AddToArrayController:(NSArrayController*)array_controller {
    [array_controller removeObjects:[array_controller arrangedObjects]];
    @try {
        double songDuration = duration * 1000;
        NSData *json = [RequestSender fetchRequest:[[NSString stringWithFormat:@"http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%@%@&duration=%.0f&hash=", Title, Artist, songDuration] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSError* error = nil;
        id responseBody = [NSJSONSerialization JSONObjectWithData:json
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
        
        if (error || !responseBody) return;
        
        NSInteger status = [[responseBody objectForKey:@"status"] integerValue];
        if (status != 200) return;
        
        NSArray *searchList = [responseBody objectForKey:@"candidates"];
        if (searchList.count <= 0) return;
        
        for (NSDictionary *dict in searchList) {
            NSString *singer = [dict objectForKey:@"singer"];
            NSString *ID = [dict objectForKey:@"id"];
            NSString *song = [dict objectForKey:@"song"];
            NSString *accesskey = [dict objectForKey:@"accesskey"];
            NSString *duration = [dict objectForKey:@"duration"];
            KeyValue_SearchLyrics* keyValue_SearchLyrics = [[KeyValue_SearchLyrics alloc] initWithID:ID initWithAccessKey:accesskey initWithTitle:song initWithArtist:singer initWithDuration:duration];
            [array_controller addObject:keyValue_SearchLyrics];
            [keyValue_SearchLyrics release];
        }
    }
    @catch (NSException *exception) {
        return;
    }
}

@end



/*
 1. 通过关键词(歌名+歌手)+时长 搜索歌曲
 http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%E4%B9%9D%E5%84%BF%E8%B0%AD%E6%99%B6&duration=292896&hash=
 {
 "info": "OK",
 "status": 200,
 "proposal": "22648922",
 "keyword": "九儿谭晶",
 "candidates": [
 {
 "soundname": "",
 "krctype": 2,
 "nickname": "董昭華",
 "originame": "",
 "accesskey": "8B7F267336274532A756C632DC021EE4",
 "origiuid": "0",
 "score": 60,
 "hitlayer": 7,
 "duration": 292937,
 "sounduid": "0",
 "transname": "",
 "uid": "638665221",
 "transuid": "0",
 "song": "九儿",
 "id": "22648922",
 "adjust": 0,
 "singer": "谭晶",
 "language": ""
 },
 {
 "soundname": "",
 "krctype": 2,
 "nickname": "",
 "originame": "",
 "accesskey": "8C5E0EE1922358A0305F3E867F119717",
 "origiuid": "0",
 "score": 50,
 "hitlayer": 7,
 "duration": 292896,
 "sounduid": "0",
 "transname": "",
 "uid": "975866862",
 "transuid": "0",
 "song": "九儿",
 "id": "22648600",
 "adjust": 0,
 "singer": "谭晶",
 "language": ""
 }
 ]
 }
 
 2. 取上面结果中最匹配结果中的id+accesskey 下载歌词,
 http://lyrics.kugou.com/download?ver=1&client=pc&id=22648600&accesskey=8C5E0EE1922358A0305F3E867F119717&fmt=lrc&charset=utf8
 {
 "charset": "utf8",
 "content": "WzAwOjAwLjcyXeiwreaZtiAtIOS5neWEvyhMaXZlKQ0KWzAwOjAxLjgzXeS9nOivje+8muS9leWFtueOsuOAgemYv+mysg0KWzAwOjAzLjQwXeS9nOabsu+8mumYv+mysg0KWzAwOjA0LjMxXeWOn+WUse+8mumfqee6og0KWzAwOjA1LjE3Xee8luabsu+8mumXq+WkqeWNiA0KWzAwOjA2LjIzXeWUouWRkO+8mumZiOWKm+WunQ0KWzAwOjM3Ljc2Xei6q+i+ueeahOmCo+eJh+eUsOmHjg0KWzAwOjQ1LjY1XeaJi+i+ueeahOaeo+iKsemmmQ0KWzAwOjU0LjE1XemrmOeyseeGn+adpee6oua7oeWkqQ0KWzAxOjAxLjU0XeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzAxOjEwLjUwXei6q+i+ueeahOmCo+eJh+eUsOmHjg0KWzAxOjE4LjYwXeaJi+i+ueeahOaeo+iKsemmmQ0KWzAxOjI2Ljc0XemrmOeyseeGn+adpee6oua7oeWkqQ0KWzAxOjMzLjgwXeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzAyOjI3LjI0Xei6q+i+ueeahOmCo+eJh+eUsOmHjg0KWzAyOjM0LjA5XeaJi+i+ueeahOaeo+iKsemmmQ0KWzAyOjQxLjE4XemrmOeyseeGn+adpee6oua7oeWkqQ0KWzAyOjQ3LjMwXeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzAyOjU1LjI5Xei6q+i+ueeahOmCo+eJh+eUsOmHjg0KWzAzOjAyLjI4XeaJi+i+ueeahOaeo+iKsemmmQ0KWzAzOjA5LjMxXemrmOeyseeGn+adpee6oua7oeWkqQ0KWzAzOjE1LjQ5XeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzAzOjUxLjgxXemrmOaigeeGn+adpee6oua7oeWkqQ0KWzAzOjU4LjQ3XeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzA0OjA2LjQxXemrmOeyseeGn+adpee6oua7oeWkqQ0KWzA0OjIxLjgwXeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0KWzA0OjMwLjQyXeS5neWEv+aIkemAgeS9oOWOu+i/nOaWuQ0K",
 "fmt": "lrc",
 "info": "OK",
 "status": 200
 }
 
 3. 取结果的content字段内容, base64解码
 [00:00.72]谭晶 - 九儿(Live)
 [00:01.83]作词：何其玲、阿鲲
 [00:03.40]作曲：阿鲲
 [00:04.31]原唱：韩红
 [00:05.17]编曲：闫天午
 [00:06.23]唢呐：陈力宝
 [00:37.76]身边的那片田野
 [00:45.65]手边的枣花香
 [00:54.15]高粱熟来红满天
 [01:01.54]九儿我送你去远方
 [01:10.50]身边的那片田野
 [01:18.60]手边的枣花香
 [01:26.74]高粱熟来红满天
 [01:33.80]九儿我送你去远方
 [02:27.24]身边的那片田野
 [02:34.09]手边的枣花香
 [02:41.18]高粱熟来红满天
 [02:47.30]九儿我送你去远方
 [02:55.29]身边的那片田野
 [03:02.28]手边的枣花香
 [03:09.31]高粱熟来红满天
 [03:15.49]九儿我送你去远方
 [03:51.81]高梁熟来红满天
 [03:58.47]九儿我送你去远方
 [04:06.41]高粱熟来红满天
 [04:21.80]九儿我送你去远方
 [04:30.42]九儿我送你去远方
 
 
 */
