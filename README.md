# ESM

Emergency Shutdown Module

## Invariants

* `fire` can be triggered by anyone
* `fire` can be triggered iff the ESM's balance is >= the `cap`
* `fire` can only be called once
* state transition functions are `auth`ed
* `join` can be called only in the `BASIC` state
* `join` can be called even after the `cap` has been reached
* `exit` can be called only in the `FREED` state

## Allowed state transitions

* basic
  * freed
  * burnt
  * fired
* freed
  * basic
  * burnt
  * fired
* burnt
  * basic
  * freed
  * fired
* fired
  * freed
  * burnt

## Moving to a new ESM

* Governance calls `free`
* Users call `exit`
* Users `join` a new ESM

## Pointing the ESM to a new End

* Governance calls `file("aim", 0xdeadbeef)`
