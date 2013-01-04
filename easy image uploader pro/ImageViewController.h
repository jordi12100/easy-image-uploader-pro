//
//  ImageViewController.h
//  easy image uploader pro
//
//  Created by Jordi Kroon on 08-10-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIBarButtonItem *LogoutButton;

- (IBAction)LogOut:(id)sender;

@end
