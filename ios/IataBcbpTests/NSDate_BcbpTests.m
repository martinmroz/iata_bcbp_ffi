/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <XCTest/XCTest.h>

#import "NSDate+Bcbp.h"

@interface NSDate_BcbpTests : XCTestCase
@end

@implementation NSDate_BcbpTests

// MARK: - Tests - Four-digit Julian Strings

- (void)test_dateWithFourDigitJulianStringBefore_throwsOnInvalidInputs;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([NSDate IB_dateWithFourDigitJulianString:nil onOrBefore:[NSDate date]]);
    XCTAssertThrows([NSDate IB_dateWithFourDigitJulianString:@"" onOrBefore:nil]);
    XCTAssertThrows([NSDate IB_dateWithFourDigitJulianString:nil onOrBefore:nil]);
#pragma clang diagnostic pop
}

- (void)test_dateWithFourDigitJulianStringBefore_returnsNilOnInvalidLengths;
{
    XCTAssertNil([NSDate IB_dateWithFourDigitJulianString:@"" onOrBefore:[NSDate date]]);
    XCTAssertNil([NSDate IB_dateWithFourDigitJulianString:@"123" onOrBefore:[NSDate date]]);
    XCTAssertNil([NSDate IB_dateWithFourDigitJulianString:@"12345" onOrBefore:[NSDate date]]);
}

- (void)test_dateWithFourDigitJulianStringBefore_earlierInReferenceYear;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:2 day:1];
    NSDate *const          date = [NSDate IB_dateWithFourDigitJulianString:@"8001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

- (void)test_dateWithFourDigitJulianStringBefore_sameDayAsReference;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const          date = [NSDate IB_dateWithFourDigitJulianString:@"8001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

- (void)test_dateWithFourDigitJulianStringBefore_inYearBeforeReference;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2007 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const          date = [NSDate IB_dateWithFourDigitJulianString:@"7001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

- (void)test_dateWithFourDigitJulianStringBefore_inDecadeBeforeReference;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:1999 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const          date = [NSDate IB_dateWithFourDigitJulianString:@"9001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

// MARK: - Tests - Three-digit Julian Strings

- (void)test_dateWithThreeDigitJulianStringBefore_throwsOnInvalidInputs;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([NSDate IB_dateWithThreeDigitJulianString:nil onOrBefore:[NSDate date]]);
    XCTAssertThrows([NSDate IB_dateWithThreeDigitJulianString:@"" onOrBefore:nil]);
    XCTAssertThrows([NSDate IB_dateWithThreeDigitJulianString:nil onOrBefore:nil]);
#pragma clang diagnostic pop
}

- (void)test_dateWithThreeDigitJulianStringBefore_returnsNilOnInvalidLengths;
{
    XCTAssertNil([NSDate IB_dateWithThreeDigitJulianString:@"" onOrBefore:[NSDate date]]);
    XCTAssertNil([NSDate IB_dateWithThreeDigitJulianString:@"12" onOrBefore:[NSDate date]]);
    XCTAssertNil([NSDate IB_dateWithThreeDigitJulianString:@"1234" onOrBefore:[NSDate date]]);
}

- (void)test_dateWithThreeDigitJulianStringBefore_earlierInReferenceYear;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:2 day:1];
    NSDate *const          date = [NSDate IB_dateWithThreeDigitJulianString:@"001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

- (void)test_dateWithThreeDigitJulianStringBefore_sameDayAsReference;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const          date = [NSDate IB_dateWithThreeDigitJulianString:@"001" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

- (void)test_dateWithThreeDigitJulianStringBefore_inYearBeforeReference;
{
    NSDate *const  expectedDate = [NSDate_BcbpTests dateWithYear:2007 month:1 day:2];
    NSDate *const referenceDate = [NSDate_BcbpTests dateWithYear:2008 month:1 day:1];
    NSDate *const          date = [NSDate IB_dateWithThreeDigitJulianString:@"002" onOrBefore:referenceDate];
    XCTAssertEqualObjects (date , expectedDate);
}

// MARK: - Helper Methods

+ (NSDate * _Nonnull)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
{
    NSCalendar *const gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *const components = [NSDateComponents new];
    components.year = year;
    components.month = month;
    components.day = day;
    return [gregorian dateFromComponents:components];
}

@end
