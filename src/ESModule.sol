pragma solidity ^0.5.6;

import "ds-auth/auth.sol";
import "ds-note/note.sol";

contract GemLike {
    function balanceOf(address) public returns (uint256);
}

contract EndLike {
    // TODO: does it need the auth modifier?
    function cage() public;
}

contract ESModule is DSAuth, DSNote {
    uint256 public threshold;
    mapping(address => uint256) public gems;
    GemLike public gem;
    bool freed;
    // TODO: should allow firing more than once?
    bool fired;
    bool burnt;
    EndLike end;

    constructor(address gem_, address end_, address owner_, address authority_) public {
        gem = GemLike(gem_);
        end = EndLike(end_);
        owner = owner;
        authority = DSAuthority(authority_);
    }

    // -- math --
    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y;
        require(z <= x);
    }

    function fire() public note {
        require(!fired);
        require(gem.balanceOf(address(this)) >= threshold, "es-module/threshold-not-met");

        end.cage();
        fired = true;
    }

    function free() public auth note {
        require(fired && !burnt);

        freed = true;
    }

    // TODO: maybe burner
    function burn() public auth note {
        require(fired && !freed);
        require(gem.balanceOf(address(this)) >= threshold, "es-module/threshold-not-met");

        gem.transfer(0x0, gem.balanceOf(address(this)));

        burnt = true;
    }

    function join(uint256 wad) public note {
        require(!fired);

        gems[msg.sender] = add(gems[msg.sender], wad);
        gem.transferFrom(msg.sender, address(this));
    }

    function exit(address usr, uint256 wad) public note {
        require(freed);

        gems[msg.sender] = sub(gems[msg.sender], wad);
        gem.transfer(usr, wad);
    }
}
