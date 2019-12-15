/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import <Foundation/Foundation.h>

@class IBBoardingPassSecurityData;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPass : NSObject <NSCoding, NSCopying>

/**
 @param passString An IATA BCBP type-M version 2-6 encoded, inclusive, boarding pass string.
 @param date A reference date to use when interpreting Julian date codes.
 @return A new instance of the receiver by parsing the passString or nil.
 */
+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *)passString scannedAt:(NSDate *)date;

/**
 Convenience constructor for a boarding pass with BCBP string assuming the pass was scanned now.
 @param passString An IATA BCBP type-M version 2-6 encoded, inclusive, boarding pass string.
 @return A new instance of the receiver by parsing the passString or nil.
 */
+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString *)passString;

/**
 @see +boardingPassWithBcbpString:
 */
+ (_Nullable instancetype)new NS_UNAVAILABLE;

/**
 @see +boardingPassWithBcbpString:
 */
- (_Nullable instancetype)init NS_UNAVAILABLE;

/**
 @return YES if the receiver is logically equal to boardingPass, in both contents and reference date.
 @see -[IBBoardingPass scannedAt]
 */
- (BOOL)isEqualToBoardingPass:(IBBoardingPass *)boardingPass;

#pragma mark - Required Fields

/**
 The reference date on which the boarding pass was scanned.
 @note This does not affect equality or hash, however it does affect date-type values that do.
 */
@property (nonatomic, strong, readonly) NSDate *scannedAt;

/**
 The name of the passenger. Up to 20 characters, left-aligned, space padded.
 The format is LAST_NAME/FIRST_NAME[TITLE]. There is no separator between
 the first name and the title, and no indication a title is present.
 Certain names have characters which cannot be translated and
 special handling may be required.
 Spaces indicate the field is not set.
 As a required field, this cannot be nil.
 */
@property (nonatomic, copy, readonly) NSString *passengerName;

/**
 Used to differentiate between an electronic ticket ('E') and another type of travel document.
 Values are defined in Resolution 792.
 A space indicates the field is not set.
 */
@property (nonatomic, assign, readonly) unichar electronicTicketIndicator;

#pragma mark - Optional Fields

/**
 Optionally the 4-digit Julian date representing when the boarding pass was issued.
 The first digit is the last digit of the year and the next three represent the number
 of days elapsed. For example: "6001" represnts January 1, 2016.
 "6366" represaents December 31, 2016 (a leap year).
 Spaces indicate the field is not set.
 */
@property (nonatomic, copy, readonly, nullable) NSDate *dateOfIssueOfBoardingPass;

/**
 Indicates the version number of the BCBP object.
 Values are defined in Resolution 792.
 nil indicates the value was not specified in the boarding pass.
 A space literal indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *versionNumber;

/**
 This describes the passenger.
 Values are defined in Resolution 792.
 nil indicates the value was not specified in the boarding pass.
 A space literal indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *passengerDescription;

/**
 This field reflects channel in which the customer initiated check-in.
 Values are defined in Resolution 792 Attachment C.
 nil indicates the value was not specified in the boarding pass.
 A space literal indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sourceOfCheckIn;

/**
 This field reflects channel which issued the boarding pass.
 Values are defined in Resolution 792.
 nil indicates the value was not specified in the boarding pass.
 A space literal indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sourceOfBoardingPassIssuance;

/**
 The type of the document, 'B' indicating a boarding pass.
 Values are defined in Resolution 792.
 nil indicates the value was not specified in the boarding pass.
 A space literal indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *documentType;

/**
 Airline code of the boarding pass issuer.
 Two-character and three-letter IATA carrier designators
 are permitted and the string is left-justified and space padded.
 nil indicates the value was not specified in the boarding pass.
 A string composed entirely of space literals indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly, nullable) NSString *airlineDesignatorOfBoardingPassIssuer;

#pragma mark - Nested Structures

/**
 An array of up to three non-sequential baggage tag license plate number ranges.
 Each allows carriers to populate baggage tag numbers and the number
 of consecutive bags. This 13-character fiels is divided into:
   0: '0' for interline tag, '1' for fall-back tag, '2' for interline rush tag.
   2... 4: carrier numeric code.
   5...10: carrier initial tag number with leading zeroes.
   11...13: number of consecutive bags (up to 999).
 For each value, nil indicates the value was not specified in the boarding pass.
 A string composed entirely of space literals indicates the field existed in the boarding pass but was not set.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *allBaggageTagLicensePlateNumbers;

/**
 Security data section of the boarding pass.
 */
@property (nonatomic, strong, readonly) IBBoardingPassSecurityData *securityData;

@end

NS_ASSUME_NONNULL_END
