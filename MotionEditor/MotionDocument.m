//
//  MotionDocument.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/24/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "MotionDocument.h"

NSString* const kMotionDocumentProperty_Version = @"version";
NSString* const kMotionDocumentProperty_Motions = @"motions";

@implementation Motion

- (void)encodeWithCoder:(NSCoder *)aCoder {
 
    NSInteger speed = self.speed;
    NSString* name = self.name;
    NSArray* motions = self.motions;
    
    if( speed ) {
        [aCoder encodeInteger:speed forKey:@"speed"];
    }
    if( name.length ) {
        [aCoder encodeObject:name forKey:@"name"];
    }
    if( motions.count ) {
        [aCoder encodeObject:motions forKey:@"motions"];
    }
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super init];

    NSInteger speed = [aDecoder decodeIntegerForKey:@"speed"];
    NSString* name = [aDecoder decodeObjectForKey:@"name"];
    NSArray* motions = [aDecoder decodeObjectForKey:@"motions"];
    
    self.speed = speed;
    if( name.length ) {
        self.name = name;
    }
    if( motions.count ) {
        self.motions = motions;
    }
    
    return self;
    
}


@end

@implementation MotionDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSNumber* versionNum = @(self.version);
    NSArray* motions = self.motions;
    
    NSDictionary* dict = @{
                           kMotionDocumentProperty_Version: versionNum,
                           kMotionDocumentProperty_Motions: motions
                           };
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    NSDictionary* dict = nil;
    NSNumber* versionNum = nil;
    NSArray* motions = nil;
    @try {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        versionNum = dict[kMotionDocumentProperty_Version];
        motions = dict[kMotionDocumentProperty_Motions];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        self.version = [versionNum integerValue];
        NSMutableArray* buf = [NSMutableArray arrayWithCapacity:32];
        if( motions ) {
            [buf addObjectsFromArray:motions];
        }
        self.motions = buf;
    }
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)insertObject:(Motion*)motion inMotionsAtIndex:(NSUInteger)index {
    
    [_motions insertObject:motion atIndex:index];
    
}

- (void)appendMotion:(Motion*)motion {
    
    NSInteger count = _motions.count;
    [self insertObject:motion inMotionsAtIndex:count];
    
}

- (void)removeObjectFromMotionsAtIndex:(NSUInteger)index {
    
    [_motions removeObjectAtIndex:index];
    
}

- (void)replaceObjectInMotionsAtIndex:(NSUInteger)index withObject:(Motion*)motion {
 
    [_motions replaceObjectAtIndex:index withObject:motion];
    
}


@end
