(Repository in construction)

Repository made for the SCHC Hackathon (IETF 103, Bangkok - follow-up of IETF 102, Montreal).

---

## "Installing"

How to "install": you first need to decide your `<gitplace>` e.g. the place where there are your files.
* Either fork [schc-hackathon](https://github.com/openschc/schc-hackathon) and [openschc/openschc](https://github.com/openschc/openschc) in one github account and use `GITPLACE=<account>`. The used branch is `hackathon103`.
* or do nothing and use `GITPLACE=openschc` below (faster, but later, you will probably need to manually set up remotes to push your changes)

Then

* Clone schc-hackathon (branch hackathon103):
  * `git clone https://github.com/<git-base-name>/schc-hackathon -b hackathon103`
* `cd schc-hackathon && make GITPLACE=<git-base-name>`
  * -> automatically clones micropython (version for Linux/MacOS)
  * -> automatically sets git add remote `osc` in `schc-hackathon` and `openschc`


----

## Running

* `make test-upy`
  * -> runs micropython with `test_upy.py`
  * When it works, it just prints one string

* `make test-oschc`
  * -> runs micropython with `openschc/src/test_oschc.py` (that's openschc)
  * (need to write entirely the code for openschc first)

* `make test-schc-test-recv`
  * -> runs micropython with "old/test_schc.py recv" (that's schc-test)
  * This creates a receiver for fragments
  * (needs to be updated due to repository changes)

* `make test-schc-test-send`
  * -> runs micropython with "old/test_schc.py send" (that's schc-test)
  * This creates a sender for fragments which sends a large packet
  * (needs to be updated due to repository changes)

----

## Directory tree

|schc-hackathon | this meta-repository|
|-|-|
|schc-hackathon/openschc | where `openschc` is straighforwardly cloned |
|schc-hackathon/micropython | where `micropython` is straighforwardly cloned |
|schc-hackathon/openschc/src | where **code for the "new" openschc will be put** |
|schc-hackathon/openschc/src/schctest | where there is a full copy of **the last version of [schc-test](https://github.com/tanupoo/schc-test)** before hackathon103 with submodules |
