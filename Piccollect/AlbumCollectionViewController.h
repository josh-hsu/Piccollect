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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mEditButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mAddButton;

@property (nonatomic, retain) Album *mAlbum;
@property (nonatomic, retain) AlbumListService *mAlbumListService;
@property (nonatomic, retain) NSMutableArray *mImageViewArray;
@property (nonatomic) UILabel *mNoPhotoLabel;
@property (retain, atomic) UIAlertView *mLoadingDialog;
@property (retain, nonatomic) UIToolbar *mToolbar;

@end
