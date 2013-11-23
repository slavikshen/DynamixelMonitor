//
//  CodeDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "FileDocument.h"
#import <MGSFragaria/MGSFragaria.h>

@interface CodeDocument : FileDocument

@property(nonatomic,strong) MGSFragaria* fragaria;

@end
