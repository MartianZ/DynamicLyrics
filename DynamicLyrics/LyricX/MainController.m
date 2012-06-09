//
//  MainController.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import "MainController.h"

@implementation MainController

@synthesize iTunesCurrentTrack;
@synthesize SongLyrics;
@synthesize CurrentSongLyrics;
@synthesize lyrics;


- (id)initWithMenu:(NSMenu *)AppMenu
{
    self = [super init];
    if (self) {
        NSLog(@"%@",@"Initialization");
        
        lyrics = [[NSMutableArray alloc] init];
        
        nc = [NSNotificationCenter defaultCenter];
        dnc = [NSDistributedNotificationCenter defaultCenter];
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        [dnc addObserver:self selector:@selector(iTunesPlayerInfo:) name:@"com.apple.iTunes.playerInfo" object:nil];
        [nc addObserver:self selector:@selector(UserLyricsChanged:) name:@"UserLyricsChanged" object:nil];
        
        //if iTunes is running when the application launched
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

        if ([iTunes isRunning] && [[iTunes currentTrack] name]) {
            [self iTunesPlayerInfo:nil];
        }
        
        [NSThread detachNewThreadSelector:@selector(iTunesMonitoringThread) toTarget:self withObject:nil];

        MBLyrics = [[MenuBarLyrics alloc] initWithMenu:AppMenu];

        NSRect frame = NSScreen.mainScreen.frame;
        LyricsWindow = [[FloatPanel alloc] initWithContentRect:frame];
        NSView *LView = [[PanelView alloc] initWithFrame:frame];
        LyricsWindow.contentView = LView;
        [LView release];
        [LyricsWindow makeKeyAndOrderFront:nil];
        
        NSLog(@"%@",@Pref_Enable_Desktop_Lyrics);

    }
    
    return self;
}


-(void)dealloc
{
    [nc removeObserver:self];
    [dnc removeObserver:self];
    self.SongLyrics = nil;
    self.iTunesCurrentTrack = nil;
    self.CurrentSongLyrics = nil;
    [super dealloc];
}

- (void) iTunesPlayerInfo:(NSNotification *)note
{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if ([[[note userInfo] objectForKey:@"Player State"] isEqualToString:@"Stopped"]) {
        [nc postNotificationName:@"LyricsChanged" object:self userInfo:[NSDictionary dictionaryWithObject:@"DynamicLyrics!" forKey:@"Lyrics"]];
        return;
    }
    
    
    if ((note != nil) && (![[[note userInfo] objectForKey:@"Player State"] isEqualToString:@"Playing"])) {
        return;
    }
    
    if (self.iTunesCurrentTrack == [iTunes currentTrack]) return;
    self.iTunesCurrentTrack = [iTunes currentTrack];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithString:@"iTunesSongChanged"] forKey:@"Type"];
    [self WorkingThread:dict];
    
}

-(void) UserLyricsChanged:(NSNotification *)note
{
    NSString *SongTitle = [[note userInfo] objectForKey:@"SongTitle"];
    NSString *SongArtist = [[note userInfo] objectForKey:@"SongArtist"];
    if ([userDefaults valueForKey:[NSString stringWithFormat:@"%@%@",SongArtist,SongTitle]])
    {
        self.SongLyrics = [NSString stringWithString:[userDefaults valueForKey:[NSString stringWithFormat:@"%@%@",SongArtist,SongTitle]]];
        if ([[iTunesCurrentTrack name] isEqualToString:SongTitle])
        {
            [self Anylize];  //如果搜索的歌曲是当前正在播放的歌曲，重新加载歌词
            CurrentLyric = 0;
        }
        
    }
}

- (void) SearchLyrics:(NSMutableDictionary*)tmpDict
{
    NSString *SongTitle = [iTunesCurrentTrack name];
    NSString *SongArtist = [iTunesCurrentTrack artist];
    
    GB_BIG_Converter* _convertManager = [[GB_BIG_Converter alloc] init];
    
    self.SongLyrics = [QianQianLyrics getLyricsByTitle:[_convertManager big5ToGb:SongTitle] getLyricsByArtist:[_convertManager big5ToGb:SongArtist]];
    
    [userDefaults setValue:[NSString stringWithString:self.SongLyrics] forKey:[NSString stringWithFormat:@"%@%@",SongArtist,SongTitle]];
    
    [self performSelectorOnMainThread:@selector(Anylize) withObject:nil waitUntilDone:YES];

    
    [_convertManager release];
}

- (void) WorkingThread:(NSMutableDictionary*)tmpDict
{
    //this thread should work in main thread
    //iTunesPosition or iTunesSongChanged handler
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[tmpDict objectForKey:@"Type"] isEqualToString:@"iTunesSongChanged"])
    {
        //iTunesSongChanged
        NSLog(@"%@",[iTunesCurrentTrack name]);
        NSString *SongTitle = [iTunesCurrentTrack name];
        NSString *SongArtist = [iTunesCurrentTrack artist];
        
        self.CurrentSongLyrics = [NSString stringWithFormat:@"正在播放：%@ - %@",SongTitle,SongArtist];
        [nc postNotificationName:@"LyricsChanged" object:self userInfo:[NSDictionary dictionaryWithObject:self.CurrentSongLyrics forKey:@"Lyrics"]];
        
        
        if ([userDefaults valueForKey:[NSString stringWithFormat:@"%@%@",SongArtist,SongTitle]])
        {
            self.SongLyrics = [NSString stringWithString:[userDefaults valueForKey:[NSString stringWithFormat:@"%@%@",SongArtist,SongTitle]]];
            CurrentLyric = 0;
            [self Anylize];
        }
        else
        {
            //搜索歌词
            CurrentLyric = 0;
            [NSThread detachNewThreadSelector:@selector(SearchLyrics:) toTarget:self withObject:tmpDict];
            
            
        }

        
    }
    else
    {
        //iTunesPosition
        NSString *_currentPlayerPosition = [NSString stringWithString:[tmpDict objectForKey:@"currentPlayerPosition"]];
        unsigned long currentPlayerPosition = (long)[_currentPlayerPosition longLongValue];
        long Total = [lyrics count];
        
        if (Total > 0)
        {
            NSNumber *tempNumber;
            @try {
                
                if (CurrentLyric < Total - 1) //如果已经是最后一句歌词了，不执行向后搜索
                {
                    tempNumber = [[lyrics objectAtIndex:CurrentLyric + 1] objectForKey:@"Time"]; 
                    //tempNumber 当前歌词的下一句歌词的时间
                    while ([tempNumber longValue] < currentPlayerPosition && CurrentLyric < Total - 1) 
                    {
                        CurrentLyric += 1;
                        if (CurrentLyric == Total - 1) break; //如果已经是最后一句歌词 不再比较 退出
                        tempNumber = [[lyrics objectAtIndex:CurrentLyric + 1] objectForKey:@"Time"];
                    }
                }
                
                tempNumber = [[lyrics objectAtIndex:CurrentLyric] objectForKey:@"Time"];  //当前歌词的时间
                if (CurrentLyric > 0) //如果已经是第一句歌词了，不执行向前搜索
                {
                    while ([tempNumber longValue] > currentPlayerPosition && CurrentLyric > 1) 
                    {
                        CurrentLyric -= 1;
                        tempNumber = [[lyrics objectAtIndex:CurrentLyric] objectForKey:@"Time"];
                    }
                }
                
                NSString* lyric = [[NSString alloc]initWithFormat:@"%@",[NSString stringWithString:[[lyrics objectAtIndex:CurrentLyric] objectForKey:@"Content"]]];
                if (![self.CurrentSongLyrics isEqualToString:lyric])
                {
                    self.CurrentSongLyrics = lyric;
                    [nc postNotificationName:@"LyricsChanged" object:self userInfo:[NSDictionary dictionaryWithObject:self.CurrentSongLyrics forKey:@"Lyrics"]];
                    
                }
                [lyric release];
            }
            @catch (NSException *exception) {
            }
        }
        else
        {
            //未找到歌词
            
        }

    }
    [pool release];
}

-(long) ToTime:(NSString*)s
{
    NSString *RegEx = [NSString stringWithString:@"^(\\d+):(\\d+)(\\.(\\d+))?$"];
    NSArray *matchArray = nil;
    matchArray = [s arrayOfCaptureComponentsMatchedByRegex:RegEx options:RKLCaseless range:NSMakeRange(0UL, [s length]) error:NULL];
    if (matchArray)
    {
        NSArray *tempArray = [matchArray objectAtIndex:0];
        NSString *ms = [NSString stringWithString:[tempArray objectAtIndex:4]];
        if ([ms length] == 1) [ms stringByAppendingString:@"00"];
        if ([ms length] == 2) [ms stringByAppendingString:@"0"];
        NSString *_tmp1 = [NSString stringWithString:[tempArray objectAtIndex:1]];
        NSString *_tmp2 = [NSString stringWithString:[tempArray objectAtIndex:2]];
        unsigned long ans = ([_tmp1 intValue]) * 60 * 1000 + ([_tmp2 intValue]) * 1000 + [ms intValue];
        return ans;
    }
    else
    {
        return 0;
    }
    
}

- (void)Anylize
{

    NSString *RegEx = [NSString stringWithString:@"^((\\[\\d+:\\d+\\.\\d+\\])+)(.*?)$"]; 
    [lyrics removeAllObjects];
    
    NSArray *matchArray = nil;
    matchArray = [self.SongLyrics arrayOfCaptureComponentsMatchedByRegex:RegEx options:RKLMultiline | RKLCaseless range:NSMakeRange(0UL, [self.SongLyrics length]) error:nil];
    
    for(int i=0; i<[matchArray count]; i++)
    {
        NSArray *tempArray = [matchArray objectAtIndex:i];
        NSString *a = [NSString stringWithString:[tempArray objectAtIndex:1]];
        NSString *b = [NSString stringWithString:[tempArray objectAtIndex:3]];
        //分割多个时间标签
        NSArray *ACount = [a componentsSeparatedByString:@"]"];
        for (int j=0; j<[ACount count]-1; j++)
        {
            //新建一个字典
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            NSString *Time = [ACount objectAtIndex:j];
            Time = [Time stringByReplacingOccurrencesOfString:@"[" withString:@""];
            
            [tempDict setObject:[NSNumber numberWithLong:[self ToTime:Time]] forKey:@"Time"];
            [tempDict setObject:b forKey:@"Content"];
            [lyrics addObject:tempDict];
        }
    }
    
    NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"Time" ascending:YES] autorelease];
    [lyrics sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
}

- (void)iTunesMonitoringThread
{
    //This thread now will only handle the playing position and will no longer handle either the song name or the lyrics
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

    while (![iTunes isRunning])
    {
        //if iTunes is not running, we should wait for it rather than launch it
        //once iTunes is launched, this loop will stop
        sleep(1);
    }
    unsigned long currentPlayerPosition = 0;
    unsigned long PlayerPosition = 0;   
    while (true) {
        currentPlayerPosition += 100;
        usleep(100000); //1000微秒 = 1毫秒
        if ([iTunes playerState] != iTunesEPlSPlaying) {
            usleep(100000);
            continue;
        }
        PlayerPosition = [iTunes playerPosition];
        if ((currentPlayerPosition / 1000) != PlayerPosition)
            currentPlayerPosition = PlayerPosition * 1000;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        while (![iTunes isRunning] || ![[iTunes currentTrack] name])
        {
            sleep(1);
        }
        
        [dict setObject:[NSString stringWithString:@"iTunesPosition"] forKey:@"Type"];
        [dict setObject:[NSString stringWithFormat:@"%lu",currentPlayerPosition] forKey:@"currentPlayerPosition"];
        [self performSelectorOnMainThread:@selector(WorkingThread:) withObject:dict waitUntilDone:YES];
    }
}




@end
