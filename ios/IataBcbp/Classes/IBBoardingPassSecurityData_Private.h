/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

@class IBBcbp;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPassSecurityData ()

/**
 Creates a new instance of the receiver with the specified Bcbp instance.
 */
+ (instancetype)securityDataWithBcbp:(IBBcbp *)bcbp;

/**
 @return A new instance of the receiver with all fields populated.
 */
- (instancetype)initWithTypeOfSecurityData:(NSString *_Nullable)typeOfSecurityData
                              securityData:(NSString *_Nullable)securityData NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
