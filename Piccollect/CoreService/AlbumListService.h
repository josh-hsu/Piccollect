//
//  AlbumListService.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Album;

@interface AlbumListService : NSObject {
    // Local variable, it cannot be accessed outside this method
    NSMutableArray *mAlbum;
}

// Album list keyword
#define ALBUM_LIST_NAME     @"albums"
#define ALBUM_LIST_FOLDER   @"Lists"
#define ALBUM_KEY_NAME      @"albumName"
#define ALBUM_KEY_KEY       @"albumKey"
#define ALBUM_KEY_CDATE     @"createDate"
#define ALBUM_KEY_ORDER     @"order"

// Album list path and list body
@property (nonatomic, copy) NSString *mAlbumListPath;
@property (nonatomic, retain) NSMutableDictionary *mAlbumList;
@property (nonatomic) int mCount;
// Photos document path
@property (nonatomic, retain) NSString *mDocumentRootPath;

- (int) initAlbumList;
- (void) initAlbumByList;
- (Album *) albumInListAtIndex: (NSInteger)idx;

@end
