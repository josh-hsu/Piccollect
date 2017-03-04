//
//  Log.h
//  Piccollect
//
//  Created by Josh on 2017/3/4.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Log : NSObject {
    
}

+ (void) LOG: (NSString *) TAG args: (NSString *)arg_list, ...;

@end
