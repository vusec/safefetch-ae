FILENAME=paper

all: pdf

pdf:
	pdflatex $(FILENAME).tex
	pdflatex $(FILENAME).tex
	pdflatex $(FILENAME).tex

clean:
	rm -f *.out *.blg *.log *.pdf *.aux *.bbl

.PHONY: all pdf
