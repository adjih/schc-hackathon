(Repository in construction)

Repository made for the SCHC Hackathon (IETF 103, Bangkok - follow-up of IETF 102, Montreal).

---

## "Installing"

How to "install": you first need to decide on your `<git-place>` i.e. the location of the GitHub repository you are going to work on.
* Either use your own GitHub acccount. For this:
  - fork [openschc/schc-hackathon](https://github.com/openschc/schc-hackathon) into your GitHub account.
  - fork [openschc/openschc](https://github.com/openschc/openschc) into your GitHub account.
  - in the instructions below, replace `<git-place>` with your GitHub account name.
  - the branch used is `hackathon103`.
* or do nothing and replace `<git-place>` with `openschc` below (faster, but later, you will probably need to manually set up remotes to push your changes to your own GitHub repo)

Then

* Clone schc-hackathon (branch hackathon103):
  * `git clone https://github.com/<git-place>/schc-hackathon -b hackathon103`
* `cd schc-hackathon && make GITPLACE=<git-place>`
  * -> this will automatically clone micropython (Linux/MacOS version)
  * -> this will automatically set git add remote `osc` in `schc-hackathon` and `openschc`


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
