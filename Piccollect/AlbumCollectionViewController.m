//
//  AlbumCollectionViewController.m
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015 Mu Mu Corp. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AlbumPhotoCollectionViewController.h"
#import "AlbumListService.h"
#import "ELCImagePicker/ELCImagePickerHeader.h"
#import "RMGalleryTransition.h"

@interface AlbumCollectionViewController ()<UIViewControllerTransitioningDelegate, RMGalleryTransitionDelegate>

@end

@implementation AlbumCollectionViewController

@synthesize mAlbum, mAlbumListService, mImageViewArray;
@synthesize mCollectionView, currentImageView, mNoPhotoLabel;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [mAlbum.mAlbumPhotos count]; i++)
    {
        [viewArray addObject:[NSNull null]];
    }
    self.mImageViewArray = viewArray;
    
    // Do any additional setup after loading the view.
    self.title = mAlbum.mAlbumName;
    
    // If no photo to show, tell user to add some
    CGRect totalRect = mCollectionView.frame;
    CGFloat y = (totalRect.size.height - 140.0)/2;
    mNoPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, y, 300, 40)];
    
    if ([mAlbum.mAlbumPhotos count] == 0) {
        mNoPhotoLabel.text = @"沒有照片或影片";
        mNoPhotoLabel.textColor = [UIColor grayColor];
        mNoPhotoLabel.font = [UIFont systemFontOfSize:25.0];
        [mCollectionView addSubview:mNoPhotoLabel];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    long photoCount = [mAlbum.mAlbumPhotos count];
    NSLog(@"CollectionView: photo count = %ld", photoCount);
    return photoCount/4 + (photoCount%4 ? 1 : 0);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumThumbCollectionCell" forIndexPath:indexPath];
    long pageIndex = indexPath.row + indexPath.section * 4;
    
    // Only config the cell with photo available
    if (pageIndex < [mAlbum.mAlbumPhotos count]) {
        
        // replace the placeholder if necessary
        UIImageView *imageView = [mImageViewArray objectAtIndex:pageIndex];
        if ((NSNull *)imageView == [NSNull null])
        {
            NSString *subimagePath = [mAlbum.mAlbumPhotos objectAtIndex:(indexPath.row + indexPath.section * 4)];
            NSString *imagePath = [mAlbumListService.mDocumentRootPath stringByAppendingPathComponent:subimagePath];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.height, cell.frame.size.width)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            // Add tap recognizer
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(thumbnailTapGestureRecognized:)];
            tapGesture1.numberOfTapsRequired = 1;
            //[tapGesture1 setDelegate:self];
            [imageView addGestureRecognizer:tapGesture1];
        }
        
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


#pragma mark - <UICollectionViewDelegate>

- (UIEdgeInsets)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout *) collectionViewLayout
        insetForSectionAtIndex:(NSInteger) section {
    
    return UIEdgeInsetsMake(1, 1, 1, 1); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 1.0;
}

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

#pragma mark - IBAction


- (IBAction)editPhotoLibrary:(id)sender {
    
}


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

#pragma mark - ELCImagePickerControllerDelegate Methods


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
    mNoPhotoLabel.text = @"";
    [self.mCollectionView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    RMGalleryTransition *transition = [RMGalleryTransition new];
    transition.delegate = self;
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    RMGalleryTransition *transition = [RMGalleryTransition new];
    transition.delegate = self;
    return transition;
}

#pragma mark - RMGalleryTransitionDelegate


- (UIImageView*)galleryTransition:(RMGalleryTransition*)transition transitionImageViewForIndex:(NSUInteger)index
{
    return self.currentImageView;
}

- (CGSize)galleryTransition:(RMGalleryTransition*)transition estimatedSizeForIndex:(NSUInteger)index
{ // If the transition image is different than the one displayed in the gallery we need to provide its size
    UIImageView *imageView = self.currentImageView;
    const CGSize thumbnailSize = imageView.image.size;
    
    // In this example the final images are about 25 times bigger than the thumbnail
    const CGSize estimatedSize = CGSizeMake(thumbnailSize.width * 25, thumbnailSize.height * 25);
    return estimatedSize;
}


#pragma mark - Gesture Recongnizer


- (void)thumbnailTapGestureRecognized:(id) sender
{
    // Try to find which cell has been clicked
    UIImageView* iv = (UIImageView*)[sender view];
    currentImageView = iv;
    UIView* cellView = iv;
    // Loop to find view
    while(cellView && ![cellView isKindOfClass:[UICollectionViewCell class]])
        cellView = cellView.superview; // go up until you find a cell
    
    // Then get its indexPath
    UICollectionViewCell* cell = (UICollectionViewCell*)cellView;
    NSIndexPath* indexPath = [self.mCollectionView indexPathForCell:cell];
    
    // Allocate next view controller
    AlbumPhotoCollectionViewController *galleryViewController = [AlbumPhotoCollectionViewController new];
    galleryViewController.mAlbum = mAlbum;
    galleryViewController.mPage = (int)(indexPath.row + 4 * indexPath.section);
    galleryViewController.galleryIndex = (int)(indexPath.row + 4 * indexPath.section);
    galleryViewController.mAlbumListService = mAlbumListService;
    
    // The gallery is designed to be presented in a navigation controller or on its own.
    UIViewController *viewControllerToPresent;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    navigationController.toolbarHidden = NO;
    
    // When using a navigation controller the tap gesture toggles the navigation bar and toolbar. A way to dismiss the gallery must be provided.
    galleryViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissGallery:)];
    
    viewControllerToPresent = navigationController;
    
    // Set the transitioning delegate. This is only necessary if you want to use RMGalleryTransition.
    viewControllerToPresent.transitioningDelegate = self;
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:viewControllerToPresent animated:YES completion:nil];
}

- (void)dismissGallery:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
