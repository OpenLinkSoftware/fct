FCT_STICKER	= fct_sticker.xml
FCT_FILES	= \
	*.html \
	js/*.js \
	owl/*.owl \
	sql/*.sql \
	*.txt \
	*.vsp \
	*.xml \
	xslt/*.xsl \
	images/*.gif \
	images/*.png \
	images/*.svg \
	rdfdesc/*.vsp \
	css/*.css \
	fontawesome/css/* \
	fontawesome/js/* \
	fontawesome/less/* \
	fontawesome/metadata/* \
	fontawesome/sprites/* \
	fontawesome/svgs/* \
	fontawesome/webfonts/* \
	vad_version \
	VirtTripleLoader/.classpath \
	VirtTripleLoader/.project \
	VirtTripleLoader/src/virtTripleLoaderInit/*.java \
	www/*.html \
	www/*.vsp

VERSION=`./gen_version.sh`
NEED_VERSION=07.20.3226

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
