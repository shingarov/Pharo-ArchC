# ArchC for Smalltalk

## How to load

### ...into Pharo

````
Metacello new
  baseline: 'ArchC';
  repository: 'github://shingarov/Pharo-ArchC:pure-z3';
  load.
````

To create fresh image for development: 

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