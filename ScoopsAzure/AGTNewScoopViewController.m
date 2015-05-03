//
//  AGTNewScoopViewController.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "AGTNewScoopViewController.h"
#import "AGTScoopsAzure.h"
#import "Scoop.h"


@interface AGTNewScoopViewController ()

@end

@implementation AGTNewScoopViewController

#pragma mark - Init

-(id)initWithScoop:(Scoop *)scoop {
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _scoop = scoop;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self syncModelAndView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
     self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Util

-(NSString *) nameFromImage {
    
    return [NSString stringWithFormat:@"%lu_image", self.scoopTtile.hash];
    
}

-(void)syncViewAndModel {
    
    self.scoop = [[Scoop alloc] initWithTitle:self.scoopTtile.text
                                     andPhoto:nil
                                        aText:self.scoopBody.text
                                     anUserId:nil
                                     anAuthor:nil
                                        aCoor:CLLocationCoordinate2DMake(0, 0)
                                     blobName:[self nameFromImage]];
    
}

-(void)syncModelAndView {
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.scoopTtile.text = self.scoop.title;
    self.scoopBody.text = self.scoop.text;
    self.scoopPhoto.image = [UIImage imageNamed:@"no_image.png"];
    
    [self updateImageWithName:self.scoop.blobName
                   completion:^(NSData *data) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.scoopPhoto.image = [UIImage imageWithData:data];
                       });
                       
                   }];
    
    if (self.scoop) {
        self.saveButton.enabled = NO;
    }
    
    if (self.scoop.aprobada) {
        self.publishButton.enabled = NO;
    }
    
}

-(void) updateImageWithName:(NSString *) blobName completion: (void (^)(NSData * data))completionBlock{
    
    if (blobName) {
        
        AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
        
        [azure blobReadURLWithBlobName:blobName completion:^(NSURL *url) {
            
            NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:conf];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NSURLSessionDataTask *task = [downloadSession dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                
                                                                completionBlock(data);
                                                            }];
            [task resume];
            
            
        }];
    }
    
}

#pragma mark - Actions

- (IBAction)publishScoop:(id)sender {
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];

    self.scoop.aprobada = YES;
    
    [azure publishScoop:self.scoop];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
}

- (IBAction)takePicture:(id)sender {
    
    // Creamos un UIImagePickerController
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // Lo configuro
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Uso la camara
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        // Tiro del carrete
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    picker.delegate = self;
    
    // Lo muestro de forma modal
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:picker
                       animated:YES
                     completion:^{
                         // Esto se va a ejecutar cuando termine la animación que muestra al Picker.
                     }];
    
}

- (IBAction)saveScoop:(id)sender {
    
    [self syncViewAndModel];
    
    AGTScoopsAzure *azure = [[AGTScoopsAzure alloc] init];
    
    [azure saveBlobWithName:[self nameFromImage] data:UIImageJPEGRepresentation(self.scoopPhoto.image, 0.1)];
    
     [azure saveScoopInAzure:self.scoop errorBlock:^(NSError *error) {
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Field errors"
                                                                            message:error.localizedDescription
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         });

     } completionBlock:^(NSDictionary *result) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.navigationController popToRootViewControllerAnimated:YES];
         });
         
     }];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.scoopPhoto.image = img;
    
    // Quito de encima el controlador que estamos presentando
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 // Se ejecutará cuando se haya ocultado del todo
                             }];
}

@end
