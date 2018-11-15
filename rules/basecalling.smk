# \HEADER\-------------------------------------------------------------------------
#
#  CONTENTS      : Snakemake nanopore data pipeline
#
#  DESCRIPTION   : nanopore basecalling rules
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
include: "utils.smk"
localrules: basecaller_merge, basecaller_merge2, basecaller_compress
ruleorder: basecaller_merge2 > basecaller_merge


# get batches
def get_batches_basecaller(wildcards):
    return expand("runs/{wildcards.runname}/sequences/{{batch}}.{wildcards.basecaller}.{wildcards.format}".format(wildcards=wildcards), batch=get_batches(wildcards))

# flowcell and kit parsing
def get_flowcell(wildcards):
    fields = wildcards.runname.split('_')
    if fields[2] in ['FLO-MIN106', 'FLO-MIN107', 'FLO-PRO001']:
        return fields[2]
    else:
        raise ValueError('Could not detect flowcell from ' + wildcards.runname)
    
def get_kit(wildcards):
    fields = wildcards.runname.split('_')
    if fields[3] in ['SQK-DCS108','SQK-LRK001','SQK-LSK108','SQK-LSK109', 'SQK-LSK308', 'SQK-LWB001','SQK-LWP001','SQK-PBK004','SQK-PCS108','SQK-PSK004','SQK-RAB201','SQK-RAB204','SQK-RAD002','SQK-RAD003','SQK-RAD004','SQK-RAS201','SQK-RBK001','SQK-RBK004','SQK-RLB001','SQK-RLI001','SQK-RNA001','SQK-RPB004','VSK-VBK001','VSK-VMK001','VSK-VSK001']:
        return fields[3]
    else:
        raise ValueError('Could not detect kit from ' + wildcards.runname)


# albacore basecalling
rule albacore:
    output:
        "runs/{runname}/sequences/{batch}.albacore.{format}"
    shadow: "minimal"
    threads: 16
    resources:
        mem_mb = lambda wildcards, attempt: int((1.0 + (0.1 * (attempt - 1))) * 32000),
        time_min = 60
    params:
        flowcell = get_flowcell,
        kit = get_kit,
        barcoding = lambda wildcards : '--barcoding' if config['albacore_barcoding'] else ''
    shell:
        """
        mkdir -p raw
        tar -C raw/ -xf {config[DATADIR]}/{wildcards.runname}/reads/{wildcards.batch}.tar
        {config[albacore]} -i raw/ --recursive -t {threads} -s raw/ --flowcell {params.flowcell} --kit {params.kit} --output_format fastq --disable_filtering {params.barcoding}
        find raw/workspace/ -regextype posix-extended -regex '^.*f(ast)?q' -exec cat {{}} \; > {wildcards.batch}.fq
        if [[ {wildcards.format} == *'q'* ]]
        then
            cat {wildcards.batch}.fq > {output}
        else
            cat {wildcards.batch}.fq | paste - - - - | cut -f1,2 | tr '@' '>' | tr '\t' '\n' > {output}
        fi
        """
        
# merge and compression
rule basecaller_merge:
    input:
        get_batches_basecaller
    output:
        "runs/{runname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}"
    shell:
        "cat {input} > {output}"
        
rule basecaller_merge2:
    input:
        "runs/{runname}.{basecaller}.{format}.gz"
    output:
        "runs/{runname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}"
    shell:
        "gunzip {input}"

rule basecaller_compress:
    input:
        "runs/{runname}.{basecaller}.{format}"
    output:
        "runs/{runname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}.gz"
    shell:
        "gzip {input}"
        