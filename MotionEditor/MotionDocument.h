//
//  MotionDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/24/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "FileDocument.h"

APPKIT_EXTERN NSString* const kMotionDocumentProperty_Motions;

@interface Motion : NSObject<NSCoding>

@property(nonatomic,copy) NSString* name;
@property(nonatomic,assign) NSInteger speed;
@property(nonatomic,copy) NSArray* motions;

@end

@interface MotionDocument : FileDocument

@property(nonatomic,assign) NSInteger version;
@property(nonatomic,strong) NSMutableArray* motions;

- (void)insertObject:(Motion*)motion inMotionsAtIndex:(NSUInteger)index;
- (void)appendMotion:(Motion*)motion;
- (void)removeObjectFromMotionsAtIndex:(NSUInteger)index;
- (void)replaceObjectInMotionsAtIndex:(NSUInteger)index withObject:(Motion*)motion;

@end
