//
//  AlbumSelectViewController.h
//  Piccollect
//
//  Created by Josh on 2017/2/28.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "AlbumListService.h"
@protocol AlbumSelectControllerDelegate;

@interface AlbumSelectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableViewIB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mEditButtonIB;
@property (weak, nonatomic) IBOutlet UINavigationItem *mNavBarIB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mCancelButtonIB;
@property (strong, nonatomic) AlbumListService *mAlbumList;
@property (retain, atomic) id <AlbumSelectControllerDelegate> delegate;

@end

@protocol AlbumSelectControllerDelegate <NSObject>
- (void)albumSelectDidCancel:(AlbumSelectViewController *)controller;
- (void)albumSelectDidFinish:(AlbumSelectViewController *)controller albumKey: (Album *) album;
@end
