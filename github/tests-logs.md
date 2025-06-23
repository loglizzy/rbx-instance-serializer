Logs i got from running the playtests
```
Target has 256 child instances.
  
TEST serialization-results
SingleInstance(only selected instance and nothing else)
48 bytes/characters
0.00003229999856557697 secs
Recursive(instance + descendants)
47119 bytes/characters
0.0015007000038167462 secs
RecursiveWithDiffs(Recursive function + size reduction)
45105 bytes/characters
0.002481799994711764 secs
  
TEST speed
Speed overview after serializing 1 million times:
Time took to serialize all: 1.1596523999614874
Avarage time per serialization: 0.0000011596523999614873
Lowest time in all: 7.999915396794677e-07
Minutes needed to serialize 1 billion instances:
Using the avarage speed: 19.327539999358123
Using the best speed reached: 13.333192327991128
```