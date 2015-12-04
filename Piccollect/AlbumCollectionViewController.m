//
//  AlbumCollectionViewController.m
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AlbumPhotoCollectionViewController.h"
#import "AlbumListService.h"
#import "ELCImagePicker/ELCImagePickerHeader.h"

@interface AlbumCollectionViewController ()

@end

@implementation AlbumCollectionViewController

@synthesize mAlbum, mAlbumListService;
@synthesize mCollectionView;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.title = mAlbum.mAlbumName;
    
    // If no photo to show, tell user to add some
    if ([mAlbum.mAlbumPhotos count] == 0) {
        CGRect totalRect = mCollectionView.frame;
        CGFloat y = (totalRect.size.height - 140.0)/2;
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, y, 300, 40)];
        aLabel.text = @"沒有照片或影片";
        aLabel.textColor = [UIColor grayColor];
        aLabel.font = [UIFont systemFontOfSize:25.0];
        [mCollectionView addSubview:aLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *hitPath = [[mCollectionView indexPathsForSelectedItems] objectAtIndex:0];
    AlbumPhotoCollectionViewController *collectionViewController = [segue destinationViewController];
    collectionViewController.mAlbum = mAlbum;
    collectionViewController.mPage = (int)(hitPath.row + 4 * hitPath.section);
    collectionViewController.mAlbumListService = mAlbumListService;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    long photoCount = [mAlbum.mAlbumPhotos count];
    return photoCount/4 + (photoCount%4 ? 1 : 0);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumThumbCollectionCell" forIndexPath:indexPath];
    
    // Only config the cell with photo available
    if ((indexPath.row + indexPath.section * 4) < [mAlbum.mAlbumPhotos count]) {
        NSString *subimagePath = [mAlbum.mAlbumPhotos objectAtIndex:(indexPath.row + indexPath.section * 4)];
        NSString *imagePath = [mAlbumListService.mDocumentRootPath stringByAppendingPathComponent:subimagePath];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.height, cell.frame.size.width)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    } else {
        // In this case, the subview of this cell might be dirty
        // TODO: this is a workaround
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.height, cell.frame.size.width)];
        imageView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (UIEdgeInsets)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout *) collectionViewLayout
    insetForSectionAtIndex:(NSInteger) section {
    
    return UIEdgeInsetsMake(1, 1, 1, 1); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout *) collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 1.0;
}

#pragma mark - IBAction

- (IBAction)addPhotoInLibrary:(id)sender {
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    //elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
    
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

#pragma mark ELCImagePickerControllerDelegate Methods

/*
 * display image picker controller for user to select
 * TODO: Note that user might select too many images that will make our saving process hanging
 *       Maybe we should consider saving it in a thread style
 */
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    int ret = 0;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image = [dict objectForKey:UIImagePickerControllerOriginalImage];
                
                // Save it to album
                NSLog(@"CollectionView: Add a photo");
                ret = [mAlbumListService addPhotoWithImage:image toAlbum:mAlbum];
                
                if (ret) {
                    NSLog(@"Save image to album failed, return %d", ret);
                }
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image = [dict objectForKey:UIImagePickerControllerOriginalImage];
                
                // Save it to album
                ret = [mAlbumListService addPhotoWithImage:image toAlbum:mAlbum];
                
                if (ret) {
                    NSLog(@"Save image to album failed, return %d", ret);
                }
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    // Done with saving, refresh it
    [self.mCollectionView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
