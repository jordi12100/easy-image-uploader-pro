//
//  ImageView.m
//  easy image uploader pro
//
//  Created by Jordi Kroon on 22-12-12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import "ImageView.h"
#import "MBProgressHUD.h"

@interface ImageView ()

@end

@implementation ImageView


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.selectedIndex = 1;
    [self.tabBarController.selectedViewController viewDidAppear:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

     self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    hud.mode = MBProgressHUDAnimationZoom;
    hud.labelText = NSLocalizedString(@"Loading images", @"");;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *post	 = [[NSString alloc] initWithFormat:@"userid=%i&key=Gty7v5#uvT6VimgIos&pkey=%@", UIDvalue, PKEYvalue];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        [request setURL:[NSURL URLWithString:@"https://www.imgios.com/checkimg.php"]];
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

        if([returnString isEqualToString: @"noauth"] || [returnString isEqualToString: @"error"] || [returnString isEqualToString: @"unknownkey"]) {
            
            NSString *Error;
            if([returnString isEqualToString: @"noauth"]) {
                Error = @"Not authenticated!";
            } else if([returnString isEqualToString: @"error"]) {
                Error = @"Maintenance , please try again later!";
            } else if([returnString isEqualToString: @"unknownkey"]) {
                Error = @"Unknown key while requesting to the server";
            }
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:Error delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
            [alert show];
            
            if([returnString isEqualToString: @"noauth"] ) {
                
                NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
                
                [plistDict setValue:@"" forKey:@"pkey"];
                [plistDict setValue:0 forKey:@"uid"];
                
                [plistDict writeToFile:path atomically: YES];
                
                [self performSegueWithIdentifier:@"Pushtologin" sender:self];
            }
            
            
        } else {
            
            NSArray *plistData = [returnString componentsSeparatedByString:@":"];
            
            if([plistData count] == 2) {

                

                
                NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
                
                int UIDvalue = [[root objectForKey:@"uid"] intValue];
                NSString *PKEYvalue = [root objectForKey:@"pkey"];
                NSLog(@"%i",UIDvalue);
                
                NSLog(@"%@",PKEYvalue);
                
                

                
        tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [tableData objectAtIndex: [indexPath row]];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
  

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
