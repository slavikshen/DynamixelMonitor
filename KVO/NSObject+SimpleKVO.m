//
//  NSObject+SimpleKVO.m
//  FCOM
//
//  Created by Shen Slavik on 5/22/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import "NSObject+SimpleKVO.h"

@implementation NSObject (SimpleKVO)

- (void)addObserver:(id)observer keys:(NSArray*)keys contexts:(NSArray*)contexts {
    NSUInteger count = keys.count;
    for( NSUInteger i = 0; i < count; i++ ) {
        NSString* key = keys[i];
        void* context = (__bridge void*)contexts[i];
        [self addObserver:observer forKeyPath:key options:0 context:context];
    }
}

- (void)removeObserver:(id)observer keys:(NSArray*)keys contexts:(NSArray*)contexts {
    NSUInteger count = keys.count;
    for( NSUInteger i = 0; i < count; i++ ) {
        NSString* key = keys[i];
        void* context = (__bridge void*)contexts[i];
        [self removeObserver:observer forKeyPath:key context:context];
    }
}

- (void)addObserver:(id)observer constantKeys:(NSArray*)keys {
    [self addObserver:observer keys:keys contexts:keys];
}

- (void)removeObserver:(id)observer constantKeys:(NSArray*)keys {
    [self removeObserver:observer keys:keys contexts:keys];
}

- (void)addObserver:(id)observer constantKey:(NSString*)key options:(NSKeyValueObservingOptions)options {
    [self addObserver:observer forKeyPath:key options:options context:(__bridge void*)key];
}

- (void)removeObserver:(id)observer constantKey:(NSString*)key {
    [self removeObserver:observer forKeyPath:key context:(__bridge void*)key];
}

@end
