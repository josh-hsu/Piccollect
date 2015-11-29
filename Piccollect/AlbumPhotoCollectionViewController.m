//
//  AlbumPhotoCollectionViewController.m
//  Piccollect
//
//  Created by Josh on 2015/11/29.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AlbumPhotoCollectionViewController.h"
#import "AlbumListService.h"

@interface AlbumPhotoCollectionViewController ()

@end

@implementation AlbumPhotoCollectionViewController

@synthesize mCollectionView;
@synthesize mAlbum, mAlbumListService, mPage;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCollectionView];
    [self scrollToPage:mPage];
    self.title = [[NSString alloc] initWithFormat:@"總共 %ld 張相片", [mAlbum.mAlbumPhotos count]];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)initCollectionView {
    [self.mCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:CGSizeMake(375.0, 554.0)];
    [self.mCollectionView setPagingEnabled:YES];
    [self.mCollectionView setCollectionViewLayout:flowLayout];
    
}

- (void)scrollToPage: (int) page {
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = page * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mAlbum.mAlbumPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailPhotoCell" forIndexPath:indexPath];
    
    // Configure the cell
    // Only config the cell with photo available
    if ((indexPath.row) < [mAlbum.mAlbumPhotos count]) {
        NSString *subimagePath = [mAlbum.mAlbumPhotos objectAtIndex:(indexPath.row)];
        NSString *imagePath = [mAlbumListService.mDocumentRootPath stringByAppendingPathComponent:subimagePath];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
    }

    //[cell.contentView removeFromSuperview];
    
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

@end
