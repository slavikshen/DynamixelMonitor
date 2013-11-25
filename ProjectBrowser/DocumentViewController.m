//
//  DocumentViewController.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "DocumentViewController.h"

@interface DocumentViewController ()

@end

@implementation DocumentViewController

- (id)init {
 
    NSString* nib = NSStringFromClass([self class]);
    self = [self initWithNibName:nib bundle:nil];
    return self;
    
}

@end
