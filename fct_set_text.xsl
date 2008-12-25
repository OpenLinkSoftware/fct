

<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

<xsl:param name="pos"/>
<xsl:param name="op"/>
<xsl:param name="type"/>
<xsl:param name="limit"/>
<xsl:param name="offset"/>
<xsl:param name="iri"/>
<xsl:param name="name"/>



    <xsl:template match = "query">
<xsl:copy>
<xsl:element name="text">
<xsl:if test="not ($prop='none')">
<xsl:attribute name="property"><xsl:value-of select="$prop"/></xsl:attribute>
</xsl:if>
<xsl:value-of select="$text" />
</xsl:element>
<xsl:apply-templates select="@* | node()" />
</xsl:copy>
</xsl:template>

<xsl:template match="text">
</xsl:template>
 

<xsl:template match="@* | node()">
<xsl:copy>
<xsl:apply-templates select="@* | node()"/>
</xsl:copy>
</xsl:template>

</xsl:stylesheet>





