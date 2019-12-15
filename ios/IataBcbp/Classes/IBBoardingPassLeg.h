/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

@class IBBoardingPassSecurityData;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPassLeg : NSObject <NSCoding, NSCopying>

/**
 @see IBBoardingPass
 */
+ (_Nullable instancetype)new NS_UNAVAILABLE;

/**
 @see IBBoardingPass
 */
- (_Nullable instancetype)init NS_UNAVAILABLE;

/**
 @return YES if the receiver is logically equal to leg, in both contents and reference date.
 @see -[IBBoardingPass scannedAt]
 */
- (BOOL)isEqualToBoardingPassLeg:(IBBoardingPassLeg *)leg;

#pragma mark - Required Fields

/**
 The reference date on which the boarding pass was scanned.
 @note This does not affect equality or hash, however it does affect date-type values that do.
 */
@property (nonatomic, strong, readonly) NSDate *scannedAt;

#pragma mark - Optional Fields

@end

NS_ASSUME_NONNULL_END
