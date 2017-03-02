//
//  ShareExtensionHandler.h
//  Piccollect
//
//  Created by Josh on 2017/3/2.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "AlbumListService.h"

@interface ShareExtensionHandler : NSObject {
    
}

+ (BOOL) checkNewPhotosFromExtension: (AlbumListService *) albumService;

@end
