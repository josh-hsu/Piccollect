//
//  SettingsService.m
//  Piccollect
//
//  Created by Josh on 2015/12/15.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "SettingsService.h"

@implementation SettingsService

- (id)init {
    int ret = -1;
    if (self = [super init]) {
        ret = [self initSettingList];
        
        if (ret == 0)
            return self;
    }
    return nil;
}

- (int)initSettingList {
    return 0;
}

@end
