//
//  Sundown.h
//  Sundown
//
//  Created by Jakub Hampl on 15.10.12.
//  Copyright (c) 2012 Jakub Hampl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sundown : NSObject

+ (NSString *)convertMD: (NSString *)str withOptions: (int)opts;
+ (void)asyncConvertMD: (NSString *)str withOptions: (int)opts whenDone:(void(^)(NSString*))cb;
@end
