//
//  CodeViewController.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "CodeViewController.h"
#import "CodeDocument.h"

@interface CodeViewController ()

@property(nonatomic,strong) MGSFragaria* fragaria;

@end

@implementation CodeViewController

- (void)setDocument:(id)document {
    
    CodeDocument* prev = self.document;
    if( prev ) {
        prev.fragaria = nil;
    }
    [super setDocument:document];
    if( self.fragaria ) {
        CodeDocument* doc = self.document;
        doc.fragaria = self.fragaria;
    }
    
}

- (void)awakeFromNib {

    [super awakeFromNib];
    // embed editor in editView
    // create an instance
	MGSFragaria* fragaria = [[MGSFragaria alloc] init];
	[fragaria setObject:self forKey:MGSFODelegate];
	[fragaria embedInView:self.editorContainer];
    self.fragaria = fragaria;
    
    [self.document setFragaria:fragaria];
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
