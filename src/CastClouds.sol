// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC2981 } from "@openzeppelin/contracts/token/common/ERC2981.sol";
import { ERC1155, ERC1155Supply } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract CastClouds is Ownable, ERC1155Supply, ERC2981 {
    string public name = "Cast Clouds";
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

    /// @notice deploy the Cast Clouds contract
    /// @param _owner the initial owner of the contract
    /// @param _royaltyReceiver the default royalty receiver address
    constructor(address _owner, address _royaltyReceiver) ERC1155("") Ownable(_owner) {
        _setDefaultRoyalty(_royaltyReceiver, 250);
    }

    /// @notice mints a single token to msg.sender
    /// @param _id the token ID to mint
    function mint(uint256 _id) external {
        if (!mintingOpen[_id]) revert MintingClosed();
        if (minted[_id][msg.sender]) revert OneMintPerAccount();

        minted[_id][msg.sender] = true;

        _mint(msg.sender, _id, 1, "");
    }

    /// @notice updates the specified token URI
    /// @notice only callable by the owner
    /// @param _id the token ID to update the URI for
    /// @param _uri the new token URI string
    function updateUri(uint256 _id, string memory _uri) external onlyOwner {
        if (locked[_id]) revert Locked();

        _uris[_id] = _uri;

        emit MetadataUpdate(_id);
    }

    /// @notice locks the specified token ID so minting can't be opened again,
    /// @notice and the URI for the token can't be updated.
    /// @notice only callable by the owner
    /// @param _id the token ID to lock
    function lock(uint256 _id) external onlyOwner {
        if (locked[_id]) revert Locked();

        locked[_id] = true;

        emit PermanentURI(_uris[_id], _id);
    }

    /// @notice opens minting for the specified token ID
    /// @notice only callable by the owner
    /// @param _id the token ID to open minting for
    function openMinting(uint256 _id) external onlyOwner {
        if (mintingOpen[_id]) revert MintingOpen();
        if (locked[_id]) revert Locked();

        mintingOpen[_id] = true;
    }

    /// @notice closes minting for the specified token ID
    /// @notice only callable by the owner
    /// @param _id the token ID to open minting for
    function closeMinting(uint256 _id) external onlyOwner {
        if (!mintingOpen[_id]) revert MintingClosed();

        mintingOpen[_id] = false;
    }

    /// @notice sets the default royalty info
    /// @notice only callable by the owner
    /// @param _receiver default address to receive royalties
    /// @param _feeNumerator royalty amount numerator, denominator is 10,000
    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) external onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    /// @notice sets the royalty info for a specific token
    /// @notice only callable by the owner
    /// @param _tokenId the token ID to set royalty info for
    /// @param _receiver address to receive royalties for the token
    /// @param _feeNumerator royalty amount numerator, denominator is 10,000
    function setTokenRoyalty(uint256 _tokenId, address _receiver, uint96 _feeNumerator) external onlyOwner {
        _setTokenRoyalty(_tokenId, _receiver, _feeNumerator);
    }

    /// @notice the distinct Uniform Resource Identifier (URI) for a given token
    /// @param _id the token ID to get URI for
    /// @return the URI string
    function uri(uint256 _id) public view override returns (string memory) {
        return _uris[_id];
    }

    /// @notice returns true if this contract implements the specified interface ID
    /// @param _interfaceId The bytes4 interface ID
    /// @return true if this contract implements the specified interface ID
    function supportsInterface(bytes4 _interfaceId) public view override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }
}
