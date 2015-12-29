//
//  PasswordViewController.m
//  Piccollect
//
//  Created by Josh on 2015/12/15.
//  Copyright © 2015年 Mu Mu Corp. All rights reserved.
//

#import "PasswordViewController.h"
#import "SettingsService.h"

@implementation PasswordViewController

@synthesize maxTryLabel;
@synthesize passworkTextField, delegate, errorAlert;
@synthesize mSettingsService;

#define LSTR(arg) NSLocalizedString(arg, nil)

int max_try;

- (void) initialAlert{
    errorAlert = [[UIAlertView alloc] initWithTitle:LSTR(@"Authorization Failed") message:LSTR(@"Please try again") delegate:nil cancelButtonTitle:LSTR(@"OK") otherButtonTitles:nil, nil];
}

- (void) showAlert{
    max_try--;
    [passworkTextField setText:@""];
    [maxTryLabel setText:[NSString stringWithFormat:LSTR(@"You have %d times to try") ,max_try]];
    
    if(max_try <= 0)
        exit(0);
    else
        [errorAlert show];
}

- (IBAction)cancel:(id)sender {
    [self showAlert];
    exit(0);
}

// TODO:這裡還必須處理時間問題。
- (IBAction)done:(id)sender {
    NSString *password = [mSettingsService getValueOfPrimaryKey:STOKEN_PASSWORD];
    
    if([[passworkTextField text] isEqualToString:password]) {
        [self dismissModal];
    } else {
        [self showAlert];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passworkTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void) dismissModal{
    [self.delegate addSightingViewControllerDidFinish:self];
    NSLog(@"Password authorization passed");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    max_try = 10;
    [passworkTextField becomeFirstResponder]; //使畫面一開始就出現鍵盤，讓使用者可以直接作輸入輸出。
    [self initialAlert];
    mSettingsService = [[SettingsService alloc] init]; // should not initialize here
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setPassworkTextField:nil];
    [self setMaxTryLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

