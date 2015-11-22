//
//  AlbumListService.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Album;

@interface AlbumListService : NSObject

#define ALBUM_LIST_NAME     @"albums"
#define ALBUM_LIST_FOLDER   @"Lists"
#define ALBUM_KEY_NAME      @"albumName"
#define ALBUM_KEY_KEY       @"albumKey"
#define ALBUM_KEY_CDATE     @"createDate"
#define ALBUM_KEY_ORDER     @"order"

@property (nonatomic, copy) NSString *mAlbumPath;
@property (nonatomic) int mCount;
@property (nonatomic, copy) NSMutableDictionary *mRootDir;
@property (nonatomic, retain) NSMutableDictionary *mMemberList;

- (int) initAlbumList;
- (Album *) objectInListAtIndex: (NSInteger)idx;

@end
