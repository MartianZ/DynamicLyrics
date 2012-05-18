//
//  BingTranslator.h
//  V-for-Lyrics
//
//  Created by Zheng Zhu on 11-8-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BingTranslator : NSObject


+(NSString *)s2t:(NSString *)s;
+(NSString *)t2s:(NSString *)s;

@end
