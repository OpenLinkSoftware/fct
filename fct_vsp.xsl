<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:template match = "facets">

<div id="res">
<h3>Results</h3>
<table>
  <xsl:for-each select="result/row">
    <tr>
      <xsl:choose>
        <xsl:when test="$type = 'properties'">
          <td>
            <xsl:if test="'url' = column[1]/@datatype">
              <a>
		<xsl:attribute name="href">/about/?url=<xsl:value-of select="urlify (column[1])"/>&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>open
              </a>&#160;
            </xsl:if>
            <a><xsl:attribute name="href">/fct/facet.vsp?cmd=<xsl:value-of select="$cmd"/>&amp;iri=<xsl:value-of select="urlify (column[1])"/>&amp;lang=<xsl:value-of select="column[1]/@xml:lang"/>&amp;datatype=<xsl:value-of select="column[1]/@datatype"/>&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute><xsl:value-of select="column[1]"/></a>
          </td>
          <td>
            <xsl:value-of select="column[2]"/>
          </td>
          <td>
            <xsl:value-of select="column[3]"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="column"> 
            <td>
              <xsl:choose>
		<xsl:when test="'url' = ./@datatype">
		  <a>
                    <xsl:attribute name="href">/about/?url=<xsl:value-of select="urlify (.)"/></xsl:attribute>
                    <xsl:choose>
		      <xsl:when test="'' != ./@shortform"><xsl:value-of select="./@shortform"/></xsl:when>
		      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		    </xsl:choose>
		  </a>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
	      </xsl:choose>
            </td>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
    <xsl:text></xsl:text>
  </xsl:for-each>
</table>

<xsl:if test="20 = count (/facets/result/row)">
  <a>
    <xsl:attribute name="href">/fct/facet.vsp?cmd=next&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>Next page</a>
</xsl:if>

<div id="result_nfo">
  <xsl:choose>
    <xsl:when test="/facets/complete = 'yes'">Complete results in </xsl:when>
    <xsl:otherwise>Partial results <a href="/fct/facet.vsp?cmd=refresh&amp;sid={$sid}&amp;timeout={2*$timeout}">Retry with X timeout</a></xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="/facets/time"/> msec. Resource utilization: 
  <xsl:value-of select="/facets/db-activity"/>
</div> <!-- #result_nfo -->
</div> <!-- #res -->
</xsl:template>
</xsl:stylesheet>

