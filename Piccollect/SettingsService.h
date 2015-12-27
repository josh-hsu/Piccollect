//
//  SettingsService.h
//  Piccollect
//
//  Created by Josh on 2015/12/15.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsService : NSObject

// Plist token
#define STOKEN_PASSWORD_REQ   @"passwordRequired"
#define STOKEN_NIGHT_MODE     @"nightMode"
#define STOKEN_CLOUD_SAVE     @"saveToCloud"
#define STOKEN_SOCIAL_DICT    @"socialAccounts"
#define STOKEN_FACEBOOK       @"facebook"
#define STOKEN_TWITTER        @"twitter"
#define STOKEN_INSTAGRAM      @"instagram"
#define STOKEN_TUMBLR         @"tumblr"
#define STOKEN_ACC_TOKEN      @"accountToken"
#define STOKEN_ACC_NAME       @"accountName"

// Setting list
@property (nonatomic, copy) NSString *mSettingListPath;
@property (nonatomic, retain) NSMutableDictionary *mSettingList;

@end
