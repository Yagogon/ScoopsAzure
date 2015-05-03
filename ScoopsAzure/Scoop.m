//
//  Scoop.m
//  Scoops
//
//  Created by Juan Antonio Martin Noguera on 17/04/15.
//  Copyright (c) 2015 Cloud On Mobile. All rights reserved.
//

#import "Scoop.h"

#define TITLE_COLUMN @"title"
#define DATE_COLUMN @"createDate"
#define BODY_COLUMN @"body"
#define AUTHOR_ID_COLUMN @"id_author"
#define AUTHOR_NAME_COLUMN @"author_name"
#define PUBLISHED_COLUMN @"published"
#define APPROVED_COLUMN @"approved"
#define LIKE_COLUM @"likeScoop"
#define BLOB_NAME_COLUMN @"blobname"

@interface Scoop ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *author;
@property (nonatomic) CLLocationCoordinate2D coors;
@property (nonatomic, nonatomic, nonatomic, strong) NSDate *dateCreated;


@end


@implementation Scoop


-(id)initWithTitle:(NSString *)title
          andPhoto:(NSData *)img
             aText:(NSString *)text
          anUserId:(NSString *) anUserID
          anAuthor:(NSString *)author
             aCoor:(CLLocationCoordinate2D)coors
          blobName:(NSString *)blobName
{
    
    if (self = [super init]) {
        _title = title;
        _text = text;
        _author = author;
        _coors = coors;
        _image = img;
        _dateCreated = [NSDate date];
        _likes = 0;
        _userId = anUserID;
        _publicada = NO;
        _aprobada = NO;
        _blobName = blobName;
    }
    
    return self;
    
}

-(id)initWithDict: (NSDictionary *)dict {
    
    if (self = [super init]) {
        _title = dict[TITLE_COLUMN];
        _text = dict[BODY_COLUMN];
        _likes = [dict[LIKE_COLUM]intValue];
        _dateCreated = dict[DATE_COLUMN];
        _aprobada = [dict[APPROVED_COLUMN] boolValue];
        _blobName = dict[BLOB_NAME_COLUMN];
    }
    
    return self;
    
}

#pragma mark - Overwritten

-(NSString*) description{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], self.title];
}


- (BOOL)isEqual:(id)object{
    
    
    return [self.title isEqualToString:[object title]];
}

- (NSUInteger)hash{
    return [_title hash] ^ [_text hash];
}








@end
