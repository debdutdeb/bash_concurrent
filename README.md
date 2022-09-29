# bash_concurrent
concurrency in bash scripts

## Examples

1. **00-example-basic-multitasking.bash**

```sh
[DEBUG] __PIPE_PREFIX: __bash_92548_pipe
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_92548__func_returnsXXXXXXXXXX.bsMlqtnh for synchronous communication in pid 92548
{"tag": "4.3.1"}
{"CVE": "1343-HGt"}

real	0m20.026s
user	0m0.005s
sys	0m0.012s


[DEBUG] creating background job with id 0
[DEBUG] creating background job with id 1
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_92548__func_returnsXXXXXXXXXX.TXTeIELQ for synchronous communication in pid 92548
[DEBUG] starting background task 0
[DEBUG] reading from pipe /tmp/__bash_92548_pipe_5260
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_92548__func_returnsXXXXXXXXXX.t5PZfU6r for synchronous communication in pid 92548
[DEBUG] starting background task 1
[DEBUG] background task 0 completed
[DEBUG] flushing pipe id from memory
{"tag": "4.3.1"}
[DEBUG] reading from pipe /tmp/__bash_92548_pipe_7358
[DEBUG] background task 1 completed
[DEBUG] flushing pipe id from memory
{"CVE": "1343-HGt"}

real	0m10.049s
user	0m0.017s
sys	0m0.043s
```

2. **01-example-functools.bash**

```sh
[DEBUG] __PIPE_PREFIX: __bash_92441_pipe
[DEBUG] using file /var/folders/pq/xv5hx2d117jfxls2nx49wgrm0000gn/T/bash_92441__func_returnsXXXXXXXXXX.y7HB1X23 for synchronous communication in pid 92441
[DEBUG] executing foo
out: {"tag": "v12.87.3"}
```
