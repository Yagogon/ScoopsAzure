//
//  AGTScoopsAzure.m
//  ScoopsAzure
//
//  Created by Yago de la Fuente on 28/4/15.
//  Copyright (c) 2015 cinnika. All rights reserved.
//

#import "AGTScoopsAzure.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "Keys.h"
#import "Scoop.h"
#import "Constants.h"

#define TITLE_COLUMN @"title"
#define DATE_COLUMN @"createDate"
#define BODY_COLUMN @"body"
#define AUTHOR_ID_COLUMN @"id_author"
#define AUTHOR_NAME_COLUMN @"author_name"
#define PUBLISHED_COLUMN @"published"
#define APPROVED_COLUMN @"approved"
#define BLOB_NAME_COLUMN @"blobName"
#define LIKE_COLUM @"likeScoop"
#define NEWS_TABLE @"News"
#define USER_NAME @"userName"


@implementation AGTScoopsAzure

MSClient * client;
NSString *userFBId;
NSString *tokenFB;


#pragma mark - Recuperar desde azure

-(void)populateModelFromAzure:  (void (^)(NSArray * array))completionBlock{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
     NSString *userName =  [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];
    
    NSDictionary *dict = @{ @"idAuthor" : userName};
    
    [client invokeAPI:@"getscoopsbyauthorname"
                 body:nil
           HTTPMethod:@"GET"
           parameters:dict
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar noticias del autor: %@", error);
               } else if (result){
                   NSMutableArray *scoops = [[NSMutableArray alloc]init];
                   
                   for (NSDictionary *dict in result) {
                       
                       Scoop *scoop = [[Scoop alloc] initWithDict:dict];
                       [scoops addObject:scoop];
                   }
                   completionBlock(scoops);
               }
           }];
    
}

-(void)populateReaderModelFromAzure:  (void (^)(NSArray * array))completionBlock{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    [client invokeAPI:@"getpublishedscoops"
                 body:nil
           HTTPMethod:@"GET"
           parameters:nil
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar noticias del autor: %@", error);
               } else if (result) {
                   
                   NSMutableArray *scoops = [[NSMutableArray alloc]init];
                   
                   for (NSDictionary *dict in result) {
                       
                       Scoop *scoop = [[Scoop alloc] initWithDict:dict];
                       [scoops addObject:scoop];
                       
                   }
                   completionBlock(scoops);
               }
           }];
    
}

-(void) userInfo:(void (^)(id result))completionBlock{

    
    [client invokeAPI:@"getuserinfo"
                 body:nil
           HTTPMethod:@"GET"
           parameters:nil
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error){
               
               if (error) {
                   NSLog(@"Error recuperando info usuario: %@", error);
               } else {
                   completionBlock(result);
                   NSLog(@"Info usuario: %@", result);
               }
     
    }];
    
}

-(void) scoopWithTitle:(NSString *) title completion: (void (^)(NSArray * array))completionBlock{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    NSDictionary *dict = @{ @"scoopTitle" : title};
    
    [client invokeAPI:@"getscoopwithname"
                 body:nil
           HTTPMethod:@"GET"
           parameters:dict
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar noticia: %@", error);
               } else {
                   completionBlock(result);
               }
           }];
    
    
}

#pragma mark - Actualizar

-(void) publishScoop: (Scoop *) scoop {
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    NSDictionary *params = @{@"ScoopTitle" : scoop.title};
    
    [client invokeAPI:@"publishscoops"
                 body:nil
           HTTPMethod:@"GET"
           parameters:params
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar noticias del autor: %@", error);
               } else {
                   [[NSNotificationCenter defaultCenter] postNotificationName:SCOOP_WAS_PUBLISHED
                                                                       object:nil
                                                                     userInfo:nil];
               }
           }];
    
}

-(void) likeScoop: (Scoop *) scoop vote: (NSNumber *) vote{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    NSDictionary *params = @{@"ScoopTitle" : scoop.title,
                             @"likeFromUser" : vote };
    
    [client invokeAPI:@"likescoop"
                 body:nil
           HTTPMethod:@"GET"
           parameters:params
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al votar noticia: %@", error);
               }
           }];
    
}

#pragma mark - Guardar en azure

-(void)saveScoopInAzure: (Scoop *) scoop errorBlock: (void (^)(NSError * error))errorBlock
        completionBlock:(void (^)(NSDictionary * result))completionBlock{
    
    
    [self warmupMSClient];
    
    [self loadUserAuthInfo];
    
    MSTable *news = [client tableWithName:NEWS_TABLE];
    NSString *userName =  [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];

    
    NSDictionary *scoopDict = @{TITLE_COLUMN: scoop.title,
                                BODY_COLUMN  : scoop.text,
                                DATE_COLUMN : scoop.dateCreated,
                                AUTHOR_ID_COLUMN : client.currentUser.userId,
                                AUTHOR_NAME_COLUMN: userName,
                                PUBLISHED_COLUMN: @NO,
                                APPROVED_COLUMN : @NO,
                                BLOB_NAME_COLUMN : scoop.blobName,
                                LIKE_COLUM : @0
                                };
    [news insert:scoopDict
      completion:^(NSDictionary *item, NSError *error) {
          if (error) {
              NSLog(@"Error %@", error);
              errorBlock(error);
          } else {
              NSLog(@"Todo OK");
              [[NSNotificationCenter defaultCenter] postNotificationName:SCOOP_ADDED_NOTIFICATION
                                                                  object:nil
                                                                userInfo:@{SCOOP_KEY : scoopDict}];
              completionBlock(item);

          }
      }];
    
    
}

-(void)saveBlobWithName: (NSString *) blobName data: (NSData *) data {
    
    [self blobURLWithBlobName:blobName completion:^(NSURL *url) {
        
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        
        NSURLSessionUploadTask * uploadTask = [[NSURLSession sharedSession]uploadTaskWithRequest:request
                                                                                        fromData:data
                                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                                   // nada de momento
                                                                                   
                                                                                   if (error) {
                                                                                       NSLog(@"Error al subir el blob %@", error);
                                                                                   }
                                                                               }];
        [uploadTask resume];
    }];
    
}

-(void) blobURLWithBlobName: (NSString *) blobName completion: (void (^)(NSURL * url))completionBlock{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    NSDictionary *dict = @{ @"blobName" : blobName};
    
    [client invokeAPI:@"getbloburlwithname"
                 body:nil
           HTTPMethod:@"GET"
           parameters:dict
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar url del blob: %@", error);
               } else {
                   NSString *urlName = [result objectForKey:@"sasUrl"];
                   completionBlock([NSURL URLWithString:urlName]);
               }
           }];
    
}

-(void) blobReadURLWithBlobName: (NSString *) blobName completion: (void (^)(NSURL * url))completionBlock{
    
    [self warmupMSClient];
    [self loadUserAuthInfo];
    
    NSDictionary *dict = @{ @"blobName" : blobName};
    
    [client invokeAPI:@"getblobreadurlwithname"
                 body:nil
           HTTPMethod:@"GET"
           parameters:dict
              headers:nil
           completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
               
               if (error) {
                   NSLog(@"Error al recuperar url del blob: %@", error);
               } else {
                   NSString *urlName = [result objectForKey:@"sasUrl"];
                   completionBlock([NSURL URLWithString:urlName]);
               }
           }];
    
}



#pragma mark - Azure connect, setup, login etc...

-(void)warmupMSClient{
    
    
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
    NSLog(@"%@", client.debugDescription);
}

#pragma mark - Login

- (void)loginAppInViewController:(UIViewController *)controller
           destinationController: (UIViewController *) toController
                  withCompletion:(completeBlock)bloque{
    
    [self warmupMSClient];
    
    [self loadUserAuthInfo];
    
    if (client.currentUser){
        
        bloque(nil);
        return;
    }
    
    [client loginWithProvider:@"facebook"
                   controller:controller
                     animated:YES
                   completion:^(MSUser *user, NSError *error) {
                       
                       if (error) {
                           [self loginAppInViewController:controller
                                    destinationController: toController
                                           withCompletion:bloque];
                       } else {
                           NSLog(@"user -> %@", user);
                           
                           [self saveAuthInfo];
                           [self userInfo:^(id result) {
                               NSString *userName = result[@"name"];
                               [[NSUserDefaults standardUserDefaults]setObject:userName
                                                                        forKey:USER_NAME];

                           }];
                           bloque(@[user]);
                       }
                   }];
    
}


- (BOOL)loadUserAuthInfo{
    
    
    
    userFBId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userID"];
    tokenFB = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
    
    if (userFBId) {
        client.currentUser = [[MSUser alloc]initWithUserId:userFBId];
        client.currentUser.mobileServiceAuthenticationToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"tokenFB"];
        
        
        
        return TRUE;
    }
    
    return FALSE;
}


- (void) saveAuthInfo{
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.userId forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:client.currentUser.mobileServiceAuthenticationToken
                                             forKey:@"tokenFB"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
}

@end
