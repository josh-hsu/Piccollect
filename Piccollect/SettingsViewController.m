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
@synthesize mSwitchEncryptAlbums, mSwitchNightMode, mSettingService;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"view did load");
    mSettingService = [[SettingsService alloc] init];
    
    [self prepareView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) prepareView {
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_PASSWORD_REQ] boolValue]) {
        [mSwitchEncryptAlbums setOn:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didSetEncryptAlbums:(id)sender {
    UISwitch *switchView = (UISwitch *) sender;
    if ([switchView isOn]) {
        NSLog(@"isOn");
        NSNumber *value = [[NSNumber alloc] initWithBool:YES];
        [mSettingService setPrimaryKey:STOKEN_PASSWORD_REQ withValue:value];
    } else {
        NSLog(@"isOFF");
        NSNumber *value = [[NSNumber alloc] initWithBool:NO];
        [mSettingService setPrimaryKey:STOKEN_PASSWORD_REQ withValue:value];
    }
}


@end
