//
//  AlbumTableViewController.m
//  Piccollect
//
//  Created by Josh on 2015/11/21.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "AlbumCollectionViewController.h"
#import "AlbumListService.h"
#import "Album.h"

@interface AlbumTableViewController ()

@end

@implementation AlbumTableViewController

@synthesize mAlbumList;
@synthesize mTableViewIB;

#pragma mark - list access

- (void)initAlbumList {
    mAlbumList = [[AlbumListService alloc] init];
    
    if (mAlbumList != nil) {
        // Initial document path for storing photos
        NSLog(@"Loading album list from service, total: %d", mAlbumList.mCount);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSLog(@"Document path: %@", documentsDirectory);
        mAlbumList.mDocumentRootPath = documentsDirectory;
    }
}

#pragma mark - View cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self initAlbumList];
    [mAlbumList initPhotoFileDebug];
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
    [subtitleLabel setText:thisAlbum.mAlbumKey];
    topImageView.image = [[UIImage alloc] initWithContentsOfFile:[mAlbumList topPhotoInAlbum:thisAlbum]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AlbumCollectionViewController *collectionViewController = [segue destinationViewController];
    collectionViewController.mAlbum = [mAlbumList albumInListAtIndex:[mTableViewIB indexPathForSelectedRow].row];
    collectionViewController.mAlbumListService = mAlbumList;
}


@end
