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
@synthesize mTableViewIB, mEditButtonIB;

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
    [super viewDidLoad];

    [self initAlbumList];
    //[mAlbumList initPhotoFileDebug]; /* Setting default photo from library automatically */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Because the selected row will not reset after user hit back button and return here
    [mTableViewIB deselectRowAtIndexPath:[mTableViewIB indexPathForSelectedRow] animated:YES];
    
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
    topImageView.image = [mAlbumList topPhotoInAlbum:thisAlbum];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Album *thisAlbum = [mAlbumList albumInListAtIndex:indexPath.row];
        [mAlbumList removeAlbumWithKey:thisAlbum.mAlbumKey deletePhotos:NO];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"刪除";
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AlbumCollectionViewController *collectionViewController = [segue destinationViewController];
    collectionViewController.mAlbum = [mAlbumList albumInListAtIndex:[mTableViewIB indexPathForSelectedRow].row];
    collectionViewController.mAlbumListService = mAlbumList;
}

#pragma mark - IBActions

// Add album
- (IBAction)addNewAlbum:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"新增相簿"
                                  message:@"請輸入名稱"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *userInput = [alert.textFields objectAtIndex:0].text;
                                                   if (![userInput isEqualToString:@""]) {
                                                       NSLog(@"Get user's input %@", userInput);
                                                       [self.mAlbumList createAlbumWithName:userInput];
                                                       [self.mTableViewIB reloadData];
                                                   }
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"標題";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)editTableVIew:(id)sender {
    static BOOL isEditing = NO;
    
    if (!isEditing) {
        mEditButtonIB.title = @"完成";
        [self.mTableViewIB setEditing:YES animated:YES];
        isEditing = YES;
    } else {
        mEditButtonIB.title = @"編輯";
        [self.mTableViewIB setEditing:NO animated:YES];
        isEditing = NO;
    }
}


@end
