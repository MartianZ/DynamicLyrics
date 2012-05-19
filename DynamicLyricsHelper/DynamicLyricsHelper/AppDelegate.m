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
    while (1) {
        while ([iTunes isRunning]) {
            sleep(2);
        }
        //ITUNES EXIT
        NSLog(@"%@",@"ITUNES EXIT");
        
        
        
        
        
        
        while (![iTunes isRunning]) {
            sleep(2);
        }
        //ITUNES START
        NSLog(@"%@",@"ITUNES START");
        
        
        
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
