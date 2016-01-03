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
@synthesize mSwitchEncryptAlbums, mSwitchNightMode, mSwitchUseTouchID, mSwitchLogUpload, mTextPasswordSetting;
@synthesize mSettingService, mAlbumListService;

#define LSTR(arg) NSLocalizedString(arg, nil)

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
    
    if ([[mSettingService getValueOfPrimaryKey:STOKEN_PASSWORD] isEqualToString:@""]) {
        [mTextPasswordSetting setText:LSTR(@"No Password")];
    } else {
        [mTextPasswordSetting setText:LSTR(@"Password is set")];
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
        [self changePassword];
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

#pragma mark - Table view controller events

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (mCellPasswordSetting == theCellClicked) {
        if ([[mSettingService getValueOfPrimaryKey:STOKEN_PASSWORD_REQ] boolValue])
            [self changePassword];
    }
    
    if(mCellCompressPhotos == theCellClicked) {
        NSLog(@"compress photo hits");
    }
    
    // Deselect that cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Prompt message handler

- (void)changePassword {
    if (![mSettingService getValueOfPrimaryKey:STOKEN_PASSWORD_REQ]) {
        return;
    }

    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:LSTR(@"New Password")
                                  message:LSTR(@"Please enter password")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:LSTR(@"Cancel") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LSTR(@"Finish") style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *userInput = [alert.textFields objectAtIndex:0].text;
                                                   NSString *secondInput = [alert.textFields objectAtIndex:1].text;
                                                   if (![userInput isEqualToString:@""] && ![secondInput isEqualToString:@""]) {
                                                       NSLog(@"Get user's input %@", userInput);
                                                       if ([userInput isEqualToString:secondInput]) {
                                                           [mSettingService setPrimaryKey:STOKEN_PASSWORD withValue:userInput];
                                                           [mTextPasswordSetting setText:LSTR(@"Password is set")];
                                                       } else {
                                                           NSLog(@"Passwords mismatch");
                                                           alert.message = LSTR(@"Error: Two passwords are not matched!");
                                                           [self presentViewController:alert animated:YES completion:nil];
                                                       }
                                                   } else {
                                                       NSLog(@"Please fill the empty text");
                                                       alert.message = LSTR(@"Error: Some fields are empty!");
                                                       [self presentViewController:alert animated:YES completion:nil];
                                                   }
                                               }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = LSTR(@"Password");
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = LSTR(@"Enter again");
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
