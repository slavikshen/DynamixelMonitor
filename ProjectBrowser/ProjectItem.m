//
//  FileSystemItem.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/15/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "ProjectItem.h"

@interface ProjectItem()

@property(nonatomic,readwrite,copy) NSString* relativePath;
@property(nonatomic,readwrite,strong) ProjectItem* parent;
@property(nonatomic,readwrite,strong) NSArray* children;
@property(nonatomic,readwrite,assign) BOOL isDir;
@property(nonatomic,readwrite,assign) BOOL isValid;

@end

@implementation ProjectItem

@dynamic fullPath, displayName;

- (id)initWithProjectURL:(NSURL*)url {
 
    self = [super init];
    if (self) {
        NSString* relativePath = [[url path] stringByDeletingLastPathComponent];
        self.relativePath = relativePath;
        // load children anyway
        [self children];
    }
    
    return self;
    
}

- (id)initWithPath:(NSString *)path parent:(ProjectItem *)parentItem {
    self = [super init];
    if (self) {
        self.relativePath = [path lastPathComponent];
        self.parent = parentItem;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid;
        valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
        
        self.isValid = valid;
        self.isDir = isDir;
    }
    return self;
}


// Creates, caches, and returns the array of children
// Loads children incrementally
- (NSArray *)children {
    
    if (_children == nil) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid;
        
        valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];

        self.isValid = valid;
        self.isDir = isDir;

        if (valid && isDir) {
            NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
            
            NSUInteger numChildren, i;
            
            numChildren = [array count];
            NSMutableArray* children = [[NSMutableArray alloc] initWithCapacity:numChildren];
            
            for (i = 0; i < numChildren; i++)
            {
                NSString* path = [array objectAtIndex:i];
                NSString* fileName = [path lastPathComponent];
                if( [self _shouldAcceptFile:fileName] ) {
                    ProjectItem *newChild = [[ProjectItem alloc]
                                             initWithPath:[array objectAtIndex:i] parent:self];
                    [children addObject:newChild];
                }
            }
            
            self.children = children;
        }
    }
    return _children;
}

- (BOOL)_shouldAcceptFile:(NSString*)fileName {

    NSUInteger dotPost = [fileName rangeOfString:@"."].location;
    if( 0 == dotPost ) {
        return NO; // hidden file
    }
    if( NSNotFound == dotPost ) {
        return YES;
    }
    if( [fileName hasSuffix:@".js"] || [fileName hasSuffix:@".dm"] ) {
        return YES;
    }
    
    return NO;
}


- (NSString *)fullPath {
    // If no parent, return our own relative path
    if ( _parent == nil) {
        return _relativePath;
    }
    
    // recurse up the hierarchy, prepending each parent’s path
    return [[_parent fullPath] stringByAppendingPathComponent:_relativePath];
}

- (NSString*)displayName {
 
    if( _parent == nil ) {
        return [_relativePath lastPathComponent];
    }
    
    return self.relativePath;
    
}

- (ProjectItem *)childAtIndex:(NSUInteger)n {
    return [[self children] objectAtIndex:n];
}


- (NSInteger)numberOfChildren {
    if( self.isDir ) {
        return self.children.count;
    }
    return -1;
}

@end
