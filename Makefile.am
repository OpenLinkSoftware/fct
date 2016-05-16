FCT_STICKER	= fct_sticker.xml
FCT_FILES	= \
	*.html \
	*.js \
	*.owl \
	*.sql \
	*.txt \
	*.vsp \
	*.xml \
	*.xsl \
	images/*.gif \
	images/*.png \
	images/*.svg \
	rdfdesc/*.sql \
	rdfdesc/*.vsp \
	s/*.js \
	styles/*.css \
	styles/images/*.png \
	vad_version \
	VirtTripleLoader/.classpath \
	VirtTripleLoader/.project \
	VirtTripleLoader/src/virtTripleLoaderInit/*.java \
	www/*.css \
	www/*.html \
	www/*.sql \
	www/*.vsp

VERSION=`./gen_version.sh`
NEED_VERSION=06.00.3117

vad_DATA = fct_dav.vad

fct_dav.vad: $(FCT_FILES) $(FCT_STICKER) Makefile vad_version
	@PYTHON@ @VADPACKER@ -o fct_dav.vad \
		--var="VERSION=$(VERSION)" \
		--var="BASE_PATH=/DAV/VAD" \
		--var="TYPE=dav" \
		--var="ISDAV=1" \
		--var="NEED_VERSION=$(NEED_VERSION)" \
		$(FCT_STICKER)


CLEANFILES = *.vad

EXTRA_DIST = $(FCT_FILES) $(FCT_STICKER)
