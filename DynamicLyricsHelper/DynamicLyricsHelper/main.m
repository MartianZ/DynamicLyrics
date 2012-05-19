//
//  main.m
//  DynamicLyricsHelper
//
//  Created by Martian on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"


int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[NSApplication sharedApplication] setDelegate:[[AppDelegate alloc] init]];
	[NSApp run];
	[pool release];
	return 0;
}
