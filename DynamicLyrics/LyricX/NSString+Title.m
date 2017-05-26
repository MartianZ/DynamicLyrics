//
//  NSString+Title.m
//  LyricX
//
//  Created by Frank on 26/05/2017.
//  Copyright © 2017 Martian. All rights reserved.
//

#import "NSString+Title.h"

@implementation NSString (Title)

- (NSString *)getRidOfUnusedIndexNumber{
    NSArray *separators = @[@" ", @"-", @"_", @"."];
    
    NSString *removedTitle = self;
    
    for (NSString *separator in separators) {
        removedTitle = [removedTitle getRidOfUnusedIndexNumberSeparatedByString:separator];
    }
    
    return removedTitle;
}

- (NSString *)getRidOfUnusedIndexNumberSeparatedByString:(NSString *)separator {
    NSArray *words = [self componentsSeparatedByString:separator];
    
    if (words.count > 1) {
        //简易判断头部是否为标号的快速方法
        if ([words[0] integerValue] != 0 || [words[0] isEqualToString:@"0"] || [words[0] isEqualToString:@"00"]) {
            NSMutableArray *removedIndexWords = [words mutableCopy];
            [removedIndexWords removeObjectAtIndex:0];
            
            return [removedIndexWords componentsJoinedByString:separator];
        }
    }
    
    return self;
}

@end
