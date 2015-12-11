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
//  Copyright © 2015 Mu Mu Corp. All rights reserved.
//

// TODO: Need code refinement

#import "AlbumListService.h"
#import "Album.h"

@implementation AlbumListService

@synthesize mAlbumListPath;
@synthesize mAlbumList;
@synthesize mCount;
@synthesize mDocumentRootPath;
@synthesize mAlbumPhotoList, mAlbumPhotoPath, mValidate, mNextAlbumSerial;
#define LOCAL_DEBUG           YES   //YES, turn on Log
#define NUM_LIST_ATTRIBUTE    1     //number of attributes in albums.plist except serial such as "next"
#define LENGTH_OF_SERIAL      8     //request serial code length for album

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

/*
 * initAlbumList
 *
 * This is the main entry of AlbumListService
 * We should deal with every little details to prevent aborting
 */
- (int) initAlbumList {
    NSError *errorDesc;
    NSPropertyListFormat format;
    
    // Initial document path for storing photos
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if(LOCAL_DEBUG) NSLog(@"Document path: %@", documentsDirectory);
    mDocumentRootPath = documentsDirectory;
    
    // Find the new albums.plist inside the document folder
    mAlbumListPath = [mDocumentRootPath stringByAppendingPathComponent:ALBUM_LIST_FILE_NAME];
    
    // If we cannot find list in document folder, copy default list to document
    //if (true) { /* For debug, put golden list back */
    if (![[NSFileManager defaultManager] fileExistsAtPath:mAlbumListPath]) {
        if (LOCAL_DEBUG) NSLog(@"Load default");
        NSString *localListPath = [[NSBundle mainBundle] pathForResource:ALBUM_LIST_NAME ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:localListPath toPath:mAlbumListPath error:&errorDesc];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:mAlbumListPath];
    mAlbumList = (NSMutableDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                              options:NSPropertyListMutableContainersAndLeaves format:&format error:&errorDesc];
    
    if (!mAlbumList) {
        NSLog(@"Error reading plist: %@, format: %lu", errorDesc, (unsigned long)format);
        return -1;
    }

    mCount = (int)[mAlbumList count] - NUM_LIST_ATTRIBUTE; //Because we have a "next" field on the top
    NSLog(@"mCount = %d", mCount);
    
    [self initAlbumPhotosList];
    [self initAlbumsWithRefresh:NO];

    return 0;
}


/*
 * This function initial albumImage.plist
 * Notice that if we didn't have key in the albumImage.plist, this is not
 * an error, it's just there is no photo in there and need to be set an empty one
 */
- (int)initAlbumPhotosList {
    NSError *errorDesc;
    NSPropertyListFormat format;
    
    // Find the new albumImage.plist inside the document folder
    mAlbumPhotoPath = [mDocumentRootPath stringByAppendingPathComponent:ALBUM_PHOTO_LIST_FILE_NAME];
    
    // If we cannot find list in document folder, copy default list to document
    //if (true) { /* For debug, copy back golden list */
    if (![[NSFileManager defaultManager] fileExistsAtPath:mAlbumPhotoPath]) {
        NSString *localListPath = [[NSBundle mainBundle] pathForResource:ALBUM_PHOTO_LIST_NAME ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:localListPath toPath:mAlbumPhotoPath error:&errorDesc];
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

- (void) initAlbumsWithRefresh: (BOOL) needRefresh {
    if (!mAlbumList) {
        NSLog(@"BUG: There is no album list presented.");
    }
    
    if (!mAlbums || needRefresh) {
        mAlbums = [[NSMutableArray alloc] init];
    }
    
    NSNumber *nextSerial  = [mAlbumList objectForKey:ALBUM_KEY_NEXT];
    self.mNextAlbumSerial = [nextSerial intValue];
    
    for (unsigned i = 0; i < mCount; i++) {
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        
        NSString *name   = [eachPerson objectForKey:ALBUM_KEY_NAME];
        NSString *key    = [eachPerson objectForKey:ALBUM_KEY_KEY];
        NSDate   *cdate  = [eachPerson objectForKey:ALBUM_KEY_CDATE];
        NSNumber *order  = [eachPerson objectForKey:ALBUM_KEY_ORDER];
        NSString *incr   = [eachPerson objectForKey:ALBUM_KEY_INCR];
        NSNumber *serial = [eachPerson objectForKey:ALBUM_KEY_SERIAL];
        
        NSLog(@"init: this album %d with INCR %@", i, incr);
        
        Album *thisAlbum = [Album alloc];
        [thisAlbum initWithName:name key:key date:cdate order:order incr:incr serial:serial];
        
        // Initial its album photos
        NSMutableArray *eachAlbumPhoto = [mAlbumPhotoList objectForKey:key];
        
        // If the album's photo is not in list, fudge it.
        if (eachAlbumPhoto == nil) {
            eachAlbumPhoto = [[NSMutableArray alloc] init];
            [mAlbumPhotoList setObject:eachAlbumPhoto forKey:key];
        }
        
        // Fill the photos index
        thisAlbum.mAlbumPhotos = eachAlbumPhoto;
        NSLog(@"Initial album photo: %ld", [thisAlbum.mAlbumPhotos count]);
        
        [mAlbums addObject:thisAlbum];
    }
    
    mValidate = YES;
    
}

- (void) refresh {
    mCount = (int)[mAlbumList count] - NUM_LIST_ATTRIBUTE;
    
    [self initAlbumPhotosList];
    [self initAlbumsWithRefresh:YES];
}

# pragma mark - Album functions
/* ===================================
 * Album functions
 * ===================================
 */


/*
 * Get album in album list for specific index
 * this is called from a table view, so it's related to the order
 * of how it displayed on screen.
 * return nil if no album
 */
- (Album *) albumInListAtIndex: (NSInteger)idx {
    if (idx >= mCount)
        return nil;
    else
        return [mAlbums objectAtIndex:idx];
}

/*
 * Create an album with user-specific name
 * And yes, we accept duplicate name because we use identity key
 * to identify album.
 * the root serial should be strictly increasing with increment of 1
 * the content of album setting will not change after adding or removing
 * an album
 */
- (int) createAlbumWithName: (NSString *) name {
    // Adding to the album list
    NSNumber *root_serial = [[NSNumber alloc] initWithInt: mCount];
    NSString *rootName = [NSString stringWithFormat:@"%d", [root_serial intValue]];
    NSDate *today = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString *key = [self randomStringWithLength:LENGTH_OF_SERIAL];
    // Create data
    if(LOCAL_DEBUG) NSLog(@"LOG: create album with serial %d", mNextAlbumSerial);
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 name, ALBUM_KEY_NAME,
                                 key, ALBUM_KEY_KEY,
                                 today, ALBUM_KEY_CDATE,
                                 root_serial, ALBUM_KEY_ORDER,
                                 @"00000", ALBUM_KEY_INCR,
                                 [[NSNumber alloc] initWithInt:mNextAlbumSerial], ALBUM_KEY_SERIAL,
                                 nil];
    
    // Save list back to file
    [mAlbumList setObject:data forKey:rootName];
    [mAlbumList setObject:[[NSNumber alloc] initWithInt:mNextAlbumSerial + 1] forKey:ALBUM_KEY_NEXT];
    [mAlbumList writeToFile:mAlbumListPath atomically:YES];
    
    // Update runtime
    Album *thisAlbum = [Album alloc];
    [thisAlbum initWithName:name key:key date:today order:root_serial incr:@"00000" serial:[[NSNumber alloc] initWithInt:mNextAlbumSerial]];
    [mAlbums addObject:thisAlbum];
    mCount++;
    mNextAlbumSerial++;
    
    // Adding default photos attribute
    NSMutableArray *defaultPhotos = [[NSMutableArray alloc] init];
    [mAlbumPhotoList setObject:defaultPhotos forKey:key];
    [mAlbumPhotoList writeToFile:mAlbumPhotoPath atomically:YES];
    
    // Update runtime connectivity
    thisAlbum.mAlbumPhotos = defaultPhotos;
    
    return 0;
}

- (int) editAlbumWithKey: (NSString *) key order: (NSInteger *) order {
    return 0;
}

/*
 * We need to update Increase (for the next photo file name)
 * both on file and on runtime
 */
- (int) increaseAlbum: (Album *) album {
    NSString *rootName = [NSString stringWithFormat:@"%d", [self albumIndexWithKey:album.mAlbumKey]];
    int intincr = [album.mIncrease intValue];
    
    intincr += 1;
    if (intincr > 99999) {
        NSLog(@"Too many photos! cannot add more.");
        return -9;
    }
    
    // Deal with trailing
    int m1 = (int) intincr / 10000;
    intincr = intincr % 10000;
    int m2 = (int) intincr / 1000;
    intincr = intincr % 1000;
    int m3 = (int) intincr / 100;
    intincr = intincr % 100;
    int m4= (int) intincr / 10;
    intincr = intincr % 10;
    int m5= (int) intincr;
    
    // Save it to file
    NSString *newIncr = [NSString stringWithFormat:@"%d%d%d%d%d",m1,m2,m3,m4,m5];
    NSLog(@"increaseAlbum: new increase is %@", newIncr);
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 album.mAlbumName, ALBUM_KEY_NAME,
                                 album.mAlbumKey, ALBUM_KEY_KEY,
                                 album.mCreateDate, ALBUM_KEY_CDATE,
                                 newIncr, ALBUM_KEY_INCR,
                                 album.mOrder, ALBUM_KEY_ORDER,
                                 album.mSerial, ALBUM_KEY_SERIAL,
                                 nil];
    [mAlbumList setObject:data forKey:rootName];
    [mAlbumList writeToFile:mAlbumListPath atomically:YES];
    
    // Change on runtime
    album.mIncrease = newIncr;
    
    return 0;
}

/*
 * When remove an album, we should reorder the list
 * In this moment, the mCount is still the value before album deleted
 *
 * idx => 5   mCount => 10 [0, 1, 2, ..., 9]
 * we should move 6, 7, 8, 9 to 5, 6, 7, 8
 */
- (void) reorderAlbumId: (int) idx {
    int index = idx;
    for (unsigned i = index + 1; i < mCount; i++) {
        NSLog(@"i = %d, mCount = %d", i, mCount);
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSString *targetKey = [[NSString alloc] initWithFormat:@"%ld", (long)i-1];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        [mAlbumList removeObjectForKey:rootKey];
        [mAlbumList setObject:eachPerson forKey:targetKey];
    }
}

- (int) removeAlbumWithKey: (NSString *) key mergeBack: (BOOL) merge {
    NSString *deleteTarget = @"";
    int deleteIdx = -1;

    for (unsigned i = 0; i < mCount; i++) {
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        NSString *eachKey   = [eachPerson objectForKey:ALBUM_KEY_KEY];
        
        if ([eachKey isEqualToString:key]) {
            NSLog(@"Found it");
            deleteTarget = rootKey;
            deleteIdx = i;
        }
    }
    
    if (![deleteTarget isEqualToString:@""]) {
        if(LOCAL_DEBUG) NSLog(@"LOG: remove index %d with merge back %@", deleteIdx, merge ? @"YES" : @"NO");
        [self removeAllPhotosInAlbum:[self albumWithKey:key] mergeBackToDefaultAlbum:merge];
        [mAlbumList removeObjectForKey:deleteTarget];
        [self reorderAlbumId:deleteIdx];
    } else {
        NSLog(@"BUG: cannot find album key to delete!");
        return -1;
    }
    
    //[mAlbumList setObject:data forKey:rootName];
    [mAlbumList writeToFile:mAlbumListPath atomically:YES];
    [self refresh]; //TODO: need to remove refresh lazy code
    return 0;
}

- (Album *) albumWithKey: (NSString *) key {
    int targetIdx = -1;
    
    for (unsigned i = 0; i < mCount; i++) {
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        NSString *eachKey   = [eachPerson objectForKey:ALBUM_KEY_KEY];
        
        if ([eachKey isEqualToString:key]) {
            targetIdx = i;
        }
    }
    
    if (targetIdx != -1)
        return [mAlbums objectAtIndex:targetIdx];
    else
        return nil;
}

- (int) albumIndexWithKey: (NSString *) key {
    int targetIdx = -1;
    
    for (unsigned i = 0; i < mCount; i++) {
        NSString *rootKey = [[NSString alloc] initWithFormat:@"%ld", (long)i];
        NSDictionary *eachPerson = [mAlbumList objectForKey:rootKey];
        NSString *eachKey   = [eachPerson objectForKey:ALBUM_KEY_KEY];
        
        if ([eachKey isEqualToString:key]) {
            targetIdx = i;
        }
    }
    
    if (targetIdx != -1)
        return targetIdx;
    else
        return 0;
}



#pragma mark - Photo functions

/* ===================================
 * Photos functions
 * ===================================
 */

- (int) addPhotoInPath: (NSString *) path toAlbumWithKey: (NSString *) key {
    return 0;
}

- (int) addPhotoWithImage: (UIImage *) img toAlbum: (Album *) thisAlbum {
    // Save the image to database
    NSString *imageFileName = [self generateNewPhotoFileNameWithAlbum: thisAlbum];
    NSString *savePath = [mDocumentRootPath stringByAppendingPathComponent: imageFileName];
    [UIImagePNGRepresentation(img) writeToFile:savePath atomically:YES];
    NSLog(@"New image %@ saved.", imageFileName);

    // Update list
    NSMutableArray *photoList = [mAlbumPhotoList objectForKey:thisAlbum.mAlbumKey];
    [photoList addObject:imageFileName];
    [mAlbumPhotoList setObject:photoList forKey:thisAlbum.mAlbumKey];
    [mAlbumPhotoList writeToFile:mAlbumPhotoPath atomically:YES];
    
    // Increase the incr
    [self increaseAlbum:thisAlbum];
    
    // Update runtime list
    //[thisAlbum.mAlbumPhotos addObject:imageFileName];
    
    return 0;
}

/*
 * This function is called only in the procedure of album deleting.
 * Merge back to default album is also available in the merge option
 */
- (int) removeAllPhotosInAlbum: (Album *) thisAlbum mergeBackToDefaultAlbum: (BOOL) merge {

    // Make sure we are not deleting default album
    Album *defaultAlbum = [self albumInListAtIndex:0];
    NSMutableArray *defaultPhotoList = [mAlbumPhotoList objectForKey:defaultAlbum.mAlbumKey];
    if ([defaultAlbum.mAlbumKey isEqualToString:thisAlbum.mAlbumKey]) {
        NSLog(@"BUG: removing default album!! this is not allowed");
        return -3;
    }

    // Remove or merge back to default album
    if (merge) {
        // Initial file manager
        NSError * err = NULL;
        NSFileManager * fm = [[NSFileManager alloc] init];

        // Batching rename for default
        NSLog(@"this album key %@", thisAlbum.mAlbumKey);
        for (NSString *oldPhotoName in thisAlbum.mAlbumPhotos) {
            NSString *oldPath = [mDocumentRootPath stringByAppendingPathComponent: oldPhotoName];
            NSString *newPhotoName = [self generateNewPhotoFileNameWithAlbum: defaultAlbum];
            NSString *newPath = [mDocumentRootPath stringByAppendingPathComponent: newPhotoName];
            
            NSLog(@"Merge %@ to %@", oldPhotoName, newPhotoName);
            BOOL result = [fm moveItemAtPath:oldPath toPath:newPath error:&err];
            if(!result)
                NSLog(@"Error moving photo file: %@", err);
            
            [defaultPhotoList addObject:newPhotoName];
            // Increase the incr
            [self increaseAlbum:defaultAlbum];
            
        }
        
        // Update list, update file in outside
        [mAlbumPhotoList setObject:defaultPhotoList forKey:defaultAlbum.mAlbumKey];
        
    } else {
        
    }
    
    // Remove the key entry in albumImage.plist
    [mAlbumPhotoList removeObjectForKey:thisAlbum.mAlbumKey];
    [mAlbumPhotoList writeToFile:mAlbumPhotoPath atomically:YES];
    
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

/*
 * return the lastest photo in the album
 * If no photo in this album, it will return default prototypeImage
 */
- (UIImage *) topPhotoInAlbum: (Album *) album {
    NSString* firstPhotoFileName;
    NSString* firstPhotoFilePath;
    UIImage* ret;
    long photoCountInAlbum = [album.mAlbumPhotos count];
    
    if (!mValidate) {
        NSLog(@"BUG: try to get photo before it validate");
        return nil;
    }
    
    if (photoCountInAlbum > 0) {
        firstPhotoFileName = [album.mAlbumPhotos objectAtIndex:photoCountInAlbum - 1];
        firstPhotoFilePath = [[NSString alloc] initWithFormat:@"%@/%@", mDocumentRootPath, firstPhotoFileName];
        NSLog(@"First photo path is: %@", firstPhotoFilePath);
        ret = [[UIImage alloc] initWithContentsOfFile:firstPhotoFilePath];
    } else {
        NSLog(@"There is no photo in this album, give it a default top photo");
        ret = [UIImage imageNamed:@"prototypeImage"];
    }
    
    return ret;
}


#pragma mark - Debug functions
/*
 * Debug functions
 */
- (void) initPhotoFileDebug {
    [self getAllPictures];
}

- (void) getAllPictures {
    imageArray = [[NSArray alloc] init];
    mutableArray = [[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        static int count = 0;
        if(result != nil && count < 13) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];

                NSURL *url = (NSURL*) [[result defaultRepresentation] url];

                [library assetForURL:url
                         resultBlock:^(ALAsset *asset) {
                             static int count = 0;
                             [mutableArray addObject:[UIImage imageWithCGImage:[[asset defaultRepresentation]  fullScreenImage]]];

                             if (count == 11) {
                                 imageArray = [[NSArray alloc] initWithArray:mutableArray];
                                 [self allPhotosCollected:imageArray];
                             }
                             count ++;
                         }
                        failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); } ];
            }
        }
        count++;
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        static BOOL first_group = NO;
        if(group != nil && !first_group) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            //count = (int)[group numberOfAssets];
            if(LOCAL_DEBUG) NSLog(@"group enumerator finished");
            first_group = YES;
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) { NSLog(@"There is an error"); }];
}

- (void) allPhotosCollected: (NSArray*)imgArray {
    // We can deal with those images in user's photo library here
    NSLog(@"allPhotosCollected called %ld", [imgArray count]);
    int j = 0;
    for (Album *thisAlbum in mAlbums) {
        for (int i = 0; i < thisAlbum.mAlbumPhotos.count; i++) {
            NSString *savePath = [mDocumentRootPath stringByAppendingPathComponent:[thisAlbum.mAlbumPhotos objectAtIndex:i]];
            [UIImagePNGRepresentation([imgArray objectAtIndex:i+j*6]) writeToFile:savePath atomically:YES];
        }
        j++;
    }
}


#pragma mark - Utility functions
- (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i = 0; i < len; i++) {
        NSUInteger index = arc4random_uniform((unsigned)[letters length]);
        [randomString appendFormat: @"%C", [letters characterAtIndex: index]];
    }
    
    return randomString;
}

- (NSString *) generateNewPhotoFileNameWithAlbum: (Album*) thisAlbum {
    if (thisAlbum == nil) {
        return @"";
    }
    
    int serial = [thisAlbum.mSerial intValue];
    NSString *incr = thisAlbum.mIncrease;
    NSString *ret = [NSString stringWithFormat:@"IMG_%d%@.png", serial, incr];
    
    return ret;
}

- (void) debugPrint {
    NSLog(@"Album debug: %@", [mAlbumList description]);
    NSLog(@"Photo debug: %@", [mAlbumPhotoList description]);
}

@end
