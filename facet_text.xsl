


<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
    <xsl:output method="text"/>
    <xsl:template match = "facets">

	<xsl:for-each select="result/row">
	<xsl:for-each select="column"> 
<xsl:value-of select="." />  
<xsl:text>	</xsl:text>
</xsl:for-each>
<xsl:text>
</xsl:text> 
</xsl:for-each>

    </xsl:template>
</xsl:stylesheet>

