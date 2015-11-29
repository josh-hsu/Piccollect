//
//  AlbumListService.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Album.h"

@import AssetsLibrary;

@interface AlbumListService : NSObject {
    // Local variable, it cannot be accessed outside this method
    NSMutableArray *mAlbum;
    
    // For debug
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
}

// Album list keyword
#define ALBUM_LIST_NAME     @"albums"
#define ALBUM_LIST_FILE_NAME     @"albums.plist"
#define ALBUM_LIST_FOLDER   @"Lists"
#define ALBUM_KEY_NAME      @"albumName"
#define ALBUM_KEY_KEY       @"albumKey"
#define ALBUM_KEY_CDATE     @"createDate"
#define ALBUM_KEY_ORDER     @"order"
#define ALBUM_PHOTO_LIST_NAME   @"albumImage"
#define ALBUM_PHOTO_LIST_FILE_NAME   @"albumImage.plist"

/*
 * Properties
 */
// Album photos list path and list body
@property (nonatomic, copy) NSString *mAlbumPhotoPath;
@property (nonatomic, retain) NSMutableDictionary *mAlbumPhotoList;
@property (nonatomic) BOOL mValidate; //YES, if album photo is fully initialized

// Album list path and list body
@property (nonatomic, copy) NSString *mAlbumListPath;
@property (nonatomic, retain) NSMutableDictionary *mAlbumList;
@property (nonatomic) int mCount;

// Photos document path
@property (nonatomic, retain) NSString *mDocumentRootPath;

/*
 * Intial functions
 */

// Initial phase, only run once when view controller presents
- (int) initAlbumList;
- (int) initAlbumPhotosList;
- (void) initAlbumsWithRefresh: (BOOL) needRefresh;

/* 
 * Utilities for interaction with users
 */
// Utilities
- (void) refresh;
- (NSString *) randomStringWithLength: (int) len;

// Photo functions
- (int) addPhotoInPath: (NSString *) path toAlbumWithKey: (NSString *) key;
- (int) removePhotoInPath: (NSString *) path toAlbumWithKey: (NSString *) key;
- (NSArray *) photosInAlbum: (Album *) album;
- (NSArray *) photosInAlbumWithKey: (NSString *) key;
- (UIImage *) topPhotoInAlbum: (Album *) album;

// Album functions
- (Album *) albumInListAtIndex: (NSInteger)idx;
- (void) reorderAlbumId: (int) idx;
- (int) createAlbumWithName: (NSString *) name;
- (int) editAlbumWithKey: (NSString *) key order: (NSInteger *) order;
- (int) removeAlbumWithKey: (NSString *) key deletePhotos: (BOOL) deletePhotos;

/*
 * Debug functions
 */
- (void) initPhotoFileDebug;
- (void) allPhotosCollected:(NSArray*)imgArray;

@end
