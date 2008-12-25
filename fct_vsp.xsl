
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
    <xsl:output method="html"/>
    <xsl:template match = "facets">

<table>
	<xsl:for-each select="result/row">
<tr>
<xsl:choose>
<xsl:when test="$type = 'properties'">
<td>
<a><xsl:attribute name="href">/fct/facet.vsp?cmd=<xsl:value-of select="$cmd"/>&amp;iri=<xsl:value-of select="urlify (column[1])"/>&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>
<xsl:value-of select="column[1]"/>
</a></td>
<td><xsl:value-of select="column[2]"/></td>
<td><xsl:value-of select="column[3]"/></td>
</xsl:when>
<xsl:otherwise>
	<xsl:for-each select="column"> 
<td><xsl:value-of select="."/></td>
</xsl:for-each>
</xsl:otherwise>
</xsl:choose>
</tr>
<xsl:text>
</xsl:text>
</xsl:for-each>
</table>
<br/><br/>
<xsl:if test="20 = count (/facets/result/row)">
<a><xsl:attribute name="href">/fct/facet.vsp?cmd=next&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>Next page</a>
<br/><br/>
</xsl:if>


<xsl:choose>
<xsl:when test="/facets/complete = 'yes'">Complete results</xsl:when>
<xsl:otherwise>Partial results</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="/facets/time"/> msec.  Resource utilization: 
<xsl:value-of select="/facets/db-activity"/>
<br/><br/>



</xsl:template>
</xsl:stylesheet>

