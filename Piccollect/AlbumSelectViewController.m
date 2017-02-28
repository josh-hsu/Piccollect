//
//  AlbumSelectViewController.m
//  Piccollect
//
//  Created by Josh on 2017/2/28.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import "AlbumSelectViewController.h"

@interface AlbumSelectViewController ()

@end

@implementation AlbumSelectViewController

@synthesize mAlbumList, delegate;
@synthesize mTableViewIB, mEditButtonIB, mNavBarIB, mCancelButtonIB;

#define LSTR(arg) NSLocalizedString(arg, nil)

#pragma mark - list access

- (void)initAlbumList {
    mAlbumList = [[AlbumListService alloc] init];
    
    if (mAlbumList != nil) {
        NSLog(@"Loading album list from service, total: %d", mAlbumList.mCount);
    } else {
        NSLog(@"Initial AlbumListService failed, this is a serious BUG");
        abort();
    }
}

#pragma mark - View cycle

- (void)viewDidLoad {
    [self initAlbumList];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Because the selected row will not reset after user hit back button and return here
    [mTableViewIB deselectRowAtIndexPath:[mTableViewIB indexPathForSelectedRow] animated:YES];
    [self.mTableViewIB reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.mCancelButtonIB setTitle:LSTR(@"Cancel")];
    [self.mNavBarIB setTitle:LSTR(@"Album Select")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mAlbumList mCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumListTableCell" forIndexPath:indexPath];
    
    // Get the view on the cell prototype
    UIImageView *topImageView = [cell viewWithTag:1];
    UILabel *titleLabel = [cell viewWithTag:2];
    UILabel *subtitleLabel = [cell viewWithTag:3];
    
    // Configure view content
    Album *thisAlbum = [mAlbumList albumInListAtIndex:indexPath.row];
    [titleLabel setText:thisAlbum.mAlbumName];
    [subtitleLabel setText:[NSString stringWithFormat:@"%ld", [thisAlbum.mAlbumPhotos count]]];
    topImageView.image = [mAlbumList topPhotoInAlbum:thisAlbum];
 
    return cell;
}

#pragma mark - Table view delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath* )indexPath {
    NSLog(@"Table %ld has been tapped.", indexPath.row);
    Album *thisAlbum = [mAlbumList albumInListAtIndex:indexPath.row];
    
    [self.delegate albumSelectDidFinish: self albumKey:thisAlbum];
}


#pragma mark - IBAction

- (IBAction)cancelSelectAlbum:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
