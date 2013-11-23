//
//  FileSystemItem.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/15/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectItem : NSObject

@property(nonatomic,readonly,copy) NSString* relativePath;
@property(nonatomic,readonly) NSString* fullPath;
@property(nonatomic,readonly,strong) ProjectItem* parent;
@property(nonatomic,readonly) NSString* displayName;
@property(nonatomic,readonly,assign) BOOL isDir;
@property(nonatomic,readonly,assign) BOOL isValid;
@property(nonatomic,readonly,strong) NSArray* children;
@property(nonatomic,strong) NSDocument* document;

- (id)initWithProjectURL:(NSURL*)url;

@end
