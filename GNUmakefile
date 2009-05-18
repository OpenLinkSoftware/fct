#
#  $Id$
#
#  (C)Copyright 2009 OpenLink Software.
#  All Rights Reserved.
#
#  The copyright above and this notice must be preserved in all
#  copies of this source code.  The copyright above does not
#  evidence any actual or intended publication of this source code.
#
#  This is unpublished proprietary trade secret of OpenLink Software.
#  This source code may not be copied, disclosed, distributed, demonstrated
#  or licensed except as authorized by OpenLink Software.
#

TARGETS	= fct_dav.vad 

DEPS	= \
	*.html \
	*.js \
	*.sql \
	*.txt \
	*.vsp \
	*.xsl \
	GNUmakefile \
	images/*.gif \
	images/*.png \
	images/*.svg \
	make_vad.sh \
	rdfdesc/*.sql \
	rdfdesc/*.vsp \
	s/*.js \
	styles/*.css \
	VirtTripleLoader/.classpath \
	VirtTripleLoader/.project \
	VirtTripleLoader/src/virtTripleLoaderInit/*.java \
	www/*.css \
	www/*.html \
	www/*.sql \
	www/*.vsp

.PHONY: all
all: $(TARGETS)
	[ -d ../../vad ] || mkdir ../../vad
	ln -f fct_dav.vad ../../vad/fct_dav.vad
	
fct_dav.vad: $(DEPS)
	@./make_vad.sh

.PHONY: clean
clean:
	$(RM) o $(TARGETS) 
	rm -f fct_dav.vad fct_filesystem.vad vad.db vad.trx vad.log make_*_vad.log make_*_vad.xml vad_*.xml
	rm -f virtuoso.pxa
	rm -rf vad
