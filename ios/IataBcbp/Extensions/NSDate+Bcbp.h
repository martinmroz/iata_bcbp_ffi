/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Bcbp)

/**
 Constructs an instance of the receiver from a four-digit Julian string.
 The first digit represents the last digit of the year.
 The next three digits represent the day of the year beginning with '1'.
 The date is calculated as being before the specified date.
 @param string The four-digit Julian date string.
 @param date The on-or-before date used when calculating the Gregorian date.
 @return nil if a date could not be constructed.
 */
+ (_Nullable instancetype)IB_dateWithFourDigitJulianString:(NSString *)string onOrBefore:(NSDate *)date;

/**
 Constructs an instance of the receiver from a three-digit Julian string.
 The 3-digit number represents the day of the year beginning with '0'.
 The date is calculated as being before the specified date.
 @param string The three-digit Julian date string.
 @param date The on-or-before date used when calculating the Gregorian date.
 @return nil if a date could not be constructed.
 */
+ (_Nullable instancetype)IB_dateWithThreeDigitJulianString:(NSString *)string onOrBefore:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
