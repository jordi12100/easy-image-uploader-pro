//
//  eiopro_FirstViewController.h
//  easy image uploader pro
//
//  Created by Jordi Kroon on 27-09-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAD.h>
#import <SystemConfiguration/SystemConfiguration.h>


@class Reachability;

Reachability* internetReachable;
Reachability* hostReachable;

@interface eiopro_FirstViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ADBannerViewDelegate ,
UIAlertViewDelegate >

@property (retain, nonatomic) IBOutlet UIBarButtonItem *UploadButton;
@property (retain, nonatomic) IBOutlet UIImageView *ImageView;



-(void) checkNetworkStatus:(NSNotification *)notice;
- (IBAction)tapUpload:(id)sender;
- (IBAction)uploadImage:(id)sender;


@end

