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

@synthesize mCellCompressPhotos, mCellEncryptAlbums, mCellNightMode;
@synthesize mSwitchEncryptAlbums, mSwitchNightMode;
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
    }
    
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_NIGHT_MODE] boolValue]) {
        [mSwitchNightMode setOn:YES];
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
    } else {
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_PASSWORD_REQ withValue:value];
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

#pragma mark - Utility



@end
