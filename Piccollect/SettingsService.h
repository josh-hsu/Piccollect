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
#define STOKEN_PASSWORD       @"password"
#define STOKEN_NIGHT_MODE     @"nightMode"
#define STOKEN_CLOUD_SAVE     @"saveToCloud"
#define STOKEN_SOCIAL_DICT    @"socialAccounts"
#define STOKEN_FACEBOOK       @"facebook"
#define STOKEN_TWITTER        @"twitter"
#define STOKEN_INSTAGRAM      @"instagram"
#define STOKEN_TUMBLR         @"tumblr"
#define STOKEN_ACC_TOKEN      @"accountToken"
#define STOKEN_ACC_NAME       @"accountName"
#define STOKEN_LOG_UPLOAD     @"ueLogUpload"
#define STOKEN_USE_TOUCHID    @"useTouchID"

// Constant
#define SETTINGS_LIST_NAME    @"settings"

// Setting list
@property (nonatomic, copy) NSString *mSettingListPath;
@property (nonatomic, retain) NSMutableDictionary *mSettingList;

// Photos document path
@property (nonatomic, retain) NSString *mDocumentRootPath;

// Getter
- (id) getValueOfPrimaryKey: (NSString *) key;
- (id) getValueOfSocialKey: (NSString *) key;

// Setter
- (int) setPrimaryKey: (NSString *) key withValue: (id) value;
- (int) setSocialKey: (NSString *) key withValue: (id) value;

@end
