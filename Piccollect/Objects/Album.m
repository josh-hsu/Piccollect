//
//  Album.m
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize mAlbumName, mAlbumKey, mCreateDate, mOrder, mAlbumPhotos, mIncrease, mSerial;

- (void)initWithName:(NSString*) name key:(NSString*)key date:(NSDate*)date order:(NSNumber*)order incr:(NSString*) incr serial:(NSNumber*) serial{
    self.mAlbumName = name;
    self.mAlbumKey = key;
    self.mCreateDate = date;
    self.mOrder = order;
    self.mIncrease = incr;
    self.mSerial = serial;
}

+ (UIImage *)makeThumbWithImage: (UIImage *)image size:(int)w {
    CGSize newSize = CGSizeMake(w, w);
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MAX ( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = 0.0f;
    scaledImageRect.origin.y = 0.0f;
    
    UIGraphicsBeginImageContextWithOptions( scaledImageRect.size, NO, 0 );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

@end
