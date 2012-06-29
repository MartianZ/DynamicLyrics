//
//  AppDelegate.m
//  DynamicLyricsHelper
//
//  Created by Martian on 12-5-19.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "AppDelegate.h"
#include "iTunes.h"
/*
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


#define DEFAULT_INTERVAL 2
#define DEFAULT_LOGFILE "daemon.txt"*/

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    bool a = false;
    while (1) {
        while ([iTunes isRunning]) {
            a = true;
            sleep(1);
        }
        if (a) {
            //ITUNES EXIT
            /*NSLog(@"%@",@"ITUNES EXIT");
            
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/sh"];
            [task setArguments:[NSArray arrayWithObjects:@"-c", @"killall DynamicLyrics", nil]];
            [task launch];
            [task waitUntilExit];
            [task release];*/ //I HATE SANDBOX
        }
        while (![iTunes isRunning]) {
            sleep(1);
        }
        //ITUNES START
        NSLog(@"%@",@"ITUNES START");

        NSString *path = [[NSString alloc] initWithString:[[NSBundle mainBundle] bundlePath]];
        
        [[NSWorkspace sharedWorkspace] launchApplication:[path stringByReplacingOccurrencesOfString:@"/Contents/Library/LoginItems/DynamicLyricsHelper.app" withString:@"/Contents/MacOS/DynamicLyrics"]];
        //
        // /Users/Martian/Desktop/DynamicLyrics.app/Contents/Library/LoginItems/DynamicLyricsHelper.app
               
    }

    exit(0);
    
    
    /*pid_t pid, sid;
    pid = fork();

    umask(0);
    
    sid = setsid();
    
    if (sid < 0) {
		exit(EXIT_FAILURE);
    }
    

    //SON THREAD
    printf("sid=%d\n",sid);
  	if ((chdir("/Users/Martian/Desktop/")) < 0) {
		printf("chdir error\n");
		exit(EXIT_FAILURE);
    }

    while (1) {

        
        
    }
    exit(0);*/
}

@end
