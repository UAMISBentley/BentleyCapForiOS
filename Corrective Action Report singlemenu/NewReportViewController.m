//
//  NewReportViewController.m
//  Corrective Action Report singlemenu
//
//  Created by Devon Bellizio on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewReportViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#define kFilename @"tempdata.plist"
#define permFilename @"PermanentData.plist"

@interface NewReportViewController ()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation NewReportViewController
@synthesize imageView;
@synthesize takePictureButton;
@synthesize moviePlayerController;
@synthesize image;
@synthesize movieURL;
@synthesize lastChosenMediaType;
@synthesize imageFrame;
@synthesize barcodeText;
@synthesize Description;
@synthesize Location;
@synthesize BarcodeOutput;
@synthesize PictureReference;

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

// Method that calls action sheet once camera button is pressed
- (IBAction)cameraButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"New Photo", @"Choose From Gallery", nil];
    [actionSheet showInView:self.view];
}

// Method that calls the Zbar barcode application once barcode button is pressed
- (IBAction)barcodeButtonPressed:(id)sender {
    NSLog(@"TBD: scan barcode here...");
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    //[reader release];
}

// Method that minimizes action sheet once user selects button from index
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]){
        if (buttonIndex == 0){
            // Loads camera application
            [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];}
        else {
            // Loads photo gallery
            [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];}
    }
}

// Method that will hide the takePictureButton if the device does not have a camera
// Called only when the view has just been loaded into memory
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *TempDataArray = [[NSArray alloc] initWithContentsOfFile:filePath]; 
        Location.text = [TempDataArray objectAtIndex:0];
        Description.text = [TempDataArray objectAtIndex:1];
        BarcodeOutput.text = [TempDataArray objectAtIndex:2];
        PictureReference.text = [TempDataArray objectAtIndex:3]; }
    UIApplication *app = [UIApplication sharedApplication]; [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ])
    {
        takePictureButton.hidden = YES;
    }
    imageFrame = imageView.frame;
}

// Called every time the view is displayed
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateDisplay];
}

// Method that gets rid of views
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.imageView = nil;
    self.takePictureButton = nil;
    self.moviePlayerController =nil;
    self.Description = nil;
    self.Location = nil;
    self.BarcodeOutput = nil;
    self.PictureReference = nil;
}
 
#pragma mark UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *shrunkenImage = shrinkImage(chosenImage, imageFrame.size);
        self.image = shrunkenImage; }
    else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        self.movieURL = [info objectForKey:UIImagePickerControllerMediaURL]; }
    [picker dismissModalViewControllerAnimated:YES];
    imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
}

- (void) barcodePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    barcodeText.text = symbol.data;
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

// Method that dismisses the image picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
// Function that shrinks image down to the size of the view
static UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width * scale, size.height * scale), original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return final;
}

// Method that updates the display
- (void)updateDisplay {
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        imageView.image = image;
        imageView.hidden = NO;
        moviePlayerController.view.hidden = YES;
    }
    else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        [self.moviePlayerController.view removeFromSuperview];
        self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        moviePlayerController.view.frame = imageFrame;
        moviePlayerController.view.clipsToBounds = YES;
        [self.view addSubview:moviePlayerController.view];
        imageView.hidden = YES; }
}

// Method that creates and configures the image picker
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
    }
    // Error notification
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error accessing media"
                              message:@"This device does not support that media source."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) dealloc
{
    self.barcodeText = nil;
    //[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else {
        return YES;
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification { NSMutableArray *TempDataArray = [[NSMutableArray alloc] init];
    [TempDataArray addObject:Location.text];
    [TempDataArray addObject:Description.text];
    [TempDataArray addObject:BarcodeOutput.text];
    [TempDataArray addObject:PictureReference.text];
    [TempDataArray writeToFile:[self dataFilePath] atomically:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
@end
