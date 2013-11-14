//
//  ScriptDocument.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/11/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "ScriptDocument.h"
#import "Dynamixel.h"
#import <MGSFragaria/MGSFragaria.h>

@interface ScriptDocument()

@property(nonatomic,strong) MGSFragaria* fragaria;
@property(nonatomic,copy) NSString* temp;

@end

@implementation ScriptDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }

    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"ScriptDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    // create an instance
	MGSFragaria* fragaria = [[MGSFragaria alloc] init];
	
	[fragaria setObject:self forKey:MGSFODelegate];
	
	// define our syntax definition
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
	// embed editor in editView
	[fragaria embedInView:self.editorContainer];
	
    //
	// assign user defaults.
	// a number of properties are derived from the user defaults system rather than the doc spec.
	//
	// see MGSFragariaPreferences.h for details
	//
    if (NO) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsLineWrapNewDocuments];
    }
	
	// define initial document configuration
	//
	// see MGSFragaria.h for details
	//
    if (YES) {
        [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
        [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
    }
    
    // set text
    if( self.temp.length ) {
        [fragaria setString:self.temp];
        self.temp = nil;
    } else {
        NSURL* emptyFileURL = [[NSBundle mainBundle] URLForResource:@"Empty" withExtension:@"djs"];
        NSError* err = nil;
        NSString* defaultContent = [NSString stringWithContentsOfURL:emptyFileURL
                                                            encoding:NSUTF8StringEncoding
                                                               error:&err];
        
        [fragaria setString:defaultContent];
    }
	
    self.fragaria = fragaria;
    
    self.jsWrapper.dynamixel = [Dynamixel sharedInstance];
	// access the NSTextView
//	NSTextView *textView = [fragaria objectForKey:ro_MGSFOTextView];
    
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
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

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (IBAction)runOrStop:(id)sender {
    
    if( [self isRunning] ) {
        self.running = NO;
        [self.jsWrapper stopScript];
    } else {
        self.running = YES;
        
        self.logView.string = @"";
        NSString* script = [self.fragaria string];
        [self.jsWrapper evalScript:script];
    }
    
}

- (void)setRunning:(BOOL)running {
 
    if( _running != running ) {
     
        _running = running;
        
        NSToolbarItem* run = self.runToolbarItem;
        
        if( _running ) {
            
            NSSplitView* splitView = self.splitView;
            CGFloat H = splitView.bounds.size.height;
            
            CGFloat logH = floorf(H*0.64f);
            
            [splitView setPosition:logH ofDividerAtIndex:0];
            
            run.image = [NSImage imageNamed:@"Stop_Template"];
            run.label = @"Stop";

        } else {
         
            run.image = [NSImage imageNamed:@"Play_Template"];
            run.label = @"Run";
            
        }
        
    }
    
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
 
    if( [subview isKindOfClass:[NSScrollView class]] ) {
        return YES;
    }
    
    return NO;
    
}

- (BOOL)splitView:(NSSplitView *)splitView
        shouldCollapseSubview:(NSView *)subview
        forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    
    if( [subview isKindOfClass:[NSScrollView class]] ) {
        return YES;
    }
    
    return NO;
}

@end
