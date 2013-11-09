//
//  Console.h
//  JSTest
//
//  Created by Slavik on 11/4/13.
//  Copyright (c) 2013 Slavik. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConsoleExport <JSExport>

-(void)log:(NSString*)text;

@end

@interface Console : NSObject<ConsoleExport>

@end
