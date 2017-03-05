//
//  SettingsService.m
//  Piccollect
//
//  Created by Josh on 2015/12/15.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "SettingsService.h"

@implementation SettingsService

@synthesize mSettingList, mSettingListPath, mDocumentRootPath;

static NSString* TAG = @"SettingService";

- (id) init {
    int ret = -1;
    if (self = [super init]) {
        ret = [self initSettingList];
        
        if (ret == 0)
            return self;
    }
    return nil;
}

/*
 * initSettingList
 *
 * This is the main entry of SettingsService
 * We should deal with every little details to prevent aborting
 */
- (int) initSettingList {
	NSError *errorDesc;
    NSPropertyListFormat format;

    // Initial document path for storing photos
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [Log LOG:TAG args:@"Document path: %@", documentsDirectory];
    mDocumentRootPath = documentsDirectory;

    // Find the new albums.plist inside the document folder
    mSettingListPath = [mDocumentRootPath stringByAppendingPathComponent:SETTINGS_LIST_NAME];

    // If we cannot find list in document folder, copy default list to document
    if (![[NSFileManager defaultManager] fileExistsAtPath:mSettingListPath]) {
        [Log LOG:TAG args:@"First use settings list, load default"];
        NSString *localListPath = [[NSBundle mainBundle] pathForResource:SETTINGS_LIST_NAME ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:localListPath toPath:mSettingListPath error:&errorDesc];
    }

    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:mSettingListPath];
    mSettingList = (NSMutableDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                              options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];

    if (!mSettingList) {
        [Log LOG:TAG args:@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format];
        return -1;
    }
    
    // Check if there is new value from update
    [self consistencyCheck];

    return 0;
}

/*
 * Traveral all the keys in current version on primary settings
 */
- (void)consistencyCheck {
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];

    [keyArray addObject:STOKEN_CLOUD_SAVE];
    [keyArray addObject:STOKEN_LOG_UPLOAD];
    [keyArray addObject:STOKEN_NIGHT_MODE];
    [keyArray addObject:STOKEN_PASSWORD_REQ];
    [keyArray addObject:STOKEN_USE_TOUCHID];
    
    [Log LOG:TAG args:@"Setting: Consistency check started"];
    for (NSString *key in keyArray) {
        id value = [self getValueOfPrimaryKey:key];
        if (value == nil) {
            NSNumber *value = [[NSNumber alloc] initWithBool:NO];
            [self setPrimaryKey:key withValue:value];
        }
    }
    
    if ([self getValueOfPrimaryKey:STOKEN_PASSWORD] == nil) {
        [self setPrimaryKey:STOKEN_PASSWORD withValue:@""];
    }
    [Log LOG:TAG args:@"Setting: Consistency check finished"];
}

#pragma mark - Getter functions
/* ===============================================================
 * Getter functions
 *
 * Each getter function might report an inconsist or unexpect value
 * You should deal with verification of each return
 * ===============================================================
 */
- (id) getValueOfPrimaryKey: (NSString *) key {
	id return_value;

	if (!key) {
		[Log LOG:TAG args:@"BUG: getValueOfPrimaryKey called with null key"];
		return nil;
	}

	return_value = [mSettingList objectForKey: key];
	if (!return_value) {
		[Log LOG:TAG args:@"BUG: the key %@ recently queried has a null return.", key];
	}

	return return_value;
}

- (id) getValueOfSocialKey: (NSString *) key {
	id return_value;
	NSDictionary *socialDict = [mSettingList objectForKey:STOKEN_SOCIAL_DICT];

	if (!key) {
		[Log LOG:TAG args:@"BUG: getValueOfPrimaryKey called with null key"];
		return nil;
	}

	return_value = [socialDict objectForKey: key];
	if (!return_value) {
		[Log LOG:TAG args:@"BUG: the key %@ recently queried has a null return.", key];
	}

	return return_value;
}

#pragma mark - Setter functions
/* ===============================================================
 * Setter functions
 * ===============================================================
 */

- (int) setPrimaryKey: (NSString *) key withValue: (id) value {
	if (!key || !value) {
		[Log LOG:TAG args:@"BUG: setPrimaryKey called with null key or null value"];
		return -1;
	}

	[mSettingList setObject:value forKey:key];
	[mSettingList writeToFile:mSettingListPath atomically:YES];
	return 0;
}

- (int) setSocialKey: (NSString *) key withValue: (id) value {
	return 0;
}

@end
