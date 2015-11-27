//
//  AlbumListService.m
//  Piccollect
//
//  AlbumListService manages albums.plist and albumImage.plist
//  It should aware any change in list and reflect the change to every
//  Album objects.
//  That is, when an user delete, add or modify an entry in an Album,
//  AlbumListService should take over the next and leave everything
//  safe and sound.
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
@synthesize mAlbumPhotoList, mAlbumPhotoPath, mValidate;

- (id)init {
    int ret = -1;
    mValidate = NO;
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
    
    [self initAlbumPhotosList];
    [self initAlbums];

    return 0;
}

- (void) initAlbums {
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
        
        // Initial its album photos
        NSDictionary *eachAlbumPhoto = [mAlbumPhotoList objectForKey:key];
        
        // If the album's photo is not in list, fudge it.
        if (eachAlbumPhoto == nil) {
            eachAlbumPhoto = [[NSDictionary alloc] init];
            //TODO: insert new line in acutal list
        }
        thisAlbum.mAlbumPhotos = eachAlbumPhoto.copy;
        NSLog(@"DEBUG %@", [thisAlbum.mAlbumPhotos objectAtIndex:0]);
        
        [mAlbum addObject:thisAlbum];
    }
    
    mValidate = YES;
    
}

/*
 * This function initial albumImage.plist
 * Notice that if we didn't have key in the albumImage.plist, this is not
 * an error, it's just there is no photo in there and need to be set an empty one
 */
- (int)initAlbumPhotosList {
    NSError *errorDesc;
    NSPropertyListFormat format;
    
    // 初始化檔案路徑
    if (![[NSFileManager defaultManager] fileExistsAtPath:mAlbumPhotoPath]) {
        mAlbumPhotoPath = [[NSBundle mainBundle] pathForResource:ALBUM_PHOTO_LIST_NAME ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:mAlbumPhotoPath];
    mAlbumPhotoList = (NSMutableDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                                                                        options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];
    
    if (!mAlbumPhotoList) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
        return -1;
    }
    
    return 0;
}

/*
 * Album functions
 */
- (Album *) albumInListAtIndex: (NSInteger)idx {
    if (idx >= mCount)
        return nil;
    else
        return [mAlbum objectAtIndex:idx];
}

- (int) createAlbumWithName: (NSString *) name {
    return 0;
}

- (int) editAlbumWithName: (NSString *) name order: (NSInteger *) order {
    return 0;
}

- (int) removeAlbumWithKey: (NSString *) key deletePhotos: (BOOL) deletePhotos {
    return 0;
}

/*
 * Photos functions
 */
- (int) addPhotoInPath: (NSString *) path toAlbumWithKey: (NSString *) key {
    return 0;
}

- (int) removePhotoInPath: (NSString *) path toAlbumWithKey: (NSString *) key {
    return 0;
}

- (NSArray *) photosInAlbum: (Album *) album {
    return nil;
}

- (NSArray *) photosInAlbumWithKey: (NSString *) key {
    return nil;
}

- (NSString *) topPhotoInAlbum: (Album *) album {
    NSString* firstPhotoFileName;
    NSString* firstPhotoFilePath;
    
    if (!mValidate) {
        NSLog(@"BUG: try to get photo before it validate");
        return nil;
    }
    
    firstPhotoFileName = [album.mAlbumPhotos objectAtIndex:0];
    firstPhotoFilePath = [[NSString alloc] initWithFormat:@"%@/%@", mDocumentRootPath, firstPhotoFileName];
    NSLog(@"First photo path is: %@", firstPhotoFilePath);
    
    return firstPhotoFilePath;
}

/*
 * Debug functions
 */
- (void) initPhotoFileDebug {
    [self getAllPictures];
}

static int count=0;

- (void) getAllPictures {
    imageArray=[[NSArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                
                [library assetForURL:url
                         resultBlock:^(ALAsset *asset) {
                             [mutableArray addObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
                             
                             if ([mutableArray count]==6)
                             {
                                 imageArray=[[NSArray alloc] initWithArray:mutableArray];
                                 [self allPhotosCollected:imageArray];
                             }
                         }
                        failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); } ];
                
            }
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            count=[group numberOfAssets];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

- (void) allPhotosCollected: (NSArray*)imgArray {
    // We can deal with those images in user's photo library here
    for (Album *thisAlbum in mAlbum) {
        for (int i = 0; i < thisAlbum.mAlbumPhotos.count; i++) {
            NSString *savePath = [mDocumentRootPath stringByAppendingPathComponent:[thisAlbum.mAlbumPhotos objectAtIndex:i]];
            NSLog(@"Save to path %@", savePath);
            [UIImagePNGRepresentation([imgArray objectAtIndex:i]) writeToFile:savePath atomically:YES];
        }
        
    }
}

@end
