# \HEADER\-------------------------------------------------------------------------
#
#  CONTENTS      : Snakemake nanopore data pipeline
#
#  DESCRIPTION   : nanopore sv detection rules
#
#  RESTRICTIONS  : none
#
#  REQUIRES      : none
#
# ---------------------------------------------------------------------------------
# Copyright (c) 2018-2019, Pay Giesselmann, Max Planck Institute for Molecular Genetics
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
# imports
localrules: sv_compress, strique_merge_batches, strique_merge_tag

# get batches
def get_batches_strique(wildcards):
    return expand("sv/strique/{aligner}/{sequence_workflow}/batches/{tag}/{runname}/{batch}.{reference}.tsv",
                        aligner=wildcards.aligner,
                        sequence_workflow=wildcards.sequence_workflow,
                        tag=wildcards.tag,
                        runname=wildcards.runname,
                        batch=get_batch_ids_raw(wildcards.runname, config=config, tag=wildcards.tag, checkpoints=checkpoints),
                        reference=wildcards.reference)

def get_batches_strique2(wildcards):
    return expand("sv/strique/{aligner}/{sequence_workflow}/batches/{tag}/{runname}.{reference}.tsv",
                        aligner=wildcards.aligner,
                        sequence_workflow=wildcards.sequence_workflow,
                        tag=wildcards.tag,
                        runname=[runname for runname in config['runnames']],
                        reference=wildcards.reference)

# sniffles sv detection
rule sniffles:
    input:
        "alignments/{aligner}/{sequence_workflow}/{tag}.{reference}.bam"
    output:
        temp("sv/sniffles/{aligner, [^.\/]*}/{sequence_workflow}/{tag, [^.\/]*}.{reference, [^.\/]*}.vcf")
    shadow: "minimal"
    threads: config['threads_sv']
    resources:
        mem_mb = lambda wildcards, threads, attempt: int((1.0 + (0.1 * (attempt - 1))) * (8000 + 1000 * threads)),
        time_min = lambda wildcards, threads, attempt: int((3840 / threads) * attempt)   # 240 min / 16 threads
    singularity:
        "docker://nanopype/sv:{tag}".format(tag=config['version']['tag'])
    shell:
        """
        {config[bin_singularity][sniffles]} -m {input} -v {output} -t {threads} {config[sv_sniffles_flags]}
        """

# compress vcf file
rule sv_compress:
    input:
        "sv/sniffles/{aligner}/{sequence_workflow}/{tag}.{reference}.vcf"
    output:
        "sv/sniffles/{aligner, [^.\/]*}/{sequence_workflow, [^.\/]*}/{tag, [^.\/]*}.{reference, [^.\/]*}.vcf.gz"
    threads: 1
    singularity:
        "docker://nanopype/sv:{tag}".format(tag=config['version']['tag'])
    shell:
        """
        cat {input} | gzip > {output}
        """

rule strique:
    input:
        index = lambda wildcards : os.path.join(config['storage_data_raw'], wildcards.runname, 'reads.fofn'),
        bam = lambda wildcards : get_alignment_batch(wildcards, config),
        config = lambda wildcards : config['sv_STRique_config']
    output:
        "sv/strique/{aligner, [^\/]*}/{sequence_workflow, ((?!batches).)*}/batches/{tag, [^\/]*}/{runname, [^\/]*}/{batch, [^.\/]*}.{reference}.tsv"
    threads: 1
    singularity:
        "docker://nanopype/sv:{tag}".format(tag=config['version']['tag'])
    shell:
        """

        """

rule strique_merge_batches:
    input:
        get_batches_strique
    output:
        "sv/strique/{aligner, [^\/]*}/{sequence_workflow}/batches/{tag, [^\/]*}/{runname, [^.\/]*}.{reference}.tsv"
    shell:
        """
        
        """

rule strique_merge_tag:
    input:
        get_batches_strique2
    output:
        "sv/strique/{aligner, [^\/]*}/{sequence_workflow, ((?!batches).)*}/{tag, [^\/]*}.{reference}.tsv"
    shell:
        """
        
        """