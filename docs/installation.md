# Installation

## Docker
Run nanopype with all its dependencies from within an automated built docker container. This is primarily for local usage and does currently not support snakemakes cluster engine. 

    docker pull giesselmann/nanopype

You can extend or customize your docker in the following way: 
    
    docker run -it --mount type=bind,source=/host/installer/path,target=/src nanopype
    
In the docker shell you could install e.g. albacore from ONT after you downloaded the python wheel to the hosts */host/installer/path*:
    
    pip3 install /src/ont_albacore-2.3.3-cp35-cp35m-manylinux1_x86_64.whl

## Python
We recommend to create a python virtual environment and install nanopype and its dependencies into it:
    
    python3 -m venv /path/to/your/environment
    source /path/to/your/environment/bin/activate
    
Nanopype relies on latest snakemake features, please consider updating your snakemake from the bitbucket repository:

    git clone https://bitbucket.org/snakemake/snakemake.git
    cd snakemake
    pip3 install . --upgrade
    
Finally Install nanopype from [github.com/giesselmann](https://github.com/giesselmann/nanopype/):

    git clone https://github.com/giesselmann/nanopype
    cd nanopype
    pip3 install . --upgrade


## Tools
Nanopype integrates a variety of different tools merged into processing pipelines for common use cases. If you don't use the docker image, you will need to install them separately and tell nanopype via the environment [configuration](configuration.md) where to find them.

We provide snakemake rules to download and build all dependencies. From within the nanopype repository run
    
    snakemake --snakefile rules/install.smk all
    
to build and install all tools into **src** and **bin** folders within the current directory. To only build specific targets e.g. samtools you can use:

    snakemake --snakefile rules/install.smk samtools
    
You will need to append the **bin** directory to your PATH variable, modify the paths in the environment config or re-run the install script with
    
    pip3 install . --upgrade --install-option="--tools=$(pwd)/bin"

to make nanopype aware of the installed tools. You may wish to test your installation by running:
    
    python3 test/test_install.py

***

Currently the following tools are available:

**Basecalling**

:   * Albacore (access restricted to ONT community)

**Alignment**

:   * Minimap2 *https://github.com/lh3/minimap2*
    * Graphmap *https://github.com/isovic/graphmap*
    * Ngmlr *https://github.com/philres/ngmlr*
    
**Methylation detection**

:   * Nanopolish *https://github.com/jts/nanopolish*

**Structural variation**

:   * Sniffles *https://github.com/fritzsedlazeck/Sniffles*

**Miscellaneous**

:   * Samtools *https://github.com/samtools/samtools*
    * Bedtools *https://github.com/arq5x/bedtools2*
    * UCSCTools *http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/*
        * bedGraphToBigWig 


