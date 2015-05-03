//
//  AGTNewScoopViewController.h
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Scoop;

@interface AGTNewScoopViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *scoopTtile;
@property (weak, nonatomic) IBOutlet UITextView *scoopBody;
@property (weak, nonatomic) IBOutlet UIImageView *scoopPhoto;
@property (strong, nonatomic) Scoop *scoop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;

-(id)initWithScoop:(Scoop *)scoop;

- (IBAction)publishScoop:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)saveScoop:(id)sender;

@end
