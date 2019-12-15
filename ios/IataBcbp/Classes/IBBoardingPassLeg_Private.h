/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

@class IBBcbp;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPassLeg ()

/**
 Creates a new instance of the receiver with the specified Bcbp instance.
 */
+ (instancetype _Nullable)legWithBcbp:(IBBcbp *)bcbp legIndex:(NSInteger)legIndex scannedAt:(NSDate *)date;

/**
 @return A new instance of the receiver with all fields populated.
 */
- (instancetype)initWithScannedAt:(NSDate *)date NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
