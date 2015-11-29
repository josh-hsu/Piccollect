//
//  AlbumPhotoCollectionViewController.h
//  Piccollect
//
//  Created by Josh on 2015/11/29.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album, AlbumListService;
@interface AlbumPhotoCollectionViewController : UICollectionViewController

@property (strong, nonatomic) IBOutlet UICollectionView *mCollectionView;

@property (nonatomic, retain) Album *mAlbum;
@property (nonatomic, retain) AlbumListService *mAlbumListService;
@property (nonatomic) int mPage;

@end
