// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/ChainWaves.sol";
import "../src/ChainWavesErrors.sol";

import "forge-std/Test.sol";

contract ChainWavesTest is Test {
    ChainWaves chainWaves;

    function setUp() public {
        chainWaves = new ChainWaves();
        startHoax(0x888f8AA938dbb18b28bdD111fa4A0D3B8e10C871);
        setUpPalettes();
        setUpNoise();
        setUpSpeed();
        setUpCharSet();
        setUpDetail();
        setUpCols();
        chainWaves.flipMint();
        vm.warp(chainWaves.MINT_START());
    }

    function setUpPalettes() public {
        ChainWaves.Trait[] memory palettes = new ChainWaves.Trait[](9);
        palettes[0] = ChainWaves.Trait("Lava", "Palette");
        palettes[1] = ChainWaves.Trait("Flamingo", "Palette");
        palettes[2] = ChainWaves.Trait("Rioja", "Palette");
        palettes[3] = ChainWaves.Trait("Forest", "Palette");
        palettes[4] = ChainWaves.Trait("Samba", "Palette");
        palettes[5] = ChainWaves.Trait("Pepewaves", "Palette");
        palettes[6] = ChainWaves.Trait("Cow", "Palette");
        palettes[7] = ChainWaves.Trait("Pastelize", "Palette");
        palettes[8] = ChainWaves.Trait("Dank", "Palette");

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

    function testFailMintEarly() public {
        vm.warp(chainWaves.MINT_START() - 1);
        chainWaves.normieMint{value: 0.0256 ether}(1);
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

    function testWithdrawal() public {
        address toad = 0xeFEed35D024CF5B59482Fa4BC594AaeAf694E669;
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assert(toad.balance == 0);

        chainWaves.withdraw();
        assertEq(toad.balance, (0.0256 ether * 83) / 100);
    }

    function testHash() public {
        chainWaves.normieMint{value: 0.0256 ether}(1);
        vm.roll(10);
        string memory hashValue = chainWaves._tokenIdToHash(0);
        vm.stopPrank();
        hoax(address(100));
        chainWaves.normieMint{value: 0.0512 ether}(2);
        vm.roll(10);
        assertEq(chainWaves._tokenIdToHash(0), hashValue);
    }

    function testSnowcrashMint() public {
        bytes32[] memory proof = new bytes32[](8);
        proof[
            0
        ] = 0xe6e7d43627ef26915e465da21a2b7a7dac9303693b04acd43b76064d24cb0023;
        proof[
            1
        ] = 0x39a123a730ca7542702dd494f9fdda13aeb76805d7f6713e8a0a97b0e3fdacc1;
        proof[
            2
        ] = 0x437e46241a0e9868922756c86d716dc7fb28145693614889e49c2e103d4d5b60;
        proof[
            3
        ] = 0x9381564e58e1f0b73a1edcda9469f6c59407e5e7ae1f54bdebf2e00c2be5a23e;
        proof[
            4
        ] = 0xf415bceb3738fb943750f569b226fe96c64ac1b3a8075a4418c08b697c41c683;
        proof[
            5
        ] = 0x16ee7eada7331c3fdd16eef20108f4a329386c20e4951c3e689bb7363072c81f;
        proof[
            6
        ] = 0x33a88c386975fc0b82b5ca060f50614cbbf3b517743921d01f201174d9050261;
        proof[
            7
        ] = 0x70e151d126139930c80411467e82e9b1fc563491007c59704bb1479e2dc3d615;

        vm.stopPrank();
        hoax(0x4533d1F65906368ebfd61259dAee561DF3f3559D);
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 1);
        assertEq(chainWaves.snowcrashReserve(), 119);
    }

    // Currently doesn't work (can inifite mint)
    function testCannotSnowcrashMintTwice() public {
        bytes32[] memory proof = new bytes32[](8);
        proof[
            0
        ] = 0xe6e7d43627ef26915e465da21a2b7a7dac9303693b04acd43b76064d24cb0023;
        proof[
            1
        ] = 0x39a123a730ca7542702dd494f9fdda13aeb76805d7f6713e8a0a97b0e3fdacc1;
        proof[
            2
        ] = 0x437e46241a0e9868922756c86d716dc7fb28145693614889e49c2e103d4d5b60;
        proof[
            3
        ] = 0x9381564e58e1f0b73a1edcda9469f6c59407e5e7ae1f54bdebf2e00c2be5a23e;
        proof[
            4
        ] = 0xf415bceb3738fb943750f569b226fe96c64ac1b3a8075a4418c08b697c41c683;
        proof[
            5
        ] = 0x16ee7eada7331c3fdd16eef20108f4a329386c20e4951c3e689bb7363072c81f;
        proof[
            6
        ] = 0x33a88c386975fc0b82b5ca060f50614cbbf3b517743921d01f201174d9050261;
        proof[
            7
        ] = 0x70e151d126139930c80411467e82e9b1fc563491007c59704bb1479e2dc3d615;

        vm.stopPrank();
        startHoax(address(0x4533d1F65906368ebfd61259dAee561DF3f3559D));
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 1);
        // should revert here
        vm.expectRevert(ChainWavesErrors.SnowcrashMinted.selector);
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
    }

    // Currently works,
    function testSnowcrashMintThrice() public {
        bytes32[] memory proof = new bytes32[](8);
        proof[
            0
        ] = 0xe6e7d43627ef26915e465da21a2b7a7dac9303693b04acd43b76064d24cb0023;
        proof[
            1
        ] = 0x39a123a730ca7542702dd494f9fdda13aeb76805d7f6713e8a0a97b0e3fdacc1;
        proof[
            2
        ] = 0x437e46241a0e9868922756c86d716dc7fb28145693614889e49c2e103d4d5b60;
        proof[
            3
        ] = 0x9381564e58e1f0b73a1edcda9469f6c59407e5e7ae1f54bdebf2e00c2be5a23e;
        proof[
            4
        ] = 0xf415bceb3738fb943750f569b226fe96c64ac1b3a8075a4418c08b697c41c683;
        proof[
            5
        ] = 0x16ee7eada7331c3fdd16eef20108f4a329386c20e4951c3e689bb7363072c81f;
        proof[
            6
        ] = 0x33a88c386975fc0b82b5ca060f50614cbbf3b517743921d01f201174d9050261;
        proof[
            7
        ] = 0x70e151d126139930c80411467e82e9b1fc563491007c59704bb1479e2dc3d615;

        vm.stopPrank();

        startHoax(address(0x4533d1F65906368ebfd61259dAee561DF3f3559D));
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 1);
        vm.expectRevert(ChainWavesErrors.SnowcrashMinted.selector);
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        vm.expectRevert(ChainWavesErrors.SnowcrashMinted.selector);
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
    }

    function testMintSnowcrashThenNormie() public {
        bytes32[] memory proof = new bytes32[](8);
        proof[
            0
        ] = 0xe6e7d43627ef26915e465da21a2b7a7dac9303693b04acd43b76064d24cb0023;
        proof[
            1
        ] = 0x39a123a730ca7542702dd494f9fdda13aeb76805d7f6713e8a0a97b0e3fdacc1;
        proof[
            2
        ] = 0x437e46241a0e9868922756c86d716dc7fb28145693614889e49c2e103d4d5b60;
        proof[
            3
        ] = 0x9381564e58e1f0b73a1edcda9469f6c59407e5e7ae1f54bdebf2e00c2be5a23e;
        proof[
            4
        ] = 0xf415bceb3738fb943750f569b226fe96c64ac1b3a8075a4418c08b697c41c683;
        proof[
            5
        ] = 0x16ee7eada7331c3fdd16eef20108f4a329386c20e4951c3e689bb7363072c81f;
        proof[
            6
        ] = 0x33a88c386975fc0b82b5ca060f50614cbbf3b517743921d01f201174d9050261;
        proof[
            7
        ] = 0x70e151d126139930c80411467e82e9b1fc563491007c59704bb1479e2dc3d615;

        vm.stopPrank();

        startHoax(address(0x4533d1F65906368ebfd61259dAee561DF3f3559D));
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 1);
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assertEq(chainWaves.totalSupply(), 2);
    }

    function testMintNormieThenSnowcrash() public {
        bytes32[] memory proof = new bytes32[](8);
        proof[
            0
        ] = 0xe6e7d43627ef26915e465da21a2b7a7dac9303693b04acd43b76064d24cb0023;
        proof[
            1
        ] = 0x39a123a730ca7542702dd494f9fdda13aeb76805d7f6713e8a0a97b0e3fdacc1;
        proof[
            2
        ] = 0x437e46241a0e9868922756c86d716dc7fb28145693614889e49c2e103d4d5b60;
        proof[
            3
        ] = 0x9381564e58e1f0b73a1edcda9469f6c59407e5e7ae1f54bdebf2e00c2be5a23e;
        proof[
            4
        ] = 0xf415bceb3738fb943750f569b226fe96c64ac1b3a8075a4418c08b697c41c683;
        proof[
            5
        ] = 0x16ee7eada7331c3fdd16eef20108f4a329386c20e4951c3e689bb7363072c81f;
        proof[
            6
        ] = 0x33a88c386975fc0b82b5ca060f50614cbbf3b517743921d01f201174d9050261;
        proof[
            7
        ] = 0x70e151d126139930c80411467e82e9b1fc563491007c59704bb1479e2dc3d615;

        vm.stopPrank();
        startHoax(address(0x4533d1F65906368ebfd61259dAee561DF3f3559D));
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assertEq(chainWaves.totalSupply(), 1);
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
        assertEq(chainWaves.totalSupply(), 2);
    }

    function testFailWrongProofMint() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        proof[
            1
        ] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        chainWaves.snowcrashMint{value: 0.0256 ether}(proof);
    }

    function testCannotOverrunSnowcrashReserve() public {
        uint256 nonReservedSpots = chainWaves.MAX_SUPPLY() -
            chainWaves.snowcrashReserve();
        for (uint256 i; i < nonReservedSpots; ++i) {
            address minter = address(uint160(i + 100));
            vm.stopPrank();
            hoax(minter);
            chainWaves.normieMint{value: 0.0256 ether}(1);
        }
        vm.stopPrank();
        vm.expectRevert(ChainWavesErrors.SoldOut.selector);
        chainWaves.normieMint{value: 0.0256 ether}(1);
    }

    function testSnowcrashReserveSetToZero() public {
        uint256 nonReservedSpots = chainWaves.MAX_SUPPLY() -
            chainWaves.snowcrashReserve();
        chainWaves.wipeSnowcrashReserve();
        for (uint256 i; i < nonReservedSpots; ++i) {
            address minter = address(uint160(i + 100));
            vm.stopPrank();
            hoax(minter);
            chainWaves.normieMint{value: 0.0256 ether}(1);
        }
        vm.stopPrank();
        chainWaves.normieMint{value: 0.0256 ether}(1);
        assertEq(chainWaves.totalSupply(), nonReservedSpots + 1);
    }
}
