package main

import (
	"fmt"
	"io"
	"os"

	"github.com/shenwei356/bio/seq"
	"github.com/shenwei356/bio/seqio/fastx"
	"github.com/shenwei356/xopen"
)

func main() {
	// use buffered out stream for output
	outfh, err := xopen.Wopen("-") // "-" for STDOUT
	checkError(err)
	defer outfh.Close()

	reader, err := fastx.NewDefaultReader("-")
	checkError(err)

	nvalid_seq := 0
	cumlen := 0
	nseq := 0
	var seqlen []int
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
		if seq_len%3 == 0 {
			nvalid_seq += 1
			cumlen += seq_len
			seqlen = append(seqlen, seq_len)
			gc = append(gc, gc_rec)
			gc1 = append(gc1, gc1_rec.Seq.GC())
			gc2 = append(gc2, gc2_rec.Seq.GC())
			gc3 = append(gc3, gc3_rec.Seq.GC())
		}
		nseq++
	}

	var mean_gc float64 = 0
	for _, value := range gc {
		mean_gc += value
	}

	var mean_gc1 float64 = 0
	for _, value := range gc1 {
		mean_gc1 += value
	}

	var mean_gc2 float64 = 0
	for _, value := range gc2 {
		mean_gc2 += value
	}

	var mean_gc3 float64 = 0
	for _, value := range gc3 {
		mean_gc3 += value
	}

	var mean_len int = 0
	for _, value := range seqlen {
		mean_len += value
	}

	fmt.Println("gc,gc1,gc2,gc3,meanlen,cumlen,nvalid_seq,nseq")
	fmt.Printf("%f,", mean_gc/float64(len(gc)))
	fmt.Printf("%f,", mean_gc1/float64(len(gc1)))
	fmt.Printf("%f,", mean_gc2/float64(len(gc2)))
	fmt.Printf("%f,", mean_gc3/float64(len(gc3)))
	fmt.Printf("%f,", float64(mean_len)/float64(len(seqlen)))
	fmt.Printf("%d,", cumlen)
	fmt.Printf("%d,", nvalid_seq)
	fmt.Printf("%d\n", nseq)
}

func checkError(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
