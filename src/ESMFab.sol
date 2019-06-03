pragma solidity ^0.5.6;

import {ESM} from "./ESM.sol";

import "ds-note/note.sol";

contract EndLike {
    function rely(address) public;
    function deny(address) public;
    function live() public returns (uint256);
}

contract ESMFab is DSNote {
    ESM     public esm;
    address public gem;
    EndLike public end;
    address public sun;
    uint256 public cap;

    mapping(address => uint256) public wards;
    function rely(address usr) public auth note { wards[usr] = 1; }
    function deny(address usr) public auth note { wards[usr] = 0; }
    modifier auth() { require(wards[msg.sender] == 1, "esmfab/unauthorized"); _; }

    constructor(address gem_, address end_, address sun_, uint256 cap_) public {
        wards[msg.sender] = 1;

        gem = gem_;
        end = EndLike(end_);
        sun = sun_;
        cap = cap_;

        esm = new ESM(msg.sender, gem_, end_, sun_, cap_);
    }

    // -- admin --
    function file(bytes32 job, address obj) external auth note {
        if (job == "end") end = EndLike(obj);
        if (job == "sun") sun = obj;
    }

    function file(bytes32 job, uint256 val) external auth note {
        if (job == "cap") cap = val;
    }

    // -- actions --
    function replace() external auth note {
        end.deny(address(esm));

        if (end.live() == 1) {
            esm = new ESM(msg.sender, gem, address(end), sun, cap);
            end.rely(address(esm));
        } else {
            end.deny(address(this));
        }
    }
}
