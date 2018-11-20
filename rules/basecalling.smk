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
localrules: basecaller_merge_run, basecaller_compress_run, basecaller_merge_runs, basecaller_compress_runs
#ruleorder: basecaller_merge2 > basecaller_merge


# get batches
def get_batches_basecaller(wildcards):
    return expand("runs/{wildcards.runname}/sequences/{{batch}}.{wildcards.basecaller}.{wildcards.format}".format(wildcards=wildcards), batch=get_batches(wildcards))

# flowcell and kit parsing
def get_flowcell(wildcards):
    fields = wildcards.runname.split(config['runname']['delimiter'])
    if fields[config['runname']['field_flowcell']] in ['FLO-MIN106', 'FLO-MIN107', 'FLO-PRO001']:
        return fields[config['runname']['field_flowcell']]
    else:
        raise ValueError('Could not detect flowcell from ' + wildcards.runname)
    
def get_kit(wildcards):
    fields = wildcards.runname.split(config['runname']['delimiter'])
    if fields[config['runname']['filed_kit']] in ['SQK-DCS108','SQK-LRK001','SQK-LSK108','SQK-LSK109', 'SQK-LSK308', 'SQK-LWB001','SQK-LWP001','SQK-PBK004','SQK-PCS108','SQK-PSK004','SQK-RAB201','SQK-RAB204','SQK-RAD002','SQK-RAD003','SQK-RAD004','SQK-RAS201','SQK-RBK001','SQK-RBK004','SQK-RLB001','SQK-RLI001','SQK-RNA001','SQK-RPB004','VSK-VBK001','VSK-VMK001','VSK-VSK001']:
        return fields[config['runname']['filed_kit']]
    else:
        raise ValueError('Could not detect kit from ' + wildcards.runname)


# albacore basecalling
rule albacore:
    input:
        "{data_raw}/{{runname}}/reads/{{batch}}.tar".format(data_raw = config["data_raw"])
    output:
        "runs/{runname}/sequences/{batch}.albacore.{format}"
    shadow: "minimal"
    threads: 16
    resources:
        mem_mb = lambda wildcards, attempt: int((1.0 + (0.1 * (attempt - 1))) * 32000),
        time_min = 90
    params:
        flowcell = get_flowcell,
        kit = get_kit,
        barcoding = lambda wildcards : '--barcoding' if config['albacore_barcoding'] else '',
        filtering = lambda wildcards : '--disable_filtering' if config['albacore_disable_filtering'] else ''
    shell:
        """
        mkdir -p raw
        tar -C raw/ -xf {input}
        {config[bin][albacore]} -i raw/ --recursive -t {threads} -s raw/ --flowcell {params.flowcell} --kit {params.kit} --output_format fastq {params.filtering} {params.barcoding}
        FASTQ_DIR='raw/workspace/'
        if [ \'{params.filtering}\' = '' ]; then
            FASTQ_DIR='raw/workspace/pass'
        fi
        find ${{FASTQ_DIR}} -regextype posix-extended -regex '^.*f(ast)?q' -exec cat {{}} \; > {wildcards.batch}.fq
        if [[ \'{wildcards.format}\' == *'q'* ]]; then
            cat {wildcards.batch}.fq > {output}
        else
            cat {wildcards.batch}.fq | paste - - - - | cut -f1,2 | tr '@' '>' | tr '\t' '\n' > {output}
        fi
        """
        
# merge and compression
rule basecaller_merge_run:
    input:
        get_batches_basecaller
    output:
        "runs/{runname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}"
    shell:
        "cat {input} > {output}"

rule basecaller_compress_run:
    input:
        "runs/{runname}.{basecaller}.{format}"
    output:
        "runs/{runname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}.gz"
    shell:
        "gzip {input}"
        
# merge run files      
rule basecaller_merge_runs:
    input:
        ['runs/{runname}.{{basecaller}}.{{format}}'.format(runname=runname) for runname in config['runnames']]
    output:
        "{trackname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}"
    params:
        min_coverage = 1
    shell:
        """
        cat {input} > {output}
        """
        
rule basecaller_compress_runs:
    input:
        "{trackname}.{basecaller}.{format}"
    output:
        "{trackname, [a-zA-Z0-9_-]+}.{basecaller}.{format, (fasta|fastq|fa|fq)}.gz"
    shell:
        "gzip {input}"
