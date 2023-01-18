// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ChainWaves.sol";

import "forge-std/Test.sol";

contract ChainWavesTest is Test {
    ChainWaves chainWaves;

    function setUp() public {
        chainWaves = new ChainWaves();
        startHoax(0x9ea04B953640223dbb8098ee89C28E7a3B448858);
        setUpPalettes();
        setUpNoise();
        setUpSpeed();
        setUpCharSet();
        setUpDetail();
        setUpCols();
        chainWaves.flipMint();
    }

    function setUpPalettes() public {
        ChainWaves.Trait[] memory palettes = new ChainWaves.Trait[](8);
        palettes[0] = ChainWaves.Trait("Lava", "Palette");
        palettes[1] = ChainWaves.Trait("Flamingo", "Palette");
        palettes[2] = ChainWaves.Trait("Rioja", "Palette");
        palettes[3] = ChainWaves.Trait("Alien", "Palette");
        palettes[4] = ChainWaves.Trait("Samba", "Palette");
        palettes[5] = ChainWaves.Trait("Pepewaves", "Palette");
        palettes[6] = ChainWaves.Trait("Twister", "Palette");
        palettes[7] = ChainWaves.Trait("Purple Rain", "Palette");

        chainWaves.addTraitType(0, palettes);
    }

    function setUpNoise() public {
        ChainWaves.Trait[] memory noise = new ChainWaves.Trait[](8);
        noise[0] = ChainWaves.Trait("Rigid", "Noisiness");
        noise[1] = ChainWaves.Trait("Regular", "Noisiness");
        noise[2] = ChainWaves.Trait("Loose", "Noisiness");
        noise[3] = ChainWaves.Trait("Erratic", "Noisiness");

        chainWaves.addTraitType(1, noise);
    }

    function setUpSpeed() public {
        ChainWaves.Trait[] memory speed = new ChainWaves.Trait[](8);
        speed[0] = ChainWaves.Trait("Tortoise", "Speed");
        speed[1] = ChainWaves.Trait("Regular", "Speed");
        speed[2] = ChainWaves.Trait("Quick", "Speed");
        speed[3] = ChainWaves.Trait("Sonik", "Speed");

        chainWaves.addTraitType(2, speed);
    }

    function setUpCharSet() public {
        ChainWaves.Trait[] memory charSets = new ChainWaves.Trait[](8);
        charSets[0] = ChainWaves.Trait("#83!:", "Char Set");
        charSets[1] = ChainWaves.Trait("@94?;", "Char Set");
        charSets[2] = ChainWaves.Trait("W72a+", "Char Set");
        charSets[3] = ChainWaves.Trait("N$50c", "Char Set");
        charSets[4] = ChainWaves.Trait("0101/", "Char Set");
        charSets[5] = ChainWaves.Trait("gm;)'", "Char Set");

        chainWaves.addTraitType(3, charSets);
    }

    function setUpDetail() public {
        ChainWaves.Trait[] memory detail = new ChainWaves.Trait[](8);
        detail[0] = ChainWaves.Trait("Sharp", "Detail");
        detail[1] = ChainWaves.Trait("Regular", "Detail");
        detail[2] = ChainWaves.Trait("Fuzzy", "Detail");

        chainWaves.addTraitType(4, detail);
    }

    function setUpCols() public {
        ChainWaves.Trait[] memory numCols = new ChainWaves.Trait[](8);
        numCols[0] = ChainWaves.Trait("Two", "# Cols");
        numCols[1] = ChainWaves.Trait("Three", "# Cols");
        numCols[2] = ChainWaves.Trait("Four", "# Cols");
        numCols[3] = ChainWaves.Trait("Five", "# Cols");

        chainWaves.addTraitType(5, numCols);
    }

    function testFailNormieMintTwice() public {
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assertEq(chainWaves.totalSupply(), 1);
        chainWaves.normieMint{value: 0.0256 ether}(1);
    }

    function testFailMintZero() public {
        chainWaves.normieMint(0);
    }

    function testNormieMintOne() public {
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assertEq(chainWaves.totalSupply(), 1);
    }

    function testNormieMintThree() public {
        chainWaves.normieMint{value: 0.0256 ether * 3}(3);
        assertEq(chainWaves.totalSupply(), 3);
    }

    function testFailFreeTwice() public {
        address[] memory mintTo = new address[](1);
        mintTo[0] = makeAddr("Alexstrasza");
        uint256[] memory amount = new uint256[](1);
        amount[0] = 1;
        chainWaves.freeMints(mintTo, amount);
        assertEq(chainWaves.totalSupply(), 1);
        chainWaves.freeMints(mintTo, amount);
    }

    function testFreeMint3x1() public {
        address[] memory mintTo = new address[](3);
        mintTo[0] = makeAddr("Alexstrasza");
        mintTo[1] = makeAddr("Malygos");
        mintTo[2] = makeAddr("Neltharion");
        uint256[] memory amount = new uint256[](3);
        amount[0] = 1;
        amount[1] = 1;
        amount[2] = 1;
        chainWaves.freeMints(mintTo, amount);
        assertEq(chainWaves.totalSupply(), 3);
    }

    function testFreeMint3x3() public {
        address[] memory mintTo = new address[](3);
        mintTo[0] = makeAddr("Alexstrasza");
        mintTo[1] = makeAddr("Malygos");
        mintTo[2] = makeAddr("Neltharion");
        uint256[] memory amount = new uint256[](3);
        amount[0] = 3;
        amount[1] = 3;
        amount[2] = 3;
        chainWaves.freeMints(mintTo, amount);
        assertEq(chainWaves.totalSupply(), 9);
    }

    function testTokenUri() public {
        chainWaves.normieMint{value: 0.0256 ether}(1);
        vm.roll(10);
        string memory uri = chainWaves.tokenURI(0);
        console.logString(uri);
    }

    function testWithdrawl() public {
        address newOwner = makeAddr("Onyxia");
        chainWaves.normieMint{value: 0.0256 ether}(1);
        chainWaves.transferOwnership(newOwner);
        vm.stopPrank();
        assert(newOwner.balance == 0);
        vm.prank(newOwner);
        chainWaves.withdraw();
        assert(newOwner.balance == 0.0256 ether);
    }

    function testMerkllProofMint() public {
        // TODO: change to a valid proof
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        proof[1] = 0x0000000000000000000000000000000000000000000000000000000000000000;

        vm.stopPrank();
        // TODO: change to WL address
        hoax(address(0x0));
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 1);
    }

    function testFailWrongProofMint() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        proof[1] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
    }
}
