//
//  RequestSender.h
//  MusicSeeker
//
//  Created by Martian on 11-6-3.
//  Copyright 2011 Martian. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RequestSender : NSObject {

}

+ (NSString*)sendRequest:(NSString*)url;
+ (NSData*)fetchRequest:(NSString*)url;

@end
