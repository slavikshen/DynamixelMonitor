//
//  FileDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DocumentNeedWindowNotification @"TSDocumentNeedWindowNotification"

@interface FileDocument : NSDocument

-(NSViewController *)newPrimaryViewController;

@end
