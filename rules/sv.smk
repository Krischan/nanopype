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

# sniffles sv detection
rule sniffles:
    input:
        "{trackname}.{aligner}.{reference}.bam"
    output:
        "{trackname, [a-zA-Z0-9_-]+}.{aligner}.{reference}.sniffles.vcf"
    shadow: "minimal"
    threads: config['threads_sv']
    params:
        min_support = lambda wildcards : config["sniffles_min_support"] if "sniffles_min_support" in config else 10,
        min_length = lambda wildcards : config["sniffles_min_length"] if "sniffles_min_length" in config else 30,
        min_seq_size = lambda wildcards : config["sniffles_min_seq_size"] if "sniffles_min_seq_size" in config else 2000
    resources:
        mem_mb = lambda wildcards, attempt: int((1.0 + (0.1 * (attempt - 1))) * (8000 + 1000 * threads)),
        time_min = lambda wildcards, threads, attempt: int((3840 / threads) * attempt)   # 240 min / 16 threads
    shell:
        """
        {config[sniffles]} -m {input} -v {output} --genotype -t {threads} -s {params.min_support} -l {params.min_length} -r {params.min_seq_size}
        """
