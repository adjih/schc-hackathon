
Repository made for the SCHC Hackathon (IETF 102, Montreal)

* make
  (or make repos)
  * -> automatically clones schc-test (from Dominique)
  * -> automatically clones micropython (version for Linux)

----

The sender/receiver code from schc-test had been copied/modified into
a single file `schc_test.py`

Currently, the sender and the receivers can be run on Linux and communicate
through lo (loopback), 127.0.0.1:9900 (sender) <-> 127.0.0.1:9999 (receiver)

How to run both:

* make recv
  * -> runs micropython with "schc_test.py recv"
  * This creates a receiver for fragments

* make send
  * -> runs micropython with "schc_test.py send"
  * This creates a sender for fragments which sends a large packet
  
----

Notes:
  micropython issues:
  
In micropython, bytearray accepts only one argument, whereas in cpython
you must have 2 arguments (e.g. with the encoding), if the first is a str.

```$ ./micropython/ports/unix/micropython -c 'bytearray("aaa", "utf-8")'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: function expected at most 1 arguments, got 2

$ python3 -c 'bytearray("aaa", "utf-8")'
$ # fine
```
