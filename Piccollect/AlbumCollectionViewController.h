//
//  AlbumCollectionViewController.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePicker/ELCImagePickerHeader.h"

@class Album, AlbumListService;
@interface AlbumCollectionViewController : UICollectionViewController <ELCImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *mCollectionView;

@property (nonatomic, retain) Album *mAlbum;
@property (nonatomic, retain) AlbumListService *mAlbumListService;

@end