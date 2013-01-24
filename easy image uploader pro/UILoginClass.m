//
//  UILoginClass.m
//  easy image uploader pro
//
//  Created by Jordi Kroon on 28-09-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import "UILoginClass.h"
#import "ImageViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"

#define LoginError      1
#define RegisterError   2




@interface UILoginClass ()


@end




@implementation NSData (NSDataDigestCategory)
- (NSString *)sha1 {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1([self bytes], [self length], digest);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:40];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", digest[i]];
    
    return hash; 
}


@end

@implementation NSString (NSStringDigestCategory)
- (NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    return [data sha1];

}

@end


@implementation UILoginClass : UITableViewController

@synthesize RegisterPass;
@synthesize RegisterUser;
@synthesize RegisterEmail;

@synthesize LoginPass;
@synthesize LoginUser;

-(IBAction)textFieldReturn:(id)sender
{
    NSLog(@"tapped return");
    [self.view endEditing:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    } 
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSLog(@"Login Form did load");
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View appears");
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"];
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error];
    }
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    int UIDvalue = [[root objectForKey:@"uid"] intValue];
    NSString *PKEYvalue = [root objectForKey:@"pkey"];
    NSLog(@"%i",UIDvalue);
    
    NSLog(@"%@",PKEYvalue);
    
    if([PKEYvalue isEqualToString:@""] || UIDvalue == 0) {
        // do nothing
    } else {
        [self performSegueWithIdentifier:@"pushToImageViewer" sender:self ];
    }
    
}


- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)CreateAccountHandle:(id)sender {
    NSLog(@"RegisterButton clicked");
    
    
    if([RegisterUser.text isEqualToString:@""]  ||
       [RegisterPass.text isEqualToString:@""]  ||
       [RegisterEmail.text isEqualToString:@""]) {
        
        NSLog(@"User didn't set all fields");
    
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:@"You didn't set all fields" delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        [alert show];
        
    } else {
        
        if(![self validateEmail:[RegisterEmail text]]) {
            
            NSLog(@"Email not correct");
        
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:@"Your email-adress is not valid!" delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
            [alert show];
        } else {

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            hud.mode = MBProgressHUDAnimationZoom;
            hud.labelText = NSLocalizedString(@"Registering", @"");;
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                NSString *Salt = @"c43C43v34C";
                NSString *Pepper = @"UTUBt6ERTyv78gDFE43CF";
            
                NSString *Newpass = [NSString stringWithFormat:@"%@%@%@", Salt, RegisterPass.text, Pepper];
                NSString *Hash = [Newpass sha1];
                // NSLog (@"Hash = %@", Newpass);
                NSLog (@"SHA1 = %@", Hash);
            
                NSString *post	 = [[NSString alloc] initWithFormat:@"registeruser=%@&key=Gty7v5#uvT6VimgIos&registerpass=%@&registeremail=%@", RegisterUser.text, RegisterPass.text, RegisterEmail.text];
                NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
                NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
            
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
                [request setURL:[NSURL URLWithString:@"https://www.imgios.com/auth.php"]];
                [request setHTTPMethod:@"POST"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:postData];
            
                NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
                NSLog(@"[%@]",returnString);
                
                /** returns
                 *
                 * notfound 	: user not found
                 * error		: fatal error (mysql)
                 * key			: returns the public key
                 * exist		: user already exist
                 * unknownkey	: key is not equals to uvT6VimgIos
                 */

                
                if([returnString isEqualToString: @"exist"] || [returnString isEqualToString: @"error"] || [returnString isEqualToString: @"unknownkey"]) {
                    
                    NSString *Error;
                    if([returnString isEqualToString: @"exist"]) {
                        Error = @"This username or email is already in use.";
                    } else if([returnString isEqualToString: @"error"]) {
                        Error = @"Maintenance , please try again later!";
                    } else if([returnString isEqualToString: @"unknownkey"]) {
                        Error = @"Unknown key while requesting to the server";
                    }
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:Error delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
                    [alert show];
                    
                    alert.tag = RegisterError;
                    
                } else {
                    
                    NSArray *plistData = [returnString componentsSeparatedByString:@":"];
                    
                    if([plistData count] == 2) {
                        
                        NSString *pkey = [plistData objectAtIndex: 0];
                        NSString *uid = [plistData objectAtIndex: 1];
                        
                        NSError *error;
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        
                        if (![fileManager fileExistsAtPath: path])
                        {
                            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"];
                            
                            [fileManager copyItemAtPath:bundle toPath: path error:&error];
                        }
                        
                        
                        NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
                        
                        [plistDict setValue:pkey forKey:@"pkey"];
                        [plistDict setValue:uid forKey:@"uid"];
                        
                        [plistDict writeToFile:path atomically: YES];
                        
                        NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
                        
                        int UIDvalue = [[root objectForKey:@"uid"] intValue];
                        NSString *PKEYvalue = [root objectForKey:@"pkey"];
                        NSLog(@"%i",UIDvalue);
                        
                        NSLog(@"%@",PKEYvalue);
                        
                        
                        [self performSegueWithIdentifier:@"pushToImageViewer" sender:self];
                        
                        
                         [self logOut];
                    }
                    
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
                           

        }
    }
}

- (void)logOut{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [plistDict setValue:@"" forKey:@"pkey"];
    [plistDict setValue:0 forKey:@"uid"];
    
    [plistDict writeToFile:path atomically: YES];
    
    [self performSegueWithIdentifier:@"x" sender:self];
    
}



- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailStr];
}



- (IBAction)LoginAccountHandle:(id)sender {
      NSLog(@"LoginButton clicked");
    

    if([LoginUser.text isEqualToString:@""]  ||
       [LoginPass.text isEqualToString:@""]) {
    
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:@"You didn't set all fields" delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"User didn't set all fields");

        
    } else {
 
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
        hud.mode = MBProgressHUDAnimationZoom;
        hud.labelText = NSLocalizedString(@"Logging in", @"");;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSString *Salt = @"c43C43v34C";
            NSString *Pepper = @"UTUBt6ERTyv78gDFE43CF";
        
            NSString *Newpass = [NSString stringWithFormat:@"%@%@%@", Salt, LoginPass.text, Pepper];
            NSString *Hash = [Newpass sha1];
            // NSLog (@"Hash = %@", Newpass);
            NSLog (@"SHA1 = %@", Hash);
    
            NSString *post	 = [[NSString alloc] initWithFormat:@"loginuser=%@&key=Gty7v5#uvT6VimgIos&loginpass=%@", LoginUser.text, LoginPass.text];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
            NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
            [request setURL:[NSURL URLWithString:@"https://www.imgios.com/auth.php"]];
        
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];

            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        


            if([returnString isEqualToString: @"notfound"] || [returnString isEqualToString: @"error"] || [returnString isEqualToString: @"unknownkey"]) {

                NSString *Error;
                if([returnString isEqualToString: @"notfound"]) {
                   Error = @"Incorrect username or password!";
                } else if([returnString isEqualToString: @"error"]) {
                    Error = @"Maintenance , please try again later!";
                } else if([returnString isEqualToString: @"unknownkey"]) {
                    Error = @"Unknown key while requesting to the server";
                }
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:Error delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
                [alert show];
                
                alert.tag = LoginError;
                
            } else {

                NSArray *plistData = [returnString componentsSeparatedByString:@":"];
            
                if([plistData count] == 2) {
                    
                    NSString *pkey = [plistData objectAtIndex: 0];
                    NSString *uid = [plistData objectAtIndex: 1];

                    NSError *error;
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
                    NSString *documentsDirectory = [paths objectAtIndex:0]; 
                    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if (![fileManager fileExistsAtPath: path]) 
                    {
                        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"]; 
                        
                        [fileManager copyItemAtPath:bundle toPath: path error:&error]; 
                    }
                    
                    
                    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
                    
                    [plistDict setValue:pkey forKey:@"pkey"];
                    [plistDict setValue:uid forKey:@"uid"];
                    
                    [plistDict writeToFile:path atomically: YES];
                    
                    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
                    
                    int UIDvalue = [[root objectForKey:@"uid"] intValue];
                    NSString *PKEYvalue = [root objectForKey:@"pkey"];
                    NSLog(@"%i",UIDvalue);

                     NSLog(@"%@",PKEYvalue);

                    
                    [self performSegueWithIdentifier:@"pushToImageViewer" sender:self];

                                                

                }

            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"ERROR: Memory warning");
    // Dispose of any resources that can be recreated.
}





- (void)viewDidUnload {
    [self setLoginUser:nil];
    [self setLoginPass:nil];
    [self setLoginButton:nil];
    [self setRegisterUser:nil];
    [self setRegisterPass:nil];
    [self setRegisterEmail:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}

@end

