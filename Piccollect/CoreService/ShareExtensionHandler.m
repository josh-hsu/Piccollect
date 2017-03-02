//
//  ShareExtensionHandler.m
//  Piccollect
//
//  Created by Josh on 2017/3/2.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import "ShareExtensionHandler.h"
#import <Foundation/Foundation.h>

@implementation ShareExtensionHandler

+ (BOOL) checkNewPhotosFromExtension: (AlbumListService *) albumService {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mumu.piccollect.Piccollect-Share"];
    
    if ([userDefaults boolForKey:@"has-new-image"]) {
        long imageCount = [userDefaults integerForKey:@"share-image-count"];
        
        for (int i = 0; i < imageCount; i++ ) {
            NSString *thisKey = [NSString stringWithFormat:@"share-image-%d", i];
            NSData* imageData = [userDefaults objectForKey:thisKey];
            UIImage* image = [UIImage imageWithData:imageData];
            UIImage* thumbnail = [Album makeThumbWithImage:image size:95];
            [albumService addPhotoWithImage:image andThumb:thumbnail toAlbum:[albumService albumInListAtIndex:0]];
        }
        
        [userDefaults setBool:NO forKey:@"has-new-image"];
        return true;
    } else {
        return false;
    }
}

@end
