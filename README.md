# Description

This script is intended to keep rsync from deleting the whole backup if the source is mutch smaller then the destination.
The threshold is set using percent of the destination tree and is configurable.

# Limitations

Because we are using perl for comparing the directory tree sizes the programm is limited to 9007199254740992 bytes (9 Petabytes).
At the time there is no overflow check implemented. Feel free to submit the patch.

You can check your limit with:

```
perl -e 'printf qq{%.f\n}, 2**53+$_ for +1,0,-1'
```
(from http://www.perlmonks.org/?node_id=718414)
