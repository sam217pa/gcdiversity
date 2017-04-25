package main

import (
	"flag"
	"fmt"
	"io"
	"os"
	"regexp"

	"strings"

	"github.com/shenwei356/bio/seq"
	"github.com/shenwei356/bio/seqio/fastx"
	"github.com/shenwei356/xopen"
)

var taxid = flag.String("t", "-", "TaxID of the strain")
var input_genome = flag.String("gen", "tmp.genome", "Input Genome")
var input_cds = flag.String("cds", "-", "Input CDS containing file, defaults to STDIN")
var output = flag.String("o", "-", "Output file, defaults to STDOUT")
var header = flag.Bool("header", false, "print CSV header, defaults to None.")

func main() {
	flag.Parse()

	// use buffered out stream for output
	outfh, err := xopen.Wopen(*output) // "-" for STDOUT
	checkError(err)
	defer outfh.Close()

	// Deal with whole genome
	reader_genome, err := fastx.NewReader(seq.DNA, *input_genome, `\|([^\|]+)\| `)
	checkError(err)

	n_chr := 0
	genome_length := 0
	var genome_N_content []float64
	var genome_gc []float64

	// disable sequence validation could reduce time when reading large sequences
	seq.ValidateSeq = false

	for {
		record, err := reader_genome.Read()
		if err != nil {
			if err == io.EOF {
				break
			}
			checkError(err)
			break
		}

		n_chr++
		genome_length += record.Seq.Length()
		genome_gc = append(genome_gc, record.Seq.GC())
		genome_N_content = append(genome_N_content, record.Seq.BaseContent("N"))
	}

	// Deal with CDS coding file
	reader, err := fastx.NewDefaultReader(*input_cds)
	checkError(err)

	nvalid_seq := 0
	cumlen := 0
	nseq := 0
	var seqlen []float64
	var gc []float64
	var gc1 []float64
	var gc2 []float64
	var gc3 []float64

	for {
		record, err := reader.Read()
		if err != nil {
			if err == io.EOF {
				break
			}
			checkError(err)
			break
		}

		seq_len := record.Seq.Length()
		gc_rec := record.Seq.GC()
		sequence := record.Seq.Seq
		last_codon := string(sequence)[seq_len-3:]
		good_last_codon, _ := regexp.MatchString("TAA|TAG|TGA", last_codon)

		var gc_1_rec []byte
		for i := 0; i < seq_len-2; i += 3 {
			gc_1_rec = append(gc_1_rec, sequence[i])
		}

		var gc_2_rec []byte
		for i := 1; i < seq_len-2; i += 3 {
			gc_2_rec = append(gc_2_rec, sequence[i])
		}

		var gc_3_rec []byte
		for i := 2; i < seq_len-2; i += 3 {
			gc_3_rec = append(gc_3_rec, sequence[i])
		}

		var gc1_rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc_1_rec)
		var gc2_rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc_2_rec)
		var gc3_rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc_3_rec)

		// TODO filter out sequences with wrong ending codons
		if seq_len%3 == 0 && good_last_codon {
			nvalid_seq += 1
			cumlen += seq_len
			seqlen = append(seqlen, float64(seq_len))
			gc = append(gc, gc_rec)
			gc1 = append(gc1, gc1_rec.Seq.GC())
			gc2 = append(gc2, gc2_rec.Seq.GC())
			gc3 = append(gc3, gc3_rec.Seq.GC())
		}
		nseq++
	}

	if *header {
		outfh.WriteString("taxid,n_chr,genome_length,N_content,genome_gc,gc,gc1,gc2,gc3,meanlen,cumlen,nvalid_seq,nseq\n")
	}

	outfh.WriteString(fmt.Sprintf("%s,", strings.Trim(string(*taxid), "\n")))
	outfh.WriteString(fmt.Sprintf("%d,%d,%f,%f,", n_chr, genome_length, mean(genome_N_content), mean(genome_gc)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc1)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc2)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc3)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(seqlen)))
	outfh.WriteString(fmt.Sprintf("%d,", cumlen))
	outfh.WriteString(fmt.Sprintf("%d,", nvalid_seq))
	outfh.WriteString(fmt.Sprintf("%d\n", nseq))

}

func mean(x []float64) float64 {
	var sum float64 = 0
	n := len(x)

	for _, value := range x {
		sum += value
	}
	return sum / float64(n)
}

func checkError(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
