//
//  Album.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface Album : NSObject {

}

// Album property
@property (nonatomic) NSString *mAlbumName;
@property (nonatomic) NSString *mAlbumKey;
@property (nonatomic) NSDate *mCreateDate;
@property (nonatomic) NSNumber *mOrder;
@property (nonatomic) NSString *mIncrease;
@property (nonatomic) NSNumber *mSerial;
@property (nonatomic, retain) NSMutableArray *mAlbumPhotos;

- (void)initWithName:(NSString*) Name key:(NSString*)key date:(NSDate*)date order:(NSNumber*)order incr:(NSString*) incr serial:(NSNumber*) serial;

+ (UIImage *)makeThumbWithImage: (UIImage *)image size:(int)w;
@end
