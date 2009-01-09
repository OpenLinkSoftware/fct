<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fct="http://openlinksw.com/services/facets/1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:template match="*">
	<xsl:element name="{local-name ()}" namespace="http://openlinksw.com/services/facets/1.0">
	    <xsl:copy-of select="@*"/>
	    <xsl:apply-templates/>
	</xsl:element>
    </xsl:template>
</xsl:stylesheet>
