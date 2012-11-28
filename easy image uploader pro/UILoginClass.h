//
//  UILoginClass.h
//  easy image uploader pro
//
//  Created by Jordi Kroon on 28-09-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UILoginClass : UITableViewController

//login
@property (strong, nonatomic) IBOutlet UITextField    *LoginUser;
@property (strong, nonatomic) IBOutlet UITextField    *LoginPass;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;

//register
@property (strong, nonatomic) IBOutlet UITextField *RegisterUser;
@property (strong, nonatomic) IBOutlet UITextField *RegisterPass;
@property (strong, nonatomic) IBOutlet UITextField *RegisterEmail;
@property (strong, nonatomic) IBOutlet UILabel *RegisterButton;



- (IBAction)LoginAccountHandle: (id) sender;
- (IBAction)CreateAccountHandle: (id) sender;


- (IBAction)textFieldReturn:(id)sender;
- (IBAction)backgroundTouched:(id)sender;

-(NSString*)stringToSha1;


@end
