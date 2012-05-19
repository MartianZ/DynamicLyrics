//
//  GB_BIG_Converter.h
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GB_BIG_Converter : NSObject

@property(nonatomic, retain) NSString*	string_GB;
@property(nonatomic, retain) NSString*	string_BIG5;

-(NSString*)gbToBig5:(NSString*)srcString;
-(NSString*)big5ToGb:(NSString*)srcString;


@end
