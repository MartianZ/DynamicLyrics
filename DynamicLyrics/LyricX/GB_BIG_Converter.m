//
//  GB_BIG_Converter.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright (c) 2012年 Martian. All rights reserved.
//

#import "GB_BIG_Converter.h"

@implementation GB_BIG_Converter

@synthesize string_GB = _string_GB;
@synthesize string_BIG5 = _string_BIG5;

-(id) init
{
    [super init];
    if (self){
        NSError *error;
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        self.string_GB = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"gb.txt"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        self.string_BIG5 = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"big5.txt"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
        
      
    }
    return self;
}

-(NSString*)gbToBig5:(NSString*)srcString
{
	NSInteger length = [srcString length];
     for (NSInteger i = 0; i< length; i++)
     {
     NSString *string = [srcString substringWithRange:NSMakeRange(i, 1)];
     NSRange gbRange = [_string_GB rangeOfString:string];
     if(gbRange.location != NSNotFound)
     {
     NSString *big5String = [_string_BIG5 substringWithRange:gbRange];
     srcString = [srcString stringByReplacingCharactersInRange:NSMakeRange(i, 1)
     withString:big5String];
     }
     }
     
     return srcString;
}

-(NSString*)big5ToGb:(NSString*)srcString
{
	NSInteger length = [srcString length];
     for (NSInteger i = 0; i< length; i++)
     {
     NSString *string = [srcString substringWithRange:NSMakeRange(i, 1)];
     NSRange big5Range = [_string_BIG5 rangeOfString:string];
     if(big5Range.location != NSNotFound)
     {
     NSString *gbString = [_string_GB substringWithRange:big5Range];
     srcString = [srcString stringByReplacingCharactersInRange:NSMakeRange(i, 1)
     withString:gbString];
     }
     }
    NSLog(@"%@",srcString);
     return srcString;
}


@end
