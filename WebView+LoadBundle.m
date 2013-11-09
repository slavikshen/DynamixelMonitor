//
//  WebView+LoadBundle.m
//  FCOM
//
//  Created by Shen Slavik on 7/25/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import "WebView+LoadBundle.h"

@implementation WebView (LoadBundle)

- (void)loadRemoteURL:(NSURL*)url {
    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadHTMLInBundle:(NSString *)name {
    NSURL *tempURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"html"];
    [self stopLoading:nil];
    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:tempURL]];
}

@end
