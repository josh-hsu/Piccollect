//
//  AlbumTableViewController.h
//  Piccollect
//
//  Created by Josh on 2015/11/21.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "AlbumListService.h"
#import "PasswordViewController.h"
#import "SettingsService.h"
#import "CoreService/ShareExtensionHandler.h"

@interface AlbumTableViewController : UIViewController <StartViewControllerDelegate> {
    int rowUserSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableViewIB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mEditButtonIB;
@property (strong, nonatomic) AlbumListService *mAlbumList;
@property (retain, nonatomic) SettingsService *mSettingsService;

- (void) initAlbumList; 

@end
