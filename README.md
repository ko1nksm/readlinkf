# readlinkf

  1. readlink (without -f option) implementation
  2. POSIX compliant implementation

## test
```
/
|-- BASE
|   |-- DIR
|   |   |-- FILE
|   |   |-- LINK1 -> ../FILE
|   |   |-- LINK2 -> ./LINK1
|   |   `-- LINK3 -> ../../LINK4
|   |-- FILE
|   |-- LINK -> FILE
|   |-- LINK2 -> DIR
|   |-- PARENT -> ../
|   `-- PARENT2 -> ../BASE
|-- BASE1 -> /BASE
|-- INCLUDE SPACE
|   |-- DIR NAME
|   |   `-- SYMBOLIC LINK -> ../FILE NAME
|   `-- FILE NAME
|-- LINK4 -> TMP/DIR/FILE
|-- LOOP1 -> ./LOOP2
|-- LOOP2 -> ./LOOP1
|-- MISSING -> ./NO_FILE
`-- ROOT -> /
```

----------------------------------------------------------------------

```
[ok]  /BASE -> /BASE
[ok]  /BASE/ -> /BASE
[ok]  /BASE/DIR -> /BASE/DIR
[ok]  /BASE/DIR/ -> /BASE/DIR
[ok]  /BASE/DIR/FILE -> /BASE/DIR/FILE
[ok]  /BASE/DIR/FILE/ -> 
[ok]  /BASE/DIR/LINK1 -> /BASE/FILE
[ok]  /BASE/DIR/LINK1/ -> 
[ok]  /BASE/DIR/LINK2 -> /BASE/FILE
[ok]  /BASE/DIR/LINK2/ -> 
[ok]  /BASE/DIR/LINK3 -> 
[ok]  /BASE/DIR/LINK3/ -> 
[ok]  /BASE/FILE -> /BASE/FILE
[ok]  /BASE/FILE/ -> 
[ok]  /BASE/LINK -> /BASE/FILE
[ok]  /BASE/LINK/ -> 
[ok]  /BASE/LINK2 -> /BASE/DIR
[ok]  /BASE/LINK2/ -> /BASE/DIR
[ok]  /BASE/PARENT -> /
[ok]  /BASE/PARENT/ -> /
[ok]  /BASE/PARENT2 -> /BASE
[ok]  /BASE/PARENT2/ -> /BASE
[ok]  /BASE1 -> /BASE
[ok]  /BASE1/ -> /BASE
[ok]  /INCLUDE SPACE -> /INCLUDE SPACE
[ok]  /INCLUDE SPACE/ -> /INCLUDE SPACE
[ok]  /INCLUDE SPACE/DIR NAME -> /INCLUDE SPACE/DIR NAME
[ok]  /INCLUDE SPACE/DIR NAME/ -> /INCLUDE SPACE/DIR NAME
[ok]  /INCLUDE SPACE/DIR NAME/SYMBOLIC LINK -> /INCLUDE SPACE/FILE NAME
[ok]  /INCLUDE SPACE/DIR NAME/SYMBOLIC LINK/ -> 
[ok]  /INCLUDE SPACE/FILE NAME -> /INCLUDE SPACE/FILE NAME
[ok]  /INCLUDE SPACE/FILE NAME/ -> 
[ok]  /LINK4 -> 
[ok]  /LINK4/ -> 
[ok]  /LOOP1 -> 
[ok]  /LOOP1/ -> 
[ok]  /LOOP2 -> 
[ok]  /LOOP2/ -> 
[ok]  /MISSING -> /NO_FILE
[ok]  /MISSING/ -> /NO_FILE
[ok]  /ROOT -> /
[ok]  /ROOT/ -> /
[ok]  /BASE/LINK2/FILE -> /BASE/DIR/FILE
[ok]  /BASE/LINK2/FILE/ -> 
```
