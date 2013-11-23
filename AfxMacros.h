//
//  AfxMacros.h
//  FCOM
//
//  Created by Shen Slavik on 1/24/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#define _L(x) (NSLocalizedString(x,@""))
#define _F(fmt,...) ([NSString stringWithFormat:fmt, ##__VA_ARGS__] )
#define _FL(fmt,...) ([NSString stringWithFormat:NSLocalizedString(fmt,@""), ##__VA_ARGS__] )
#define _I(x) ([NSImage imageNamed:x])
#define _U(x) ([NSURL URLWithString:x])

#define ALog(...) NSLog(__VA_ARGS__)

#if DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif

#define BOOL2STR(x) ( x ? @"YES" : @"NO" )

#define IS_SIZE_CHANGED(p,n) (ABS(p.width-n.width)>1||ABS(p.height-n.height)>1)
#define IS_POSITION_CHANGED(p,n) (ABS(p.x-n.x)>1||ABS(p.y-n.y)>1)

#define IS_DIFFERENT_FRAME(p,n) (IS_SIZE_CHANGED(p.size,n.size)||IS_POSITION_CHANGED(p.origin,n.origin))

#if __has_feature(objc_arc)
#define SRELEASE(x) { x = nil; }
#else
#define SRELEASE(x) { [x release]; x = nil; }
#endif

#define CGCurrentContext ([[NSGraphicsContext currentContext] graphicsPort])
