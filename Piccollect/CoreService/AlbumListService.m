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

@synthesize mAlbumListPath;
@synthesize mAlbumList;
@synthesize mCount;
@synthesize mDocumentRootPath;

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
    
    // 初始化檔案路徑
    if (![[NSFileManager defaultManager] fileExistsAtPath:mAlbumListPath]) {
        mAlbumListPath = [[NSBundle mainBundle] pathForResource:ALBUM_LIST_NAME ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:mAlbumListPath];
    mAlbumList = (NSMutableDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                              options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];
    
    if (!mAlbumList) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
        return -1;
    }

    mCount = (int)[mAlbumList count];
    [self initAlbumByList];
    return 0;
}

- (void) initAlbumByList {
    if (!mAlbumList) {
        NSLog(@"There is no album list presented.");
    }
    
    if (!mAlbum) {
        mAlbum = [[NSMutableArray alloc] init];
    }
    
    for (unsigned i = 0; i < mCount; i++) {
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        
        NSString *name  = [eachPerson objectForKey:ALBUM_KEY_NAME];
        NSString *key   = [eachPerson objectForKey:ALBUM_KEY_KEY];
        NSDate   *cdate = [eachPerson objectForKey:ALBUM_KEY_CDATE];
        NSNumber *order = [eachPerson objectForKey:ALBUM_KEY_ORDER];
        
        Album *thisAlbum = [Album alloc];
        [thisAlbum initWithName:name key:key date:cdate order:order];
        [mAlbum addObject:thisAlbum];
    }
    
}

- (Album *) albumInListAtIndex: (NSInteger)idx {
    if (idx >= mCount)
        return nil;
    else
        return [mAlbum objectAtIndex:idx];
}

@end
