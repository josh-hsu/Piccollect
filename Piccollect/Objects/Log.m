//
//  Log.m
//  Piccollect
//
//  Created by Josh on 2017/3/4.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Log.h"

@implementation Log

+ (void) LOG: (NSString *) TAG args: (NSString *)arg_list, ... {
    va_list args;
    va_start(args, arg_list);
    NSString *contents = [[NSString alloc] initWithFormat:arg_list arguments:args];
    NSString *log = [[NSString alloc] initWithFormat:@"[%@] %@", TAG, contents];
    NSLog(@"%@", log);
    va_end(args);
}

@end
