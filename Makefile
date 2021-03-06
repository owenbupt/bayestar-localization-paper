TEX = pdflatex -file-line-error -halt-on-error
BIBTEX = env BIBINPUTS=:$(CURDIR)/astronat/apj: bibtex

all: ms.pdf

FIGURES = \
	crlb_tau.pdf \
	crlb_gamma.pdf \
	fishfactor.pdf \
	inclination_integral_convergence.pdf \
	polarization_angle_integral_convergence.pdf \
	distance_interpolant_convergence.pdf \
	radial_integrand.pdf \
	runtimes.pdf \
	illustration.pdf \
	radial_integrand.pdf \
	radial_integral_interpolant.pdf \
	autocorr-likelihood.png \
	adaptive_mesh.pdf \
	area-hist.pdf \
	2015-pp.pdf \
	2016-pp.pdf

PREREQS = ms.tex \
	aas_macros.sty \
	ligo-acronyms/acronyms.tex \
	bib/telescope.bib \
	ms.bib \
	$(FIGURES)

TARFILES = \
	combined_ms.tex \
	ms.bbl \
	aas_macros.sty \
	$(FIGURES)

ms.pdf: $(PREREQS)
	$(TEX) -draftmode $(patsubst %.pdf,%,$@)
	$(BIBTEX) $(patsubst %.pdf,%,$@)
	$(TEX) -draftmode $(patsubst %.pdf,%,$@)
	$(TEX) $(patsubst %.pdf,%,$@)

area-hist.pdf: scripts/area-hist.py matplotlibrc
	python $<

adaptive_mesh.pdf: scripts/adaptive_mesh.py matplotlibrc
	python $<

autocorr-likelihood.png: scripts/autocorr-likelihood.py matplotlibrc
	python $<

importance-sampling.pdf: importance-sampling.py
	python $<

radial_integral_interpolant.pdf: scripts/radial_integral_interpolant.py matplotlibrc
	python $<

inclination_integral_convergence.pdf: scripts/inclination_integral_convergence.py matplotlibrc
	python $<

polarization_angle_integral_convergence.pdf: scripts/polarization_angle_integral_convergence.py matplotlibrc
	python $<

distance_interpolant_convergence.pdf: scripts/distance_interpolant_convergence.py matplotlibrc
	python $<

radial_integrand.pdf: scripts/radial_integrand.py matplotlibrc
	python $< $@

autocorrelation_fisher_matrix.json: scripts/autocorrelation_fisher_matrix.py
	python $<

crlb_tau.pdf: scripts/crlb_tau.py matplotlibrc autocorrelation_fisher_matrix.json
	python $<

crlb_gamma.pdf: scripts/crlb_gamma.py matplotlibrc autocorrelation_fisher_matrix.json
	python $<

fishfactor.pdf: scripts/fishfactor.py matplotlibrc autocorrelation_fisher_matrix.json
	python $<

# pp.pdf: scripts/pp.py matplotlibrc 2015_subset/found_injections.out 2016_subset/found_injections.out
# 	python $<

runtimes.pdf: plot_runtimes.py 2015_runtimes.npy 2016_runtimes.npy matplotlibrc
	python $<

combined_ms.tex: ms.pdf
	./latexpand ms.tex --output $@

ms.tar.gz: $(TARFILES) ms.pdf
	COPYFILE_DISABLE=true tar -H -s '/combined_ms/ms/' -czf $@ $(TARFILES)

ms.zip: ms.tar.gz
	mkdir zip && cd zip && tar -xzf ../ms.tar.gz && zip ../ms.zip * && cd .. && rm -rf zip

clean:
	rm -f ms.{aux,log,out,bbl,blg,pdf} msNotes.bib $(FIGURES)
