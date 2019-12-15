//
//  IBBoardingPassTests.m
//  IataBcbpTests
//
//  Created by Martin Mroz on 8/16/18.
//  Copyright © 2019 Martin Mroz. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IBBoardingPass.h"

@interface IBBoardingPassTests : XCTestCase
@end

@implementation IBBoardingPassTests

- (void)test_boardingPassWithPassString_rejectsInvalidInputs;
{
    // Trivally empty and invalid inputs.
    XCTAssertNil([IBBoardingPass boardingPassWithBcbpString:@""]);
    XCTAssertNil([IBBoardingPass boardingPassWithBcbpString:@"INVALID"]);
    
    // This is a complete and valid Type 'M' boarding pass from the IATA 792B examples, with a trailing '+'.
    NSString *const passWithTrailingData = @"M1DESMARAIS/LUC       EABC123 YULFRAAC 0834 326J001A0025 100^100+";
    XCTAssertNil([IBBoardingPass boardingPassWithBcbpString:passWithTrailingData]);
}

- (void)test_boardingPassWithPassString_acceptsValidInput;
{
    // This is a complete and valid Type 'M' boarding pass from the IATA 792B examples with no security data.
    NSString *const passString = @"M1DESMARAIS/LUC       EABC123 YULFRAAC 0834 326J001A0025 100";
    IBBoardingPass *const pass = [IBBoardingPass boardingPassWithBcbpString:passString];
    XCTAssertNotNil(pass);
    NSLog(@"%@", pass.passengerName);
}

@end
