//
//  AppDelegate.m
//  Piccollect
//
//  Created by Josh on 2015/11/21.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mumu.piccollect.Piccollect-Share"];
    
    if ([userDefaults boolForKey:@"has-new-image"]) {
        AlbumListService* mAlbumService = [[AlbumListService alloc] init];
        long imageCount = [userDefaults integerForKey:@"share-image-count"];
        
        for (int i = 0; i < imageCount; i++ ) {
            NSString *thisKey = [NSString stringWithFormat:@"share-image-%d", i];
            NSData* imageData = [userDefaults objectForKey:thisKey];
            UIImage* image = [UIImage imageWithData:imageData];
            UIImage* thumbnail = [Album makeThumbWithImage:image size:95];
            [mAlbumService addPhotoWithImage:image andThumb:thumbnail toAlbum:[mAlbumService albumInListAtIndex:0]];
        }
        
        [userDefaults setBool:NO forKey:@"has-new-image"];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
