//
//  CodeDocument.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "CodeDocument.h"

@interface CodeDocument()

@property(nonatomic,copy) NSString* temp;

@end

@implementation CodeDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)setFragaria:(MGSFragaria *)fragaria {
    
    _fragaria = fragaria;
    
    if( _fragaria ) {
        // define our syntax definition
        [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
        
        [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
        [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
        
        // set text
        if( self.temp.length ) {
            [fragaria setString:self.temp];
            self.temp = nil;
        } else {
//            NSURL* emptyFileURL = [[NSBundle mainBundle] URLForResource:@"Empty" withExtension:@"djs"];
//            NSError* err = nil;
//            NSString* defaultContent = [NSString stringWithContentsOfURL:emptyFileURL
//                                                                encoding:NSUTF8StringEncoding
//                                                                   error:&err];
//            [fragaria setString:defaultContent];
        }
    }
    
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    DLog(@"save code source");
    
    NSString* script = nil;
    if( self.fragaria ) {
        script = [self.fragaria string];
    } else {
        script = self.temp;
    }
    
    NSData* data = [script dataUsingEncoding:NSUTF8StringEncoding];
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    DLog(@"read code source");
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSString* script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if( self.fragaria ) {
        [self.fragaria setString:script];
    } else {
        self.temp = script;
    }
    
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return YES;
}

@end
