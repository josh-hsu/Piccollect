//
//  Album.h
//  Piccollect
//
//  Created by Josh on 2015/11/22.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject {
    // Local variable, it cannot be accessed outside this method
    NSMutableArray *mAlbumPhotos;
}

// Album property
@property (nonatomic) NSString *mAlbumName;
@property (nonatomic) NSString *mAlbumKey;
@property (nonatomic) NSDate *mCreateDate;
@property (nonatomic) NSNumber *mOrder;
@property (nonatomic, retain) NSArray *mAlbumPhotos;

- (void)initWithName:(NSString*) Name key:(NSString*)key date:(NSDate*)date order:(NSNumber*)order;

@end
