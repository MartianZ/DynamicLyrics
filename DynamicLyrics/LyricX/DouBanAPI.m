//
//  DouBanAPI.m
//  LyricX
//
//  Created by Martian on 12-4-7.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "DouBanAPI.h"

@implementation DouBanAPI 

@synthesize SongArtwork;

-(id)init
{
    self = [super init];
    if (self) {
        SongArtwork = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)SearchArtwork:(NSString* )q
{
    [SongArtwork removeAllObjects];
    //api.douban.com/music/subjects?q=Departures%20~あなたにおくるアイの歌~&max-results=30
    
    NSString *parameter = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)q,NULL,
                                                                              (CFStringRef)@"!*'();:@&amp;=+$,/?%#[] ",kCFStringEncodingUTF8);
    
   
    NSString *URL = [NSString stringWithFormat:@"http://api.douban.com/music/subjects?q=%@&max-results=30&apikey=058a7fc77af5da75109f7f5670e18f5f",parameter];

    [parameter release];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:URL]];
	[request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
    
	NSHTTPURLResponse* urlResponse = nil;  
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:NULL];
    
	NSString *result = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	[request release];
    NSLog(@"%ld",[urlResponse statusCode]);

    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) 
    {
        NSArray* lines = [result componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        for (NSString* str in lines)
        {
            if ([str hasSuffix:@"rel=\"image\"/>"])
            {
                NSMutableString *newString = [[NSMutableString alloc]initWithString:str];
                [newString setString: [str substringFromIndex:[str rangeOfString:@"http:"].location]];
                [newString setString:[newString substringToIndex:[newString rangeOfString:@"\""].location]];
                [newString setString:[newString stringByReplacingOccurrencesOfString:@"spic" withString:@"lpic"]];
                [SongArtwork addObject:newString];
                [newString release];
                
            }
        }

    }
    

}


@end
