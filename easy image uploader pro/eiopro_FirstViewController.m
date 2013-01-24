//
//  eiopro_FirstViewController.m
//  easy image uploader pro
//
//  Created by Jordi Kroon on 27-09-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import "eiopro_FirstViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface eiopro_FirstViewController ()

@end

@implementation eiopro_FirstViewController


@synthesize UploadButton;
@synthesize ImageView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UploadButton.enabled = YES;
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    hostReachable = [[Reachability reachabilityWithHostName: @"www.google.nl"] retain];
    [hostReachable startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeImage)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
}



- (void) removeImage {
    NSLog(@"did enter background!");
    ImageView.image = nil;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setUploadButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)tapUpload:(id)sender {
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Uploadmethod", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"Camera", @""),
                                 NSLocalizedString(@"Photolib", @""), nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showFromToolbar:self.view];
	[popupQuery release];
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // choose picture
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
    }
    
    if(buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:picker animated:YES];
        
    }
    
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker  {
    [picker dismissModalViewControllerAnimated:YES];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissModalViewControllerAnimated:YES];
    
    
    UIImage* originalImage = nil;
    originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(originalImage==nil)
    {
        NSLog(@"image picker original");
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        
        NSLog(@"image picker editedImage");
    }
    if(originalImage==nil)
    {
        NSLog(@"image picker croprect");
        originalImage = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    ImageView.image = originalImage;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    hud.mode = MBProgressHUDAnimationZoom;
    hud.labelText = NSLocalizedString(@"Uploading", @"");;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.6);
        NSString *urlString = @"http://imgios.com/upload.php";
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];	[request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",returnString);
        
        hud.labelText = NSLocalizedString(@"Succeed", @"");
        
        [NSThread sleepForTimeInterval:1.0f];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.transform = CGAffineTransformTranslate( alert.transform, 0.0, -100.0 );
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = returnString;
        alertTextField.enabled = NO;
        [alert show];
        [alert release];
        alert.tag = 1;
        
        [UIPasteboard generalPasteboard].string = alertTextField.text;
        NSLog(@"URL pasted to clipboard");
    });
    
    
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    
    if(internetStatus == NotReachable || hostStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nocontitle", @"")
                                                        message:NSLocalizedString(@"Nocontxt", @"A valid internet connection is required to communicate with the servers. Please turn on WIFI or 3G!")
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
}


@end