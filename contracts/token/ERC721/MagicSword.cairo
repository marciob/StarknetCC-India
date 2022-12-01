%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.token.erc721.library import ERC721
from IERC721 import IERC721
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.access.ownable.library import Ownable
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from ERC721_Metadata_base import (
    ERC721_Metadata_initializer,
    ERC721_Metadata_tokenURI,
    ERC721_Metadata_setBaseTokenURI,
)

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt,
    symbol: felt,
    owner: felt,
    base_token_uri_len: felt,
    base_token_uri: felt*,
    token_uri_suffix: felt,
) {
    ERC721.initializer(name, symbol);
    ERC721_Metadata_initializer();
    Ownable.initializer(owner);
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    
    nextTokenId.write(1);

    return ();
}

// NFT collection contract address that will be used to attached the SBTns to
//in this case it's Alien Stark collection
const NFT_collection_address = 0x075c4a08b9d2b232c302dc4bdbb14a2346d6f4a7c65d1f5884cf910be583f925;

// Setters
@storage_var
func nextTokenId() -> (res: felt) {
}

//
// Getters
//

// mapping to check which SBTn ids are attached to an account
@view
func hasSBTn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (sbtn_ids: felt)  {
    
}

@view
func SBTnAttachedTo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sbtn_id: felt
) -> (nft_collection_id: felt)  {
    
}

@view
func getOwner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner) = Ownable.owner();
    return (owner=owner);
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interface_id: felt
) -> (success: felt) {
    let (success) = ERC165.supports_interface(interface_id);
    return (success,);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(token_id);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(token_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (token_uri_len: felt, token_uri: felt*) {
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id);
    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, token_id: Uint256
) {
    ERC721.approve(to, token_id);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, token_id: Uint256, nft_token_id: Uint256
) {
    alloc_locals;
    let (sender_address) = get_caller_address();

    //stores the owner of the NFT id from collection
    let (nft_token_owner) = IERC721.ownerOf(
        contract_address=NFT_collection_address, token_id=nft_token_id
    );

    if (nft_token_owner == sender_address) {
        ERC721.transfer_from(_from, nft_token_owner, token_id);
        return ();
    } else {
        return ();
    }
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*, nft_token_id: Uint256
) {
    alloc_locals;
    let (sender_address) = get_caller_address();

    //stores the owner of the NFT id from collection
    let (nft_token_owner) = IERC721.ownerOf(
        contract_address=NFT_collection_address, token_id=nft_token_id
    );

    if (nft_token_owner == sender_address) {
        ERC721.transfer_from(_from, nft_token_owner, token_id);
        return ();
    } else {
        return ();
    }
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    base_token_uri_len: felt, base_token_uri: felt*, token_uri_suffix: felt
) {
    Ownable.assert_only_owner();
    ERC721_Metadata_setBaseTokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);
    return ();
}

// mint SBTn
@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, nft_address: felt, nft_token_id: Uint256
) {
    alloc_locals;
    let (sender_address) = get_caller_address();

    //stores the owner of the NFT id from collection
    let (nft_token_owner) = IERC721.ownerOf(
        contract_address=NFT_collection_address, token_id=nft_token_id
    );

    with_attr error_message("Sender doesn't doesn't own that token ID from NFT collection") {
        // checks if the sender is the owner of the NFT id from collection
        assert sender_address = nft_token_owner;
    }

    // getNextTokenId
    let token_id = nextTokenId.read();

    ERC721._mint(to, token_id);

    nextTokenId.write(token_id + 1);

    //maps this SBTn to sender
    hasSBTn.write(sender_address, token_id);

    //maps this SBTn to the NFT Collection ID
    SBTnAttachedTo.write(token_id, nft_token_id);

    return ();
}

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(token_id: Uint256) {
    Ownable.assert_only_owner();
    ERC721._burn(token_id);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_owner: felt
) -> (new_owner: felt) {
    // Ownership check is handled by this function
    Ownable.transfer_ownership(new_owner);
    return (new_owner=new_owner);
}
