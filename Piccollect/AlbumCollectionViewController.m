//
//  AlbumCollectionViewController.m
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AlbumListService.h"
#import "Album.h"

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
    return [mAlbum.mAlbumPhotos count]/4 + ([mAlbum.mAlbumPhotos count]%4 ? 1 : 0);
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


@end
