//
//  AlbumListService.m
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AlbumListService.h"
#import "Album.h"

@implementation AlbumListService

@synthesize mAlbumPath;
@synthesize mCount;
@synthesize mMemberList;
@synthesize mRootDir;

- (id)init {
    int ret = -1;
    if (self = [super init]) {
        ret = [self initAlbumList];
        
        if (ret == 0)
            return self;
    }
    return nil;
}

- (int) initAlbumList {
    NSError *errorDesc;
    NSPropertyListFormat format;
    mMemberList = [[NSMutableDictionary alloc] init];
    
    // 初始化檔案路徑
    if (![[NSFileManager defaultManager] fileExistsAtPath:mAlbumPath]) {
        mAlbumPath = [[NSBundle mainBundle] pathForResource:ALBUM_LIST_NAME ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:mAlbumPath];
    mRootDir = (NSMutableDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                              options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];
    
    if (!mRootDir) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
        return -1;
    }
    
    mMemberList = mRootDir;
    mCount = (int)[mMemberList count];
    return 0;
}

- (Album *) objectInListAtIndex: (NSInteger)idx {
    NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)idx];
    NSDictionary *eachPerson = [mMemberList objectForKey:rootKey];
    
    NSString *name  = [eachPerson objectForKey:ALBUM_KEY_NAME];
    NSString *key   = [eachPerson objectForKey:ALBUM_KEY_KEY];
    NSDate   *cdate = [eachPerson objectForKey:ALBUM_KEY_CDATE];
    NSNumber *order = [eachPerson objectForKey:ALBUM_KEY_ORDER];
    
    Album *thisAlbum = [Album alloc];
    [thisAlbum initWithName:name key:key date:cdate order:order];
    
    return thisAlbum;
}

@end
