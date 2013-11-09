//
//  MyDocument+JS.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/3/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "MyDocument.h"

@interface MyDocument (JS)

- (void)loadJSContext;
- (void)releaseJSContext;

- (void)evalScript:(NSString*)script;

@end
