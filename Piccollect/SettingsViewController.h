//
//  SettingsViewController.h
//  Piccollect
//
//  Created by Josh on 2015/12/29.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsService.h"
#import "AlbumListService.h"

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *mSwitchEncryptAlbums;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitchNightMode;
@property (weak, nonatomic) IBOutlet UITableViewCell *mCellCompressPhotos;
@property (weak, nonatomic) IBOutlet UITableViewCell *mCellEncryptAlbums;
@property (weak, nonatomic) IBOutlet UITableViewCell *mCellNightMode;

@property (retain, nonatomic) SettingsService *mSettingService;
@property (retain, nonatomic) AlbumListService *mAlbumListService;


@end
