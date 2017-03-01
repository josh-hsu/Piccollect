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
@synthesize mCollectionView, mNoPhotoLabel, mAddButton, mEditButton;
@synthesize mLoadingDialog, mToolbar;

#define LSTR(arg) NSLocalizedString(arg, nil)

static NSString * const reuseIdentifier = @"Cell";
static CGSize mCellSize;
static int mCellCountInARow = 4;    // Default set to portrait orientation
static float mCellWidth = 92.0;     // Golden cell width for 4.7 inch screen
static int mThumbnailWidth = 95;    // Thumbnail width
static NSMutableDictionary  *mSelectedPhotos;
static int mOverlayViewTag = 100;
static Boolean isSelectingAlbum = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    [self renewImageViewArray];
    
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
    
    // Hide edit related buttons
    [mAddButton setEnabled:NO];
    [mAddButton setTintColor: [UIColor clearColor]];
    mEditButton.title = LSTR(@"Edit");
    
    // Configure Toolbar
    mToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    mToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *moveButtonItem = [[UIBarButtonItem alloc]initWithTitle:LSTR(@"Move To") style:UIBarButtonItemStylePlain  target:self action:@selector(movePhotos)];
    UIBarButtonItem *removeButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removePhotos)];
    UIBarButtonItem *composeButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(menuPhotos)];

    mToolbar.items = @[fixedSpace, composeButtonItem, fixedSpace, moveButtonItem, fixedSpace, removeButtonItem, fixedSpace];
    [self.view addSubview:mToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self recalculateCellSize:mCollectionView.frame.size];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!isSelectingAlbum) {
        mSelectedPhotos = nil;
        [self setEditMode:NO];
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
    // check if range is out of bound
    if (pageIndex >= [mAlbumListService photoCount:mAlbum]) {
        NSLog(@"Request index is not available");
        return nil;
    }
    
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

        // Add overlay view
        UIImageView *overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mCellSize.height, mCellSize.width)];
        UIImage *overlayImage = [UIImage imageNamed:@"Overlay.png"];
        overlayView.image = overlayImage;
        overlayView.contentMode = UIViewContentModeScaleAspectFill;
        overlayView.hidden = YES;
        overlayView.tag = mOverlayViewTag;
        [imageView addSubview: overlayView];

        // Replace back
        [mImageViewArray replaceObjectAtIndex:pageIndex withObject:imageView];
    }
    
    return imageView;
}

- (void) renewImageViewArray {
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [mAlbumListService photoCount:mAlbum]; i++)
    {
        [viewArray addObject:[NSNull null]];
    }
    self.mImageViewArray = viewArray;
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
 * This handles when size of screen is changed by orientation or reachability
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"CollcetionView: Transition to size %f * %f", size.width, size.height);
    [self recalculateCellSize:size];
    [mCollectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self recalculateCellSize:collectionView.frame.size];
}

/*
 * This handles different screen sizes to have different cell sizes
 * Now we support 4.7 and 5.5 inch screen size
 * We want 4 cells in a section for portrait orientation and 7 cells
 * in a section for landscape orientation
 * TODO: Fix 4 inch display portrait cell size mismatch
 */
- (CGSize)recalculateCellSize:(CGSize)viewSize {
    float width = viewSize.width;
    float height = viewSize.height;
    float cell_width;
    
    if (height > width) {
        mCellCountInARow = 4;
    } else {
        mCellCountInARow = 7;
    }
    
    cell_width = (long)(width / mCellCountInARow) - 1;
    mCellWidth = cell_width;
    mCellSize = CGSizeMake(mCellWidth, mCellWidth);
    
    return mCellSize;
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
    if (!self.editing) {
        [self setEditMode:YES];
    } else {
        [self setEditMode:NO];
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



#pragma mark - Selection holder

/*
 * Selection holder uses a NSMutableDictionary to store which item has been selected
 * key  (NSString): indexPath string
 * item (NSNumber): pageIndex in long type
 */

// When user pressed edit button, we should initialize a selection process
- (void)selectItemStarted {
    mSelectedPhotos = [[NSMutableDictionary alloc] init];
}

- (BOOL)selectItemStatusForKey:(NSString *)key {
    NSString *value = [mSelectedPhotos objectForKey:key];

    if (!value) {
        return NO;
    }

    return YES;
}

// Handle every selection
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    long pageIndex = (long)(indexPath.row + indexPath.section * mCellCountInARow);
    NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", pageIndex];
    NSNumber *value = [[NSNumber alloc] initWithLong:pageIndex];
    UIImageView *overlayView = [[self getImageViewAtIndex:pageIndex] viewWithTag:mOverlayViewTag];

    // Check if item has been selected
    if (![self selectItemStatusForKey:rootKey]) {
        [mSelectedPhotos setObject:value forKey:rootKey];
        overlayView.hidden = NO;
    } else {
        [mSelectedPhotos removeObjectForKey:rootKey];
        overlayView.hidden = YES;
    }
    
    // Update title
    if ([mSelectedPhotos count] > 0) {
        self.title = [NSString stringWithFormat:LSTR(@"%d photo(s) selected") , [mSelectedPhotos count]];
    } else {
        self.title = LSTR(@"Please select photos");
    }
}

// When user pressed finish button with or without action, the selection should be removed
- (void)selectItemEnded {
    for (UIImageView *imageView in mImageViewArray) {
        if ((NSNull *)imageView != [NSNull null]) {
            UIImageView *overlayView = [imageView viewWithTag:mOverlayViewTag];
            overlayView.hidden = YES;
        }
    }
    
    mSelectedPhotos = nil;
}

#pragma mark - Toolbar actions

- (void)setEditMode:(BOOL)edit {
    if (edit) {
        self.title = LSTR(@"Please select photos");
        self.editing = YES;
        mEditButton.title = LSTR(@"Finish");
        [mAddButton setEnabled:YES];
        [mAddButton setTintColor:nil];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.tabBarController.tabBar.hidden = YES;
        [self selectItemStarted];
    } else {
        self.title = mAlbum.mAlbumName;
        self.editing = NO;
        mEditButton.title = LSTR(@"Edit");
        [mAddButton setEnabled:NO];
        [mAddButton setTintColor: [UIColor clearColor]];
        self.tabBarController.tabBar.hidden = NO;
        [self selectItemEnded];
    }
}

- (void)removePhotos {
    [mAlbumListService editPhotosIn:mSelectedPhotos ofAlbum:mAlbum toAlbum: NULL forType:ALS_PHOTO_REMOVE];
    // replace all imageview in array with null, so we can regenerate correct image when collectinView redraw
    [self renewImageViewArray];
    [mCollectionView reloadData];
    [self setEditMode:NO];
}

- (void)movePhotos {
    isSelectingAlbum = true;
    [self performSegueWithIdentifier:@"showAlbumSelect" sender:NULL];
}

- (void)menuPhotos {
    NSLog(@"Perform menu photos");
    //[self performSegueWithIdentifier:@"showAlbumSelect" sender:NULL];
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
                thumb = [Album makeThumbWithImage:image size:mThumbnailWidth];
                
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
        [self setEditMode:NO];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            // Done with saving, refresh it
            mNoPhotoLabel.text = @"";
            [self.mCollectionView reloadData];
            
            // Dismiss loading progress dialog
            [mLoadingDialog setTitle:LSTR(@"Finished")];
            [mLoadingDialog dismissWithClickedButtonIndex:0 animated:YES];
            [self setEditMode:NO];
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
        [self selectItemAtIndexPath: indexPath];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlbumSelect"]) {
        AlbumSelectViewController *addController = (AlbumSelectViewController *)[segue destinationViewController];
        addController.delegate = self;
    }
}

- (void)dismissGallery:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AlbumSelectControllerDelegate
//protocol : AlbumSelectControllerDelegate implementation
- (void)albumSelectDidCancel:(AlbumSelectViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
    isSelectingAlbum = false;
}

- (void)albumSelectDidFinish:(AlbumSelectViewController *)controller albumKey: (Album *) album {
    NSLog(@"Receive album select key %@", album.mAlbumKey);
    [self dismissViewControllerAnimated:YES completion:nil];
    [mAlbumListService editPhotosIn:mSelectedPhotos ofAlbum:mAlbum toAlbum:album forType:ALS_PHOTO_MOVE];
    [mCollectionView reloadData];
    [self setEditMode:NO];
    isSelectingAlbum = false;
    mSelectedPhotos = nil;
}

@end
