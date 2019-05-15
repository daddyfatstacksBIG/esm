# ESM

Emergency Shutdown Module

## Invariants

* `fire` can be triggered by anyone
* `fire` can be triggered iff the ESM's balance is >= the `cap`
* `fire` can only be called once
* state transition functions are `auth`ed
* `free` and `burn` are mutually exclusive, and the first one to be triggered
  takes precedence
* `join` can be called iff `fire` has not been triggered
* `exit` can be called iff `free` has been triggered
* `join` can be called even after the `cap` has been reached

## Moving to a new ESM

* Governance calls `free`
* Users call `exit`
* Users `join` a new ESM

## Pointing the ESM to a new End

* Governance calls `file("aim", 0xdeadbeef)`
