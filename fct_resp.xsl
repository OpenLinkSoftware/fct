<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fct="http://openlinksw.com/services/facets/1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" cdata-section-elements="fct:column"/>

    <xsl:template match="*">
	<xsl:element name="{local-name ()}" namespace="http://openlinksw.com/services/facets/1.0">
	    <xsl:copy-of select="@*"/>
	    <xsl:apply-templates/>
	</xsl:element>
    </xsl:template>

    <xsl:template match="column">
	<xsl:element name="{local-name ()}" namespace="http://openlinksw.com/services/facets/1.0">
	    <xsl:copy-of select="@*"/>
	    <xsl:apply-templates mode="raw"/>
	</xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="raw">
	<xsl:value-of select="serialize (.)"/>
    </xsl:template>

    <xsl:template match="text()" mode="raw">
	<xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
