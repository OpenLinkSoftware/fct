<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- xmlns:xsl="http://www.w3.org/TR/WD-xsl" -->
<xsl:output method="text"/>
<xsl:template match="facets">
<xsl:for-each select="result/row">
  <xsl:for-each select="column"> 
    <xsl:value-of select="." />  
    <xsl:text></xsl:text>
  </xsl:for-each>
  <xsl:text>
  </xsl:text> 
</xsl:for-each>
<xsl:text> Complete = </xsl:text> <xsl:value-of select="complete"/> 
<xsl:text> Activity = </xsl:text> <xsl:value-of select="db-activity"/>
</xsl:template>
</xsl:stylesheet>

