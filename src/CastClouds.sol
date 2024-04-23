// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC1155, ERC1155Supply } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract CastClouds is Ownable, ERC1155Supply {
    mapping(uint256 id => string uri) private _uris;
    mapping(uint256 id => bool) public mintingOpen;
    mapping(uint256 id => bool) public locked;
    mapping(uint256 id => mapping(address account => bool)) public minted;

    event MetadataUpdate(uint256 _tokenId);
    event PermanentURI(string _value, uint256 indexed _id);

    error MintingOpen();
    error MintingClosed();
    error Locked();
    error OneMintPerAccount();

    constructor(address _owner) ERC1155("") Ownable(_owner) {}

    function mint(uint256 _id) external {
        if (!mintingOpen[_id]) revert MintingClosed();
        // if (minted[_id][msg.sender]) revert OneMintPerAccount();

        minted[_id][msg.sender] = true;

        _mint(msg.sender, _id, 1, "");
    }

    function updateUri(uint256 _id, string memory _uri) external onlyOwner {
        if (locked[_id]) revert Locked();

        _uris[_id] = _uri;

        emit MetadataUpdate(_id);
    }

    function lock(uint256 _id) external onlyOwner {
        if (locked[_id]) revert Locked();

        locked[_id] = true;

        emit PermanentURI(_uris[_id], _id);
    }

    function openMinting(uint256 _id) external onlyOwner {
        if (mintingOpen[_id]) revert MintingOpen();
        if (locked[_id]) revert Locked();

        mintingOpen[_id] = true;
    }

    function closeMinting(uint256 _id) external onlyOwner {
        if (!mintingOpen[_id]) revert MintingClosed();

        mintingOpen[_id] = false;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return _uris[_id];
    }
}
