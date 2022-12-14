# bash_concurrent
concurrency in bash scripts

## Examples

1. **00-example-basic-multitasking.bash**

```sh
[DEBUG] __PIPE_PREFIX: __bash_94433_pipe
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_94433__func_returnsXXXXXXXXXX.dmJ75fQk for synchronous communication in pid 94433
{"tag": "4.3.1"}
{"CVE": "1343-HGt"}

real	0m19.992s
user	0m0.004s
sys	0m0.011s


[DEBUG] creating background job with id 0
[DEBUG] creating background job with id 1
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_94433__func_returnsXXXXXXXXXX.jo5Lv7fx for synchronous communication in pid 94450
[DEBUG] starting background task 0
[DEBUG] reading from pipe /tmp/__bash_94433_pipe_21207
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_94433__func_returnsXXXXXXXXXX.ssk2T3eB for synchronous communication in pid 94460
[DEBUG] starting background task 1
[DEBUG] background task 0 completed
[DEBUG] flushing pipe id from memory
{"tag": "4.3.1"}
[DEBUG] reading from pipe /tmp/__bash_94433_pipe_18947
[DEBUG] background task 1 completed
[DEBUG] flushing pipe id from memory
{"CVE": "1343-HGt"}

real	0m10.045s
user	0m0.018s
sys	0m0.045s
```

2. **01-example-functools.bash**

```sh
[DEBUG] __PREFIX: functools_example
[DEBUG] __PIPE_PREFIX: __functools_example_pipe
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/functools_example__func_returnsXXXXXXXXXX.sA8TVaY8 for synchronous communication in pid 94419
[DEBUG] executing foo
out: {"tag": "v12.87.3"}
```

3. **02-example-nested_functool_concurrent.txt**

```sh
[DEBUG] __PREFIX: nested_functool_with_multitasking
[DEBUG] __PIPE_PREFIX: __nested_functool_with_multitasking_pipe
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/nested_functool_with_multitasking__func_returnsXXXXXXXXXX.rzWiP2sa for synchronous communication in pid 94486
[DEBUG] creating background job with id 0
[DEBUG] creating background job with id 1
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/nested_functool_with_multitasking__func_returnsXXXXXXXXXX.9hJAuhcf for synchronous communication in pid 94496
[DEBUG] starting background task 0
[DEBUG] creating background job with id 2
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/nested_functool_with_multitasking__func_returnsXXXXXXXXXX.UWgfPgI1 for synchronous communication in pid 94506
[DEBUG] starting background task 1
[DEBUG] creating background job with id 3
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/nested_functool_with_multitasking__func_returnsXXXXXXXXXX.Vx9ACQpu for synchronous communication in pid 94516
[DEBUG] starting background task 2
[DEBUG] reading from pipe /tmp/__nested_functool_with_multitasking_pipe_3316
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/nested_functool_with_multitasking__func_returnsXXXXXXXXXX.rJbRkgqI for synchronous communication in pid 94526
[DEBUG] starting background task 3
[DEBUG] in baz
[DEBUG] inside bar
[DEBUG] inside foo
[DEBUG] in baz
[DEBUG] inside bar
[DEBUG] inside foo
[DEBUG] in baz
[DEBUG] inside bar
[DEBUG] inside foo
[DEBUG] background task 0 completed
[DEBUG] flushing pipe id from memory
[DEBUG] in baz
foo 94486 bar 94486 baz 94486
[DEBUG] inside bar
[DEBUG] inside foo
[DEBUG] reading from pipe /tmp/__nested_functool_with_multitasking_pipe_18293
[DEBUG] background task 1 completed
[DEBUG] flushing pipe id from memory
foo 94486 bar 94486 baz 94486
[DEBUG] reading from pipe /tmp/__nested_functool_with_multitasking_pipe_13457
[DEBUG] background task 2 completed
[DEBUG] flushing pipe id from memory
foo 94486 bar 94486 baz 94486
[DEBUG] reading from pipe /tmp/__nested_functool_with_multitasking_pipe_24718
[DEBUG] background task 3 completed
[DEBUG] flushing pipe id from memory
foo 94486 bar 94486 baz 94486
```
