//
//  NSDate+Bcbp.h
//  IataBcbp
//
//  Created by Martin Mroz on 8/19/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (_Nullable instancetype)IB_dateWithFourDigitJulianString:(NSString *_Nonnull)string onOrBefore:(NSDate *_Nonnull)date;

/**
 Constructs an instance of the receiver from a three-digit Julian string.
 The 3-digit number represents the day of the year beginning with '0'.
 The date is calculated as being before the specified date.
 @param string The three-digit Julian date string.
 @param date The on-or-before date used when calculating the Gregorian date.
 @return nil if a date could not be constructed.
 */
+ (_Nullable instancetype)IB_dateWithThreeDigitJulianString:(NSString *_Nonnull)string onOrBefore:(NSDate *_Nonnull)date;

@end
