
Repository made for the SCHC Hackathon (IETF 102, Montreal)

* make
  (or make repos)
  * -> automatically clones schc-test (from Dominique)
  * -> automatically clones micropython (version for Linux)

* make run-send
  * -> automatically builds micropython-for-unix
  * -> runs it with "schc_test.py send"

Notes:
  micropython issues:
  
In micropython, bytearray accepts only one argument, whereas in cpython
you must have 2 arguments (e.g. with the encoding), if the first is a str.

$ ./micropython/ports/unix/micropython -c 'bytearray("aaa", "utf-8")'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: function expected at most 1 arguments, got 2

$ python3 -c 'bytearray("aaa", "utf-8")'
$ # fine

