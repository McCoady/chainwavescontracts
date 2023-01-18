// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ChainWavesGenerator.sol";

import "forge-std/Test.sol";

contract ContractTest is Test {
    ChainWavesGenerator cwg;

    function setUp() public {
        cwg = new ChainWavesGenerator();
    }

    function testBuildLine() public view {
        string memory result = cwg.buildLine("gm;)'", 13, 1, 2);
        console.logString(result);
    }

    function testBuildEightLines() public view {
        string memory result = cwg.buildXLines("gm;)'", 13, 5);
        console.logString(result);
    }

    function testBuildSVG() public view {
        string memory result = cwg.buildSVG(0, "000000");
        console.logString(result);
    }

    function testbuildTraits() public view {
        ChainWavesGenerator.Traits memory result = cwg.buildTraits("012500");
        console.log(result.palette[0]);
        console.log(result.noise);
        console.log(result.charSet);
        //assertEq(result, 3);
    }
}
