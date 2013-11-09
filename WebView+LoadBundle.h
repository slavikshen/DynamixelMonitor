//
//  WebView+LoadBundle.h
//  FCOM
//
//  Created by Shen Slavik on 7/25/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WebView (LoadBundle)

// load a file in bundle with ext hmtl
- (void)loadRemoteURL:(NSURL*)url;
- (void)loadHTMLInBundle:(NSString *)name;

@end
