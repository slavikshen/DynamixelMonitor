//
//  NSObject+SimpleKVO.h
//  FCOM
//
//  Created by Shen Slavik on 5/22/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SimpleKVO)

- (void)addObserver:(id)observer keys:(NSArray*)keys contexts:(NSArray*)contexts;
- (void)removeObserver:(id)observer keys:(NSArray*)keys contexts:(NSArray*)contexts;

- (void)addObserver:(id)observer constantKeys:(NSArray*)keys;
- (void)removeObserver:(id)observer constantKeys:(NSArray*)keys;

- (void)addObserver:(id)observer constantKey:(NSString*)key options:(NSKeyValueObservingOptions)options;
- (void)removeObserver:(id)observer constantKey:(NSString*)key;

@end
