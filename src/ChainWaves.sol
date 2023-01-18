// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import "./AnonymiceLibrary.sol";
import "./ChainWavesGenerator.sol";

contract ChainWaves is ERC721, Owned {
    using AnonymiceLibrary for uint8;

    error SoldOut();
    error NotLive();
    error MintPrice();
    error MaxThree();
    error PublicMinted();
    error SnowcrashMinted();
    error NotToad();
    error FreeMinted();
    error NotSnowcrashList();
    error ReserveClosed();
    error SelfMintOnly();
    error ArrayLengths();
    error NonExistantId();
    error Stap();
    error WithdrawFail();

    struct Trait {
        string traitName;
        string traitType;
    }

    struct HashNeeds {
        uint16 startHash;
        uint16 startNonce;
    }

    struct Palette {
        string bg;
        string colOne;
        string colTwo;
    }

    uint256 public constant MAX_SUPPLY = 512;
    uint256 public constant MINT_PRICE = 0.0256 ether;
    uint256 public constant SNOWCRASH_PRICE = 0.05 ether;
    uint256 public constant MAX_MINT = 3;
    uint256 public snowcrashReserve = 150;
    bool public MINTING_LIVE;

    uint256 public totalSupply;

    uint16 private SEED_NONCE = 3;

    // TODO: generate actual root (this is folded faces)
    bytes32 constant snowcrashRoot =
        0x358899790e0e071faed348a1b72ef18efe59029543a4a4da16e13fa2abf2a578;

    bool private freeMinted;

    mapping(address => bool) publicMinted;
    mapping(address => bool) snowcrashMinted;
    mapping(uint256 => HashNeeds) tokenIdToHashNeeds;
    mapping(uint256 => Trait[]) public traitTypes;
    mapping(address => uint256) lastWrite;

    //Mappings

    ChainWavesGenerator chainWavesGenerator;

    //uint arrays
    uint16[][6] private TIERS;

    constructor()
        ERC721("ChainWaves", "CA")
        Owned(0x9ea04B953640223dbb8098ee89C28E7a3B448858)
    {
        chainWavesGenerator = new ChainWavesGenerator();

        //Palette
        TIERS[0] = [1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
        //Noise
        TIERS[1] = [1000, 4000, 4000, 1000];
        //Speed
        TIERS[2] = [1000, 4000, 4000, 1000];
        //Char set
        TIERS[3] = [2250, 2250, 2250, 2250, 600, 400];
        //Detail
        TIERS[4] = [1000, 6000, 3000];
        //NumCols
        TIERS[5] = [800, 6200, 2600, 400];
    }

    //prevents someone calling read functions the same block they mint
    modifier disallowIfStateIsChanging() {
        if (lastWrite[msg.sender] == block.number) revert Stap();
        _;
    }

    /**
     * @dev Converts a digit from 0 - 10000 into its corresponding rarity based on the given rarity tier.
     * @param _randinput The input from 0 - 10000 to use for rarity gen.
     * @param _rarityTier The tier to use.
     */
    function rarityGen(uint256 _randinput, uint8 _rarityTier)
        internal
        view
        returns (uint8)
    {
        uint16 currentLowerBound;
        uint256 tiersLength = TIERS[_rarityTier].length;
        for (uint8 i; i < tiersLength; ++i) {
            uint16 thisPercentage = TIERS[_rarityTier][i];
            if (
                _randinput >= currentLowerBound &&
                _randinput < currentLowerBound + thisPercentage
            ) return i;
            currentLowerBound = currentLowerBound + thisPercentage;
        }

        revert();
    }

    /**
     * @param _a The address to be used within the hash.
     */
    function hash(address _a) internal view returns (uint16) {
        uint16 _randinput = uint16(
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.difficulty, _a)
                )
            ) % 10000
        );

        return _randinput;
    }

    function normieMint(uint256 _amount) external payable {
        if (_amount > MAX_MINT) revert MaxThree();
        if (msg.value != MINT_PRICE * _amount) revert MintPrice();
        if (publicMinted[msg.sender]) revert PublicMinted();

        publicMinted[msg.sender] = true;
        return mintInternal(msg.sender, _amount);
    }

    // TODO: add merkle root,
    function snowcrashMint(address account, bytes32[] calldata merkleProof)
        external
        payable
    {
        bytes32 node = keccak256(abi.encodePacked(account));
        require(
            MerkleProof.verify(merkleProof, snowcrashRoot, node),
            "Not on WL"
        );
        if (account != msg.sender) revert SelfMintOnly();
        if (msg.value != MINT_PRICE) revert MintPrice();
        if (snowcrashMinted[msg.sender]) revert SnowcrashMinted();
        if (snowcrashReserve == 0) revert ReserveClosed();
        snowcrashReserve -= 1;
        return mintInternal(msg.sender, 1);
    }

    function freeMints(
        address[] calldata _addresses,
        uint256[] calldata _amount
    ) external payable onlyOwner {
        if (freeMinted) revert FreeMinted();
        uint256 addressesLength = _addresses.length;
        if (addressesLength != _amount.length) revert ArrayLengths();
        for (uint256 i; i < addressesLength; ++i) {
            mintInternal(_addresses[i], _amount[i]);
        }
    }

    function mintInternal(address _to, uint256 _amount) internal {
        if (!MINTING_LIVE) revert NotLive();
        if (totalSupply + _amount + snowcrashReserve > MAX_SUPPLY)
            revert SoldOut();
        uint256 firstTokenId = totalSupply;

        for (uint256 i; i < _amount; ++i) {
            tokenIdToHashNeeds[i] = HashNeeds(hash(_to), SEED_NONCE);
            _mint(_to, firstTokenId);
            ++firstTokenId;
        }
        lastWrite[msg.sender] = block.number;
        SEED_NONCE += 10;
        totalSupply += _amount;
    }

    // hash stuff

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     * From anonymice
     */

    function buildHash(uint256 _t) internal view returns (string memory) {
        // This will generate a 4 character string.
        string memory currentHash = "";
        uint256 rInput = tokenIdToHashNeeds[_t].startHash;
        uint256 _nonce = tokenIdToHashNeeds[_t].startNonce;

        for (uint8 i; i < 6; ++i) {
            ++_nonce;
            uint16 _randinput = uint16(
                uint256(keccak256(abi.encodePacked(rInput, _t, _nonce))) % 10000
            );
            currentHash = string(
                abi.encodePacked(
                    currentHash,
                    rarityGen(_randinput, i).toString()
                )
            );
        }
        return currentHash;
    }

    // Views

    function hashToMetadata(string memory _hash)
        public
        view
        disallowIfStateIsChanging
        returns (string memory)
    {
        string memory metadataString;

        for (uint8 i; i < 6; ++i) {
            uint8 thisTraitIndex = AnonymiceLibrary.parseInt(
                AnonymiceLibrary.substring(_hash, i, i + 1)
            );

            metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type":"',
                    traitTypes[i][thisTraitIndex].traitType,
                    '","value":"',
                    traitTypes[i][thisTraitIndex].traitName,
                    '"}'
                )
            );

            if (i != 5)
                metadataString = string(abi.encodePacked(metadataString, ","));
        }

        return string(abi.encodePacked("[", metadataString, "]"));
    }

    function _tokenIdToHash(uint256 _tokenId)
        public
        view
        disallowIfStateIsChanging
        returns (string memory tokenHash)
    {
        if (_tokenId >= totalSupply) revert NonExistantId();
        tokenHash = buildHash(_tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory _URI)
    {
        if (_tokenId >= totalSupply) revert NonExistantId();
        string memory _hash = _tokenIdToHash(_tokenId);
        _URI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                AnonymiceLibrary.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "CH41NW4V35 #',
                                AnonymiceLibrary.toString(_tokenId),
                                '","description": "Fully onchain generative art SVG collection. Created by McToady & Circolors."',
                                ',"image": "data:image/svg+xml;base64,',
                                AnonymiceLibrary.encode(
                                    bytes(
                                        abi.encodePacked(
                                            "<svg viewBox='0 0 20 20' width='600' height='600' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMidYMin'><rect width='20' height='20' fill='#",
                                            chainWavesGenerator.buildSVG(
                                                _tokenId,
                                                _hash
                                            ),
                                            "</svg>"
                                        )
                                    )
                                ),
                                '","attributes":',
                                hashToMetadata(_hash),
                                "}"
                            )
                        )
                    )
                )
            )
        );
    }

    // Owner Functions
    /**
     * @dev Add a trait type
     * @param _traitTypeIndex The trait type index
     * @param traits Array of traits to add
     */

    function addTraitType(uint256 _traitTypeIndex, Trait[] memory traits)
        external
        payable
        onlyOwner
    {
        for (uint256 i; i < traits.length; ++i) {
            traitTypes[_traitTypeIndex].push(
                Trait(traits[i].traitName, traits[i].traitType)
            );
        }

        return;
    }

    function flipMint() external payable onlyOwner {
        MINTING_LIVE = !MINTING_LIVE;
    }

    function withdraw() external payable onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        if (!sent) revert WithdrawFail();
    }

    function wipeSnowcrashReserve() external payable onlyOwner {
        snowcrashReserve = 0;
    }
}