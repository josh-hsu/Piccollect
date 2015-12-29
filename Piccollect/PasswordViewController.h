//
//  PasswordViewController.h
//  Piccollect
//
//  Created by Josh on 2015/12/15.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol StartViewControllerDelegate;
@class SettingsService;

@interface PasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passworkTextField;
@property (retain, atomic) id <StartViewControllerDelegate> delegate;
@property (retain, atomic) UIAlertView *errorAlert;
@property (weak, nonatomic) IBOutlet UILabel *maxTryLabel;
@property (nonatomic, retain) SettingsService *mSettingsService;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (void) initialAlert;
- (void) showAlert;
- (void) dismissModal;

@end

@protocol StartViewControllerDelegate <NSObject>
- (void)addSightingViewControllerDidCancel:(PasswordViewController *)controller;
- (void)addSightingViewControllerDidFinish:(PasswordViewController *)controller;
@end
