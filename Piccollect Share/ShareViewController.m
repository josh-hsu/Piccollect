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
    __block BOOL hasData = NO;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
            {
                [itemProvider loadItemForTypeIdentifier:@"public.url"
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                                          
                                          if ([(NSObject *)item isKindOfClass:[NSURL class]])
                                          {
                                              NSLog(@"URL = %@", item);
                                              NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.vimfung.ShareExtensionDemo"];
                                              [userDefaults setValue:((NSURL *)item).absoluteString forKey:@"share-url"];
                                              //Mark as new share
                                              [userDefaults setBool:YES forKey:@"has-new-share"];
                                              
                                              [activityIndicatorView stopAnimating];
                                              [theController.extensionContext completeRequestReturningItems:@[extItem] completionHandler:nil];
                                          }
                                          
                                      }];
                
                hasData = YES;
                *stop = YES;
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:
                 ^(UIImage *image, NSError *error) {
                     NSLog(@"Get Image");
                     NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mumu.piccollect.Piccollect-Share"];
                     [userDefaults setObject:UIImagePNGRepresentation(image) forKey:@"share-image"];
                     //Mark as new share
                     [userDefaults setBool:YES forKey:@"has-new-image"];
                     
                     [activityIndicatorView stopAnimating];
                     [theController.extensionContext completeRequestReturningItems:@[extItem] completionHandler:nil];
                }];
                
                hasData = YES;
                *stop = YES;
            }
            
        }];
        
        if (hasData)
        {
            *stop = YES;
        }
        
    }];
    
    if (!hasData)
    {
        // Exit
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
