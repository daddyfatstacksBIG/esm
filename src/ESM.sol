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

contract ESM is DSAuth, DSNote {
    uint256 public threshold;
    mapping(address => uint256) public gems;
    GemLike public gem;
    EndLike end;
    bool fired;
    bool freed;
    bool burnt;

    constructor(address gem_, address end_, address owner_, address authority_) public {
        gem = GemLike(gem_);
        end = EndLike(end_);
        owner = owner_;
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

    // -- admin --
    function setThreshold(uint256 threshold_) external auth note {
        threshold = threshold_;
    }

    function aim(address end_) external auth note {
        end = end_;
    }

    function fire() public note {
        require(!fired);
        require(gem.balanceOf(address(this)) >= threshold, "es-module/threshold-not-met");

        end.cage();
        fired = true;
    }

    function free() external auth note {
        require(!burnt);

        freed = true;
    }

    // TODO: maybe burner
    function burn() external auth note {
        require(fired && !freed);

        gem.transfer(0x0, gem.balanceOf(address(this)));
        burnt = true;
    }

    function join(uint256 wad) external note {
        require(!fired);

        gems[msg.sender] = add(gems[msg.sender], wad);
        gem.transferFrom(msg.sender, address(this));
    }

    function exit(address usr, uint256 wad) external note {
        require(freed);

        gems[msg.sender] = sub(gems[msg.sender], wad);
        gem.transfer(usr, wad);
    }
}
