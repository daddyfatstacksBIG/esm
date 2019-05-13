pragma solidity ^0.5.6;

import "ds-auth/auth.sol";
import "ds-note/note.sol";

contract GemLike {
    function balanceOf(address) public returns (uint256);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address, address, uint256) public returns (bool);
}

contract EndLike {
    // TODO: does it need the auth modifier?
    function cage() public;
}

contract ESM is DSAuth, DSNote {
    uint256 public cap;
    GemLike public gem;
    EndLike public end;
    address public sun;

    mapping(address => uint256) public gems;

    bool fired;
    bool freed;
    bool burnt;

    constructor(address gem_, address end_, address sun_, uint256 cap_, address owner_, address authority_) public {
        gem = GemLike(gem_);
        end = EndLike(end_);
        sun = sun_;
        cap = cap_;
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
    function file(bytes32 job, address val) external auth note {
        if (job == "end") end = EndLike(val);
        if (job == "sun") sun = val;
    }

    function file(bytes32 job, uint256 val) external auth note {
        if (job == "cap") cap = val;
    }

    // -- esm actions --
    function fire() public note {
        require(!fired, "esm/already-fired");
        require(gem.balanceOf(address(this)) >= cap, "esm/cap-not-met");

        end.cage();
        fired = true;
    }

    function free() external auth note {
        require(!burnt, "esm/already-burnt");

        freed = true;
    }

    function burn() external auth note {
        require(fired && !freed, "esm/too-early-to-burn");

        burnt = true;
        bool ok = gem.transfer(address(sun), gem.balanceOf(address(this)));

        require(ok, "esm/failed-transfer");
    }

    // -- user actions --
    function join(uint256 wad) external note {
        require(!fired);

        gems[msg.sender] = add(gems[msg.sender], wad);
        bool ok = gem.transferFrom(msg.sender, address(this), wad);

        require(ok, "esm/failed-transfer");
    }

    function exit(address usr, uint256 wad) external note {
        require(freed, "esm/not-freed");

        gems[msg.sender] = sub(gems[msg.sender], wad);
        bool ok = gem.transfer(usr, wad);

        require(ok, "esm/failed-transfer");
    }
}
