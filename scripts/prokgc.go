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
var inputGenome = flag.String("gen", "tmp.genome", "Input Genome")
var inputCds = flag.String("cds", "-", "Input CDS containing file, defaults to STDIN")
var output = flag.String("o", "-", "Output file, defaults to STDOUT")
var header = flag.Bool("header", false, "print CSV header, defaults to None.")

func main() {
	flag.Parse()

	// use buffered out stream for output
	outfh, err := xopen.Wopen(*output) // "-" for STDOUT
	checkError(err)
	defer outfh.Close()

	// Deal with whole genome
	readerGenome, err := fastx.NewReader(seq.DNA, *inputGenome, `\|([^\|]+)\| `)
	checkError(err)

	nChr := 0
	genomeLength := 0
	var genomeNContent []float64
	var genomeGc []float64

	// disable sequence validation could reduce time when reading large sequences
	seq.ValidateSeq = false

	for {
		record, err := readerGenome.Read()
		if err != nil {
			if err == io.EOF {
				break
			}
			checkError(err)
			break
		}

		nChr++
		genomeLength += record.Seq.Length()
		genomeGc = append(genomeGc, record.Seq.GC())
		genomeNContent = append(genomeNContent, record.Seq.BaseContent("N"))
	}

	// Deal with CDS coding file
	reader, err := fastx.NewDefaultReader(*inputCds)
	checkError(err)

	nvalidSeq := 0
	cumLen := 0
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

		seqLen := record.Seq.Length()
		gcRec := record.Seq.GC()
		sequence := record.Seq.Seq
		lastCodon := string(sequence)[seqLen-3:]
		goodLastCodon, _ := regexp.MatchString("TAA|TAG|TGA", lastCodon)

		var gc1Rec []byte
		for i := 0; i < seqLen-2; i += 3 {
			gc1Rec = append(gc1Rec, sequence[i])
		}

		var gc2Rec []byte
		for i := 1; i < seqLen-2; i += 3 {
			gc2Rec = append(gc2Rec, sequence[i])
		}

		var gc3Rec []byte
		for i := 2; i < seqLen-2; i += 3 {
			gc3Rec = append(gc3Rec, sequence[i])
		}

		var gc1Rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc1Rec)
		var gc2Rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc2Rec)
		var gc3Rec, _ = fastx.NewRecord(seq.DNA, record.ID, record.Name, gc3Rec)

		// TODO filter out sequences with wrong ending codons
		if seqLen%3 == 0 && goodLastCodon {
			nvalidSeq += 1
			cumLen += seqLen
			seqlen = append(seqlen, float64(seqLen))
			gc = append(gc, gcRec)
			gc1 = append(gc1, gc1_rec.Seq.GC())
			gc2 = append(gc2, gc2Rec.Seq.GC())
			gc3 = append(gc3, gc3_rec.Seq.GC())
		}
		nseq++
	}

	if *header {
		outfh.WriteString("taxid,nChr,genomeLength,N_content,genomeGc,gc,gc1,gc2,gc3,meanlen,cumLen,nvalidSeq,nseq\n")
	}

	outfh.WriteString(fmt.Sprintf("%s,", strings.Trim(string(*taxid), "\n")))
	outfh.WriteString(fmt.Sprintf("%d,%d,%f,%f,", nChr, genomeLength, mean(genomeNContent), mean(genomeGc)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc1)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc2)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(gc3)))
	outfh.WriteString(fmt.Sprintf("%f,", mean(seqlen)))
	outfh.WriteString(fmt.Sprintf("%d,", cumLen))
	outfh.WriteString(fmt.Sprintf("%d,", nvalidSeq))
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
