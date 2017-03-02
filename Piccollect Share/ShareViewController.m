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
    // Initial animation to tell user current processing
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.frame = CGRectMake((self.view.frame.size.width - activityIndicatorView.frame.size.width) / 2,
                                             (self.view.frame.size.height - activityIndicatorView.frame.size.height) / 2,
                                             activityIndicatorView.frame.size.width,
                                             activityIndicatorView.frame.size.height);
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:activityIndicatorView];
    
    // play the animation
    [activityIndicatorView startAnimating];
    
    __weak ShareViewController *theController = self;
    __block NSInteger imageCount = 0;
    __block NSInteger fetchCount = 0;
    //static dispatch_once_t oncePredicate;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mumu.piccollect.Piccollect-Share"];
    
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // this is a stupid way to get image count, but i don't have better idea to confirm that item is actually an image
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                imageCount++;
            }
        }];
        NSLog(@"Enumerate image count %ld", imageCount);
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                
                // retrieve data from itemProvider. This is done in asynchronous way
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:
                 ^(UIImage *image, NSError *error) {
                     NSString *thisKey = [NSString stringWithFormat:@"share-image-%ld", idx];
                     [userDefaults setObject:UIImagePNGRepresentation(image) forKey:thisKey];
                     [activityIndicatorView stopAnimating];
                     
                     // this should only be called once and only once at the last object is fetched
                     fetchCount ++;
                     if(fetchCount == imageCount) {
                         //dispatch_once(&oncePredicate, ^{
                             NSLog(@"All done, run controller");
                             [userDefaults setBool:YES forKey:@"has-new-image"];
                             [userDefaults setInteger:imageCount forKey:@"share-image-count"];
                             [theController.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                         //});
                     }
                     NSLog(@"Enumerate done 1");
                 }];
            }
        }];
    }];
    
    if (imageCount == 0) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem * oneItem = [[SLComposeSheetConfigurationItem alloc] init];
    
    oneItem.title = @"儲存至預設相簿";
    
    oneItem.valuePending = NO;
    
    return@[oneItem];
}

@end
