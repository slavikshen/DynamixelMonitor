//
//  MultiWindowDocumentController.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import "MultiDocDocumentController.h"

const char* const MultiWindowDocumentControllerCloseAllContext = "com.samuelcartwright.MultiWindowDocumentControllerCloseAllContext";

@implementation MultiDocDocumentController {
    BOOL _didCloseAll;
}

-(void)dealloc {
    [super dealloc];
}

#pragma mark NSDocument Delegate

// We want a custom subclass of NSDocumentController to handle document closure.
// The object is instantiated in Window.xib and becomes the application-global document
// controller, overriding NSDocumentController‘s default instance.

- (void)document:(NSDocument *)doc shouldClose:(BOOL)shouldClose  contextInfo:(void  *)contextInfo
{
    if (contextInfo == MultiWindowDocumentControllerCloseAllContext) {
        NSLog(@"in close all. should close: %@",@(shouldClose));
        if (shouldClose) {
            // work on a copy of the window controllers array so that the doc can mutate its own array.
            NSArray* windowCtrls = [doc.windowControllers copy];
            for (NSWindowController* windowCtrl in windowCtrls) {
                if ([windowCtrl respondsToSelector:@selector(removeDocument:)]) {
                    [(id)windowCtrl removeDocument:doc];
                }
            }
            
            [windowCtrls release];
            [doc close];
            [self removeDocument:doc];
        } else {
            _didCloseAll = NO;
        }
    }
}


#pragma mark NSDocumentController

- (void)closeAllDocumentsWithDelegate:(id)delegate didCloseAllSelector:(SEL)didCloseAllSelector contextInfo:(void *)contextInfo
{
    NSLog(@"Closing all documents");
    _didCloseAll = YES;
    for (NSDocument* currentDocument in self.documents) {
        [currentDocument canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:(void*)MultiWindowDocumentControllerCloseAllContext];
    }
    
    objc_msgSend(delegate,didCloseAllSelector,self,_didCloseAll,contextInfo);
}

@end