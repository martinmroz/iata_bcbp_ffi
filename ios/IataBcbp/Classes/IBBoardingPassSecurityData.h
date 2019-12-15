/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPassSecurityData : NSObject <NSCoding>

/**
 @see IBBoardingPass
 */
+ (_Nullable instancetype)new NS_UNAVAILABLE;

/**
 @see IBBoardingPass
 */
- (_Nullable instancetype)init NS_UNAVAILABLE;

/**
 @return YES if the receiver and the `securityData` instance are logically equivalent.
 */
- (BOOL)isEqualToBoardingPassSecurityData:(IBBoardingPassSecurityData *)securityData;

/**
 An optional one-character field indicating the type of the following security data.
 */
@property (nonatomic, copy, readonly, nullable) NSString *typeOfSecurityData;

/**
 An optional field containing boarding pass security data.
 */
@property (nonatomic, copy, readonly, nullable) NSString *securityData;

@end

NS_ASSUME_NONNULL_END
