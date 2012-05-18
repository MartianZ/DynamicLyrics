//
//  BingTranslator.m
//  V-for-Lyrics
//
//  Created by Zheng Zhu on 11-8-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BingTranslator.h"
#import "RequestSender.h"

@implementation BingTranslator

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//简体中文 - 繁体中文
+(NSString *)s2t:(NSString *)s
{   
    if (s == NULL || [s length] == 0)
    {
        return @"";
    }
    NSString *parameter = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)s,NULL,
                                    (CFStringRef)@"!*'();:@&amp;=+$,/?%#[] ",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=D730E24E73735C2DF15AC1E004903357669313A5&text=%@&from=zh-CHS&to=zh-CHT",parameter];
    //NSLog(@"%@",url);
    NSString *content = [RequestSender sendRequest:url];
    NSMutableString *result = [NSMutableString stringWithString:content];
    [result setString:[result substringFromIndex:[result rangeOfString:@"Serialization/\">"].location + 16]];
    [result setString:[result substringToIndex:[result rangeOfString:@"</string>"].location]];
    return result;
}

//繁体中文 - 简体中文
+(NSString *)t2s:(NSString *)s
{   
    if (s == NULL || [s length] == 0)
    {
        return @"";
    }
    NSString *parameter = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)s,NULL,
                                    (CFStringRef)@"!*'();:@&amp;=+$,/?%#[] ",kCFStringEncodingUTF8);
    NSString *url = [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=D730E24E73735C2DF15AC1E004903357669313A5&text=%@&from=zh-CHT&to=zh-CHS",parameter];
    
    //这里必须强制规定原语言是zh-CHT 不然会导致日语里面的繁体汉字不被翻译，进而影响歌曲搜索。
    
    //NSLog(@"%@",url);
    NSString *content = [RequestSender sendRequest:url];
    NSMutableString *result = [NSMutableString stringWithString:content];
    [result setString:[result substringFromIndex:[result rangeOfString:@"Serialization/\">"].location + 16]];
    [result setString:[result substringToIndex:[result rangeOfString:@"</string>"].location]];
    return result;
}

@end
