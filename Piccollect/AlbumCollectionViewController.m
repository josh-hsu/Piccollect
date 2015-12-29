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
@synthesize mCollectionView, mNoPhotoLabel;
@synthesize mLoadingDialog;

#define LSTR(arg) NSLocalizedString(arg, nil)

static NSString * const reuseIdentifier = @"Cell";
static CGSize mCellSize;
static int mCellCountInARow = 4;
static int mCellWidthHardCoded = 92;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [mAlbumListService photoCount:mAlbum]; i++)
    {
        [viewArray addObject:[NSNull null]];
    }
    self.mImageViewArray = viewArray;
    
    // Do any additional setup after loading the view.
    self.title = mAlbum.mAlbumName;
    
    // If no photo to show, tell user to add some
    CGRect totalRect = mCollectionView.frame;
    CGFloat y = (totalRect.size.height - 140.0)/2;
    mNoPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, mCollectionView.frame.size.width, 40)];
    mNoPhotoLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([mAlbumListService photoCount:mAlbum] == 0) {
        mNoPhotoLabel.text = LSTR(@"No Photo");
        mNoPhotoLabel.textColor = [UIColor grayColor];
        mNoPhotoLabel.font = [UIFont systemFontOfSize:25.0];
        [mCollectionView addSubview:mNoPhotoLabel];
    }

    mCellCountInARow = (int)(mCollectionView.frame.size.width / mCellWidthHardCoded);
    if (mCellCountInARow * mCellWidthHardCoded + mCellCountInARow > mCollectionView.frame.size.width) {
        mCellCountInARow -= 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    long photoCount = [mAlbumListService photoCount:mAlbum];
    NSLog(@"CollectionView: photo count = %ld", photoCount);
    return photoCount/mCellCountInARow + (photoCount%mCellCountInARow ? 1 : 0);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return mCellCountInARow;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumThumbCollectionCell" forIndexPath:indexPath];
    long pageIndex = indexPath.row + indexPath.section * mCellCountInARow;
    UIImageView *imageView;
    
    // Initial global variable for cell size
    mCellSize = cell.frame.size;
    
    // Only config the cell with photo available
    if (pageIndex < [mAlbumListService photoCount:mAlbum]) {
        
        // If we add new photos, we need add more objects in mImageViewArray
        if ([mAlbumListService photoCount:mAlbum] > [mImageViewArray count]) {
            [mImageViewArray addObject:[NSNull null]];
        }
        
        imageView = [self getImageViewAtIndex:pageIndex];
        if (imageView == nil) {
            NSLog(@"BUG: Cannot get image view for cell at index %ld", pageIndex);
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prototypeImage"]];
        }
        
        [cell.contentView addSubview:imageView];
    } else {
        // In this case, the subview of this cell might be dirty
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.height, cell.frame.size.width)];
        imageView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

- (UIImageView *) getImageViewAtIndex: (long) pageIndex {
    // replace the placeholder if necessary
    UIImageView *imageView = [mImageViewArray objectAtIndex:pageIndex];

    if ((NSNull *)imageView == [NSNull null]) {
        NSString *subimagePath = [[mAlbumListService photosThumbInAlbum:mAlbum] objectAtIndex:pageIndex];
        NSString *imagePath = [mAlbumListService.mDocumentRootPath stringByAppendingPathComponent:subimagePath];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        // Check if thumbimage is avaiable
        if (image == nil) {
            subimagePath = [[mAlbumListService photosInAlbum:mAlbum] objectAtIndex:pageIndex];
            imagePath = [mAlbumListService.mDocumentRootPath stringByAppendingPathComponent:subimagePath];
            image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        }
        
        // Check if original image is avaiable
        if (image == nil) {
            NSLog(@"BUG: no photo available");
        }
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mCellSize.height, mCellSize.width)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Add tap recognizer
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(thumbnailTapGestureRecognized:)];
        tapGesture1.numberOfTapsRequired = 1;
        //[tapGesture1 setDelegate:self];
        [imageView addGestureRecognizer:tapGesture1];
        
        // Replace back
        [mImageViewArray replaceObjectAtIndex:pageIndex withObject:imageView];
    }
    
    return imageView;
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"CollcetionView: Transition to size %f * %f", size.width, size.height);
    mCellCountInARow = (int)(size.width / mCellSize.width);
    if (mCellCountInARow * mCellSize.width + mCellCountInARow > size.width) {
        mCellCountInARow -= 1;
    }
        
    [mCollectionView reloadData];
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
    static BOOL isEditing = NO;
    
    if (!isEditing) {
        //mEditButtonIB.title = LSTR(@"Finish");
        self.editing = YES;
        isEditing = YES;
    } else {
        //mEditButtonIB.title = LSTR(@"Edit");
        self.editing = NO;
        isEditing = NO;
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self loadingProgressDialog];
    
    // Save photos in background thread
    [self performSelectorInBackground:@selector(savePhotosWithInfo:) withObject:info];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePhotosWithInfo:(NSArray *)info {
    int ret = 0;
    long total = [info count];
    long current = 0;
    
    [self updateProgressDialog:current ofTotal:total];
    
    for (NSDictionary *dict in info) {
        current++;
        
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image = [dict objectForKey:UIImagePickerControllerOriginalImage];
                UIImage* thumb;

                // Get thumbnail
                thumb = [self makeThumbWithImage:image];
                
                ret = [mAlbumListService addPhotoWithImage:image andThumb:thumb toAlbum:mAlbum];
                
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
                ret = [mAlbumListService addPhotoWithImage:image andThumb:nil toAlbum:mAlbum];
                
                if (ret) {
                    NSLog(@"Save image to album failed, return %d", ret);
                }
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
        
        //update progress
        [self updateProgressDialog:current ofTotal:total];
    }
    
    [self didEndProgress];
}

- (UIImage *)makeThumbWithImage: (UIImage *)image {
    CGSize newSize = CGSizeMake(95, 95);
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MAX ( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = 0.0f;
    scaledImageRect.origin.y = 0.0f;
    
    UIGraphicsBeginImageContextWithOptions( scaledImageRect.size, NO, 0 );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

- (void) loadingProgressDialog {
    mLoadingDialog = [[UIAlertView alloc] initWithTitle: LSTR(@"Saving photos") message: @"" delegate:self cancelButtonTitle: nil otherButtonTitles: nil];
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(125, 50, 30, 30)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [mLoadingDialog setValue:progress forKey:@"accessoryView"];
    [progress startAnimating];
    [mLoadingDialog show];
}

- (void) updateProgressDialog: (long) current ofTotal: (long) total {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Code here to which needs to update the UI in the UI thread goes here
        NSString *totalProgress = [NSString stringWithFormat:@"%ld/%ld", current, total];
        [mLoadingDialog setMessage:totalProgress];
    });
}

- (void) didEndProgress {
    if ([NSThread isMainThread])
    {
        // Done with saving, refresh it
        mNoPhotoLabel.text = @"";
        [self.mCollectionView reloadData];
        
        // Dismiss loading progress dialog
        [mLoadingDialog setTitle:LSTR(@"Finished")];
        [mLoadingDialog dismissWithClickedButtonIndex:0 animated:YES];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            // Done with saving, refresh it
            mNoPhotoLabel.text = @"";
            [self.mCollectionView reloadData];
            
            // Dismiss loading progress dialog
            [mLoadingDialog setTitle:LSTR(@"Finished")];
            [mLoadingDialog dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
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
    return [self getImageViewAtIndex:index];
}

- (CGSize)galleryTransition:(RMGalleryTransition*)transition estimatedSizeForIndex:(NSUInteger)index
{
    // If the transition image is different than the one displayed in the gallery we need to provide its size
    UIImageView *imageView = [mImageViewArray objectAtIndex:index];
    const CGSize thumbnailSize = imageView.image.size;
    
    // In this example the final images are about 25 times bigger than the thumbnail
    const CGSize estimatedSize = CGSizeMake(thumbnailSize.width * 25, thumbnailSize.height * 25);
    return estimatedSize;
}

#pragma mark - Gesture Recongnizer

- (void)thumbnailTapGestureRecognized:(id)sender
{
    // Try to find which cell has been clicked
    UIImageView* iv = (UIImageView*)[sender view];
    UIView* cellView = iv;
    // Loop to find view
    while(cellView && ![cellView isKindOfClass:[UICollectionViewCell class]])
        cellView = cellView.superview; // go up until you find a cell
    
    // Then get its indexPath
    UICollectionViewCell* cell = (UICollectionViewCell*)cellView;
    NSIndexPath* indexPath = [self.mCollectionView indexPathForCell:cell];
    
    if (!self.editing) {
        [self showDetailGalleryView: indexPath];
    } else {
        NSLog(@"Editing check on %ld section and %ld row", indexPath.section, indexPath.row);
    }
}

- (void)showDetailGalleryView:(NSIndexPath *)indexPath {
    // Allocate next view controller
    AlbumPhotoCollectionViewController *galleryViewController = [AlbumPhotoCollectionViewController new];
    galleryViewController.mAlbum = mAlbum;
    galleryViewController.mPage = (int)(indexPath.row + mCellCountInARow * indexPath.section);
    galleryViewController.galleryIndex = (int)(indexPath.row + mCellCountInARow * indexPath.section);
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

- (void)dismissGallery:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
