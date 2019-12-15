/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import "NSDate+Bcbp.h"

#import "NSString+Bcbp.h"

@implementation NSDate (Bcbp)

+ (instancetype)IB_dateWithFourDigitJulianString:(NSString *)string onOrBefore:(NSDate *)date;
{
    NSParameterAssert(string != nil);
    NSParameterAssert(date != nil);

    if (!string.isEntirelyDecimalDigits || string.length != 4) {
        return nil;
    }

    // Decode the year digit and the day from the four-digit Julian coded string.
    NSUInteger const encodedValue = (NSUInteger const)string.integerValue;
    NSUInteger const day = encodedValue % 1000;
    NSUInteger const yearDigit = (encodedValue / 1000) % 10;
    
    static NSCalendar *gregorianCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    // The julian date is calculated as being before the specified date.
    NSInteger const beforeDateYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:date];
    
    // Attempt to compute the date by putting the year in the current decade lexically.
    // For instance:
    //   in 2018 the year date '9' would be 2019.
    //   in 2018 the year date '5' would be 2015.
    NSDateComponents *const components = [NSDateComponents new];
    components.year = ((beforeDateYear / 10) * 10) + yearDigit;
    components.day = day;
    
    // Reify the date in the current decade and return it if it is before the reference date.
    NSDate *const dateInCurrentDecade = [gregorianCalendar dateFromComponents:components];
    if ([date compare:dateInCurrentDecade] != NSOrderedAscending) {
        return dateInCurrentDecade;
    }
    
    // Move the date back into the previous decade.
    components.year = components.year - 10;
    return [gregorianCalendar dateFromComponents:components];
}

+ (instancetype)IB_dateWithThreeDigitJulianString:(NSString *)string onOrBefore:(NSDate *)date;
{
    NSParameterAssert(string != nil);
    NSParameterAssert(date != nil);
    
    if (!string.isEntirelyDecimalDigits || string.length != 3) {
        return nil;
    }
    
    static NSCalendar *gregorianCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    NSInteger const beforeDateYear = [gregorianCalendar component:NSCalendarUnitYear fromDate:date];
    NSUInteger const day = (NSUInteger const)string.integerValue;
    
    // Attempt to compute the date by referencing the year of the before-date.
    NSDateComponents *const components = [NSDateComponents new];
    components.year = beforeDateYear;
    components.day = day;
    
    // Reify the date in the current year and return it if it is before the reference date.
    NSDate *const dateInCurrentDecade = [gregorianCalendar dateFromComponents:components];
    if ([date compare:dateInCurrentDecade] != NSOrderedAscending) {
        return dateInCurrentDecade;
    }
    
    // Move the date back into the previous year.
    components.year = components.year - 1;
    return [gregorianCalendar dateFromComponents:components];
}

@end
