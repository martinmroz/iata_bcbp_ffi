//
//  IBBoardingPass.h
//  IataBcbp
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBBoardingPassSecurityData;

NS_ASSUME_NONNULL_BEGIN

@interface IBBoardingPass : NSObject

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

/**
 The reference date on which the boarding pass was scanned.
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

/**
 Optionally the 4-digit Julian date representing when the boarding pass was issued.
 The first digit is the last digit of the year and the next three represent the number
 of days elapsed. For example: "6001" represnts January 1, 2016.
 "6366" represaents December 31, 2016 (a leap year).
 Spaces indicate the field is not set.
 */
@property (nonatomic, copy, readonly, nullable) NSDate *dateOfIssueOfBoardingPass;

/**
 Security data section of the boarding pass.
 */
@property (nonatomic, strong, readonly) IBBoardingPassSecurityData *securityData;

@end

NS_ASSUME_NONNULL_END
