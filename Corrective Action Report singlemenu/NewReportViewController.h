//
//  NewReportViewController.h
//  Corrective Action Report singlemenu
//
//  Created by Devon Bellizio on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NewReportViewController : UIViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ZBarReaderDelegate>
    {
        UITextView *barcodeText;
    }

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *movieURL;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (assign, nonatomic) CGRect imageFrame;
@property (nonatomic, retain) IBOutlet UITextView *barcodeText;

// Declares button actions
- (IBAction)cameraButtonPressed:(UIButton *)sender;
- (IBAction)barcodeButtonPressed:(UIButton *)sender;
- (IBAction)clearButtonPressed:(UIButton *)sender;
@end
