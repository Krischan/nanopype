# \HEADER\-------------------------------------------------------------------------
#
#  CONTENTS      : Snakemake nanopore data pipeline
#
#  DESCRIPTION   : none
#
#  RESTRICTIONS  : none
#
#  REQUIRES      : none
#
# ---------------------------------------------------------------------------------
# Copyright (c) 2018,  Pay Giesselmann, Max Planck Institute for Molecular Genetics
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Written by Pay Giesselmann
# ---------------------------------------------------------------------------------
configfile: "config.yaml"
include : "rules/basecalling.smk"
include : "rules/alignment.smk"
include : "rules/methylation.smk"
include : "rules/sv.smk"
localrules: albacore_basecalling_runs, graphmap_alignment_runs, nanopolish_methylation_runs


import os
runname = []
if os.path.isfile('runnames.txt'):
    runnames = [line.rstrip('\n') for line in open('runnames.txt')]

# basecalling for set of runs
rule albacore_basecalling_runs:
    input:
        ['runs/{runname}.albacore.fa.gz'.format(runname=runname) for runname in runnames]

# alignment for set of runs
rule graphmap_alignment_runs:
    input:
        ['runs/{runname}.graphmap.bam'.format(runname=runname) for runname in runnames]

# create nanopolish raw methylation calling for set of runs
rule nanopolish_methylation_runs:
    input:
        ['runs/{runname}.nanopolish.tsv.gz'.format(runname=runname) for runname in runnames]

        