//
//  ShareViewController.m
//  Piccollect Share
//
//  Created by Josh on 2017/3/1.
//  Copyright © 2017年 Mu Mu Corp. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    __weak ShareViewController *theController = self;
    __block NSInteger imageCount = 0;
    __block NSInteger fetchCount = 0;
    __block NSInteger currentPendingImageCount = 0;
    //static dispatch_once_t oncePredicate; //use this will cause irregular stuck on second share
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mumu.piccollect.Piccollect-Share"];
    
    currentPendingImageCount = [userDefaults integerForKey:@"share-image-count"];
    imageCount = 0;
    fetchCount = 0;
    
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // this is a stupid way to get image count, but i don't have better idea to confirm that item is actually an image
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                imageCount++;
            }
        }];
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                
                // retrieve data from itemProvider. This is done in asynchronous way
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:
                 ^(UIImage *image, NSError *error) {
                     NSString *thisKey = [NSString stringWithFormat:@"share-image-%ld", idx + currentPendingImageCount];
                     NSLog(@"Save image in key %@", thisKey);
                     [userDefaults setObject:UIImagePNGRepresentation(image) forKey:thisKey];
                     
                     // this should only be called once and only once at the last object is fetched
                     fetchCount ++;
                     if(fetchCount == imageCount) {
                         //dispatch_once(&oncePredicate, ^{
                             NSLog(@"All done, run controller");
                             [userDefaults setBool:YES forKey:@"has-new-image"];
                             [userDefaults setInteger:(imageCount + currentPendingImageCount) forKey:@"share-image-count"];
                             [theController.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                         //});
                     }
                 }];
            }
        }];
    }];
    
    if (imageCount == 0) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memory usage too large.");
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem * oneItem = [[SLComposeSheetConfigurationItem alloc] init];
    
    oneItem.title = @"儲存至預設相簿";
    oneItem.value = @"目前只支援到預設相簿";
    oneItem.valuePending = NO;
    
    return@[oneItem];
}

@end
