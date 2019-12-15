/*
 * Copyright (C) 2019 Martin Mroz
 *
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE file for details.
 */

#import "IBBoardingPass.h"

#import "IBBcbp.h"
#import "IBBoardingPassSecurityData.h"
#import "IBBoardingPassSecurityData_Private.h"
#import "NSDate+Bcbp.h"

@implementation IBBoardingPass

// MARK: - Class Methods

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString * _Nonnull)passString;
{
    NSParameterAssert(passString != nil);
    if (passString.length == 0) {
        return nil;
    }

    return [self boardingPassWithBcbpString:passString scannedAt:[NSDate date]];
}

+ (_Nullable instancetype)boardingPassWithBcbpString:(NSString * _Nonnull)passString scannedAt:(NSDate * _Nonnull)date;
{
    NSParameterAssert(passString != nil);
    NSParameterAssert(date != nil);
    if (passString.length == 0 || date == nil) {
        return nil;
    }

    IBBcbp *const bcbp = [IBBcbp bcbpWithString:passString];
    if (!bcbp) {
        return nil;
    }

    return [self boardingPassWithBcbp:bcbp scannedAt:date];
}

+ (_Nullable instancetype)boardingPassWithBcbp:(IBBcbp * _Nonnull)bcbp scannedAt:(NSDate * _Nonnull)date;
{
    NSParameterAssert(bcbp != NULL);
    NSParameterAssert(date != nil);
    if (bcbp == NULL || date == nil) {
        return nil;
    }

    // Mandatory top-level fields.
    NSString * const passengerName =
        [bcbp fieldWithId:BCBP_FIELD_ID_PASSENGER_NAME];
    NSString * const electronicTicketIndicatorValue =
        [bcbp fieldWithId:BCBP_FIELD_ID_ELECTRONIC_TICKET_INDICATOR];
    if (passengerName.length == 0 || electronicTicketIndicatorValue.length != 1) {
        return nil;
    }

    // Optional top-level fields.
    NSDate * const dateOfIssueOfBoardingPass = ^ NSDate * _Nullable {
        NSString * const julianRepresentation =
            [bcbp fieldWithId:BCBP_FIELD_ID_DATE_OF_ISSUE_OF_BOARDING_PASS];
        if (julianRepresentation.length > 0) {
            return [NSDate IB_dateWithFourDigitJulianString:julianRepresentation onOrBefore:date];
        } else {
            return nil;
        }
    }();

    // Optional, nested security data structure.
    IBBoardingPassSecurityData * const securityData = [IBBoardingPassSecurityData securityDataWithBcbp:bcbp];

    return [[IBBoardingPass alloc] initWithPassengerName:passengerName
                               electronicTicketIndicator:[electronicTicketIndicatorValue characterAtIndex:0]
                               dateOfIssueOfBoardingPass:dateOfIssueOfBoardingPass
                                            securityData:securityData
                                               scannedAt:date];
}

// MARK: - Initialization

- (_Nullable instancetype)init;
{
    [NSException raise:NSInternalInconsistencyException
            format:@"%s is not a supported initializer", __PRETTY_FUNCTION__];

    return nil;
}

- (_Nullable instancetype)initWithPassengerName:(NSString *)passengerName
                      electronicTicketIndicator:(unichar)electronicTicketIndicator
                      dateOfIssueOfBoardingPass:(NSDate * _Nullable)dateOfIssueOfBoardingPass
                                   securityData:(IBBoardingPassSecurityData *)securityData
                                      scannedAt:(NSDate *)date;
{
    NSParameterAssert(passengerName.length > 0);
    NSParameterAssert(securityData != nil);
    NSParameterAssert(date != nil);
    if (passengerName.length == 0 ||
        securityData == nil ||
        date == nil) {
        return nil;
    }

    self = [super init];
    if (!self) {
        return nil;
    }

    _passengerName = [passengerName copy];
    _electronicTicketIndicator = electronicTicketIndicator;
    _dateOfIssueOfBoardingPass = dateOfIssueOfBoardingPass;
    _securityData = securityData;
    _scannedAt = date;

    return self;
}

// MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    return [self initWithPassengerName:[coder decodeObjectOfClass:[NSString class] forKey:@"passengerName"]
             electronicTicketIndicator:[coder decodeInt64ForKey:@"electronicTicketIndicator"]
             dateOfIssueOfBoardingPass:[coder decodeObjectOfClass:[NSDate class] forKey:@"dateOfIssueOfBoardingPass"]
                          securityData:[coder decodeObjectOfClass:[IBBoardingPassSecurityData class] forKey:@"securityData"]
                             scannedAt:[coder decodeObjectOfClass:[NSDate class] forKey:@"scannedAt"]];
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeObject:self.passengerName
                 forKey:@"passengerName"];
    [coder encodeInt64:self.electronicTicketIndicator
                forKey:@"electronicTicketIndicator"];
    [coder encodeObject:self.dateOfIssueOfBoardingPass
                 forKey:@"dateOfIssueOfBoardingPass"];
    [coder encodeObject:self.securityData
                 forKey:@"securityData"];
    [coder encodeObject:self.scannedAt
                 forKey:@"scannedAt"];
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return self;
}

// MARK: - NSObject

- (NSUInteger)hash;
{
    return (self.passengerName.hash ^
            self.electronicTicketIndicator ^
            self.dateOfIssueOfBoardingPass.hash ^
            self.securityData.hash);
}

- (NSString *)debugDescription;
{
    return [NSString stringWithFormat:@"<%@:%p with %d legs>",
        NSStringFromClass(self.class),
        (void *)self,
        0
    ];
}

- (BOOL)isEqual:(id _Nullable)object;
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[IBBoardingPass class]]) {
        return NO;
    }
    
    return [self isEqualToBoardingPass:(IBBoardingPass *)object];
}

// MARK: - Public Methods

- (BOOL)isEqualToBoardingPass:(IBBoardingPass *)boardingPass;
{
    NSParameterAssert(boardingPass != nil);
    if (boardingPass == nil) {
        return NO;
    }

    BOOL const hasEqualPassengerName =
        (self.passengerName == boardingPass.passengerName) ||
        [self.passengerName isEqualToString:boardingPass.passengerName];
    BOOL const hasEqualElectronicTicketIndicator =
        (self.electronicTicketIndicator == boardingPass.electronicTicketIndicator);
    BOOL const hasEqualDateOfIssueOfBoardingPass =
        (self.dateOfIssueOfBoardingPass == boardingPass.dateOfIssueOfBoardingPass) ||
        ([self.dateOfIssueOfBoardingPass compare:boardingPass.dateOfIssueOfBoardingPass] == NSOrderedSame);
    BOOL const hasEqualSecurityData =
        (self.securityData == boardingPass.securityData) ||
        [self.securityData isEqualToBoardingPassSecurityData:boardingPass.securityData];

    return (hasEqualPassengerName &&
            hasEqualElectronicTicketIndicator &&
            hasEqualDateOfIssueOfBoardingPass &&
            hasEqualSecurityData);
}

@end
