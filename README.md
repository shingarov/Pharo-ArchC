# ArchC for Smalltalk

## How to load

### ...into Pharo

````
Metacello new
  baseline: 'ArchC';
  repository: 'github://shingarov/Pharo-ArchC:pure-z3';
  load.
````

#### To create fresh image for development:

Either use shortcut:

     ```
     git clone https://github.com/shingarov/Pharo-ArchC ArchC
     cd ArchC/pharo
     make
     pharo-ui ArchC.image
     ```

...or do it by hand:

  1. Clone the repository

     ```
     git clone https://github.com/shingarov/Pharo-ArchC ArchC
     ```

  2. Get PDLs:

     ```
     cd ArchC
     ./get-pdls.sh
     ```

     Alternatively, you may symlink `pdl` directory wherever you keep your PDLs

  3. Download Pharo

     ```
     mkdir ArchC/pharo
     cd ArchC/pharo

     # Be carefull, running a script downloaded from internet is not advisable!
     curl https://get.pharo.org/64/80+vm | bash
     ```

  4. Load code into Pharo image:

     ```
     ./pharo Pharo.image save archc
     ./pharo archc.image metacello install tonel://../src BaselineOfArchC
     ./pharo archc.image eval --save "(IceRepositoryCreator new location: '..' asFileReference; createRepository) register"
     ```
### ...into Smalltalk/X

*NOTE*: Following instruction assume you recent [Smalltalk/X jv-branch](1) , i.e., version newer than 2020-09-15
(older versions might not have Tonel support built).

 1. Install [MachineArithmetic](2). Follow instructions in
    [README.md](https://github.com/shingarov/MachineArithmetic/blob/pure-z3/README.md#into-smalltalkx)

 2. Clone the repository:

    ````
    git clone https://github.com/shingarov/Pharo-ArchC.git.git
    ````

 3. In Smalltalk/X, execute:

    ```
    "/ Tell Smalltalk/X where to look for MachineArithmetic packages
    Smalltalk packagePath add: '/where/you/cloned/it/MachineArithmetic'.

    "/ Tell Smalltalk/X where to look for ArchC packages
    Smalltalk packagePath add: '/where/you/cloned/it/Pharo-ArchC/src'.

    Smalltalk loadPackage: 'MachineArithmetic-FFI-SmalltalkX'.
    Smalltalk loadPackage: 'MachineArithmetic'.
    Smalltalk loadPackage: 'MachineArithmetic-Tests'.
    Smalltalk loadPackage: 'stx:goodies/petitparser'.
    Smalltalk loadPackage: 'ArchC-Core'.
    Smalltalk loadPackage: 'ArchC-Core-Tests'.
    Smalltalk loadPackage: 'ArchC-RISCV'.
    Smalltalk loadPackage: 'ArchC-RISCV-Tests'.


    "/ Set `libz3.so` to use
    (Smalltalk at: #LibZ3) libraryName: '/where/you/cloned/it/z3/build/libz3.so'
    ```

[1]: https://swing.fit.cvut.cz/projects/stx-jv/wiki/Download
[2]: https://github.com/shingarov/MachineArithmetic/
