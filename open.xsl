<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:template match = "result">

<a href="/fct/facet.vsp?cmd=refresh&sid={$sid}">Return to facets</a>
<br/>
<table>
	<xsl:for-each select="row">
<tr>
<td><xsl:value-of select="column[1]"/></td>
<td><xsl:value-of select="column[2]"/></td>
<td>
<xsl:choose>
<xsl:when test="'url' = column[3]/@datatype">
<a><xsl:attribute name="href">/fct/facet.vsp?cmd=open&amp;iri=<xsl:value-of select="urlify (column[3])"/>&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute><xsl:value-of select="column[3]"/></a>
</xsl:when>
<xsl:otherwise><xsl:value-of select="column[3]"/></xsl:otherwise>
</xsl:choose>
</td>
</tr>
<xsl:text>
</xsl:text>
</xsl:for-each>
</table>
</xsl:template>
</xsl:stylesheet>



