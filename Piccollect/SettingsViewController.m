//
//  SettingsViewController.m
//  Piccollect
//
//  Created by Josh on 2015/12/29.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize mCellCompressPhotos, mCellEncryptAlbums, mCellNightMode, mCellLogUpload, mCellPasswordSetting, mCellUseTouchID;
@synthesize mSwitchEncryptAlbums, mSwitchNightMode, mSwitchUseTouchID, mSwitchLogUpload;
@synthesize mSettingService, mAlbumListService;

- (void)viewDidLoad {
    [super viewDidLoad];

    mSettingService = [[SettingsService alloc] init];
    mAlbumListService = [[AlbumListService alloc] init];

    if (!mSettingService || !mAlbumListService) {
		NSLog(@"FATAL: Cannot get setting service or album list service");
	}

    [self prepareView];
}

/*
 * We assumed the default switch value in storyboard is set to NO
 */
- (void)prepareView {
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_PASSWORD_REQ] boolValue]) {
        [mSwitchEncryptAlbums setOn:YES];
        [mSwitchUseTouchID setEnabled:YES];
    } else {
        [mSwitchUseTouchID setEnabled:NO];
    }
    
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_NIGHT_MODE] boolValue]) {
        [mSwitchNightMode setOn:YES];
    }
    
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_LOG_UPLOAD] boolValue]) {
        [mSwitchLogUpload setOn:YES];
    }
    
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_USE_TOUCHID] boolValue]) {
        [mSwitchUseTouchID setOn:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - IBAction

- (IBAction)didSetEncryptAlbums:(id)sender {
    UISwitch *switchView = (UISwitch *) sender;
    if ([switchView isOn]) {
        NSNumber *value = [[NSNumber alloc] initWithBool:YES];
        [mSettingService setPrimaryKey:STOKEN_PASSWORD_REQ withValue:value];
        [mSwitchUseTouchID setEnabled:YES];
    } else {
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_PASSWORD_REQ withValue:value];
        [mSwitchUseTouchID setEnabled:NO];
    }
}

- (IBAction)didSetNightMode:(id)sender {
    UISwitch *switchView = (UISwitch *) sender;
    if ([switchView isOn]) {
        NSNumber *value = [[NSNumber alloc] initWithBool:YES];
        [mSettingService setPrimaryKey:STOKEN_NIGHT_MODE withValue:value];
    } else {
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_NIGHT_MODE withValue:value];
    }
}

- (IBAction)didSetUseTouchID:(id)sender {
    UISwitch *switchView = (UISwitch *) sender;
    if ([switchView isOn]) {
        NSNumber *value = [[NSNumber alloc] initWithBool:YES];
        [mSettingService setPrimaryKey:STOKEN_USE_TOUCHID withValue:value];
    } else {
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_USE_TOUCHID withValue:value];
    }
}


- (IBAction)didSetUELogUpload:(id)sender {
    UISwitch *switchView = (UISwitch *) sender;
    if ([switchView isOn]) {
        NSNumber *value = [[NSNumber alloc] initWithBool:YES];
        [mSettingService setPrimaryKey:STOKEN_LOG_UPLOAD withValue:value];
    } else {
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_LOG_UPLOAD withValue:value];
    }
}

#pragma mark - Utility



@end
