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

@end

NS_ASSUME_NONNULL_END
