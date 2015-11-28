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

@interface AlbumTableViewController : UIViewController {
    int rowUserSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableViewIB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mEditButtonIB;
@property (strong, nonatomic) AlbumListService *mAlbumList;

- (void) initAlbumList; 

@end
