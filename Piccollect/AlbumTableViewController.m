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
#import "PasswordViewController.h"

@interface AlbumTableViewController () <StartViewControllerDelegate>

@end

@implementation AlbumTableViewController

@synthesize mAlbumList, mSettingsService;
@synthesize mTableViewIB, mEditButtonIB;

#define LSTR(arg) NSLocalizedString(arg, nil)

static BOOL isAuthorized = NO;

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
    //[mAlbumList initPhotoFileDebug]; /* Setting default photo from library automatically */

    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    mSettingsService = [[SettingsService alloc] init];
    if (!mSettingsService) {
		NSLog(@"FATAL: Setting service can not be initialized");
		abort();
    }
    
    if (![[mSettingsService getValueOfPrimaryKey: STOKEN_PASSWORD_REQ] boolValue]) {
        isAuthorized = YES;
    }

    if (!isAuthorized)
        [self performSegueWithIdentifier:@"showPasswordViewSegue" sender:nil];

    // Because the selected row will not reset after user hit back button and return here
    [mTableViewIB deselectRowAtIndexPath:[mTableViewIB indexPathForSelectedRow] animated:YES];
    [self.mTableViewIB reloadData];
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
    if (isAuthorized) {
        Album *thisAlbum = [mAlbumList albumInListAtIndex:indexPath.row];
        [titleLabel setText:thisAlbum.mAlbumName];
        [subtitleLabel setText:[NSString stringWithFormat:@"%ld", [thisAlbum.mAlbumPhotos count]]];
        topImageView.image = [mAlbumList topPhotoInAlbum:thisAlbum];
    } else {
        [titleLabel setText:LSTR(@"Wait for authentication")];
        [subtitleLabel setText:@""];
        topImageView.image = [UIImage imageNamed:@"prototypeImage"];
    }
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
        [self confirmRemoveOfAlbumInTableview:tableView inIndexPaths:@[indexPath]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Editing album name in editing mode
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView.isEditing)
        [self confirmEditAlbumInTableview:tableView inIndexPaths:@[indexPath]];
    else
        [self performSegueWithIdentifier:@"showAlbumThumbSegue" sender:nil];
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
    return LSTR(@"Delete");
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlbumThumbSegue"]) {
        AlbumCollectionViewController *collectionViewController = [segue destinationViewController];
        collectionViewController.mAlbum = [mAlbumList albumInListAtIndex:[mTableViewIB indexPathForSelectedRow].row];
        collectionViewController.mAlbumListService = mAlbumList;
    } else if ([[segue identifier] isEqualToString:@"showPasswordViewSegue"]) {
        PasswordViewController *addController = (PasswordViewController *)[segue destinationViewController];
        addController.delegate = self;
    }
}

#pragma mark - IBActions

// Add album
- (IBAction)addNewAlbum:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:LSTR(@"New Album")
                                  message:LSTR(@"Please input title")
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:LSTR(@"Cancel") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:LSTR(@"Finish") style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *userInput = [alert.textFields objectAtIndex:0].text;
                                                   if (![userInput isEqualToString:@""]) {
                                                       NSLog(@"Get user's input %@", userInput);
                                                       [self.mAlbumList createAlbumWithName:userInput];
                                                       [self.mTableViewIB reloadData];
                                                   }
                                               }];

    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = LSTR(@"Title");
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)editTableVIew:(id)sender {
    static BOOL isEditing = NO;
    
    if (!isEditing) {
        mEditButtonIB.title = LSTR(@"Finish");
        [self.mTableViewIB setEditing:YES animated:YES];
        isEditing = YES;
    } else {
        mEditButtonIB.title = LSTR(@"Edit");
        [self.mTableViewIB setEditing:NO animated:YES];
        isEditing = NO;
    }
}

- (IBAction)debugPrint:(id)sender {
    [mAlbumList debugPrint];
}

# pragma mark - Album other functions

- (void)confirmRemoveOfAlbumInTableview: (UITableView *) tableView inIndexPaths: (NSArray<NSIndexPath *> *) indexPaths {
    
    Album *thisAlbum = [mAlbumList albumInListAtIndex:[indexPaths objectAtIndex:0].row];
    if (thisAlbum == NULL) {
        NSLog(@"BUG: remove album with null pointer");
        return;
    }
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:LSTR(@"Remove Album")
                                  message:LSTR(@"Do you want to remove all photos altogether?\nIf you answer NO, those photos will save to default album.")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:LSTR(@"Cancel") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    UIAlertAction* allAlbum = [UIAlertAction actionWithTitle:LSTR(@"Remove all photos") style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          [mAlbumList removeAlbumWithKey:thisAlbum.mAlbumKey mergeBack:NO];
                                                          [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                                                          [tableView reloadData];
                                                      }];
    
    UIAlertAction* onlyAlbum = [UIAlertAction actionWithTitle:LSTR(@"Remove album only") style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [mAlbumList removeAlbumWithKey:thisAlbum.mAlbumKey mergeBack:YES];
                                                   [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                                                   [tableView reloadData];
                                               }];
    
    [alert addAction:cancel];
    [alert addAction:allAlbum];
    [alert addAction:onlyAlbum];

    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmEditAlbumInTableview: (UITableView *) tableView inIndexPaths: (NSArray<NSIndexPath *> *) indexPaths {
    
    Album *thisAlbum = [mAlbumList albumInListAtIndex:[indexPaths objectAtIndex:0].row];
    if (thisAlbum == NULL) {
        NSLog(@"BUG: remove album with null pointer");
        return;
    }
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:LSTR(@"Edit Album")
                                  message:LSTR(@"Please input title")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:LSTR(@"Cancel") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LSTR(@"Finish") style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   NSString *userInput = [alert.textFields objectAtIndex:0].text;
                                                   if (![userInput isEqualToString:@""]) {
                                                       NSLog(@"Get user's input %@", userInput);
                                                       //[self.mAlbumList createAlbumWithName:userInput];
                                                       [self.mAlbumList editAlbumNameWithKey:thisAlbum.mAlbumKey value:userInput];
                                                       [self.mTableViewIB reloadData];
                                                   }
                                               }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = thisAlbum.mAlbumName;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - PasswordViewControllerDelegate
//protocol : PasswordViewControllerDelegate implementation
- (void)addSightingViewControllerDidCancel:(PasswordViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSightingViewControllerDidFinish:(PasswordViewController *)controller{
    NSLog(@"password correct");
    isAuthorized = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
