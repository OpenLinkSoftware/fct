<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

<xsl:template match = "facets">

<div id="res">
<h3>Results</h3>

<table>
  <xsl:choose>
    <xsl:when test="$type = 'properties'">
      <tr><th>URI</th><th></th><th>NUM</th></tr>
    </xsl:when>
  </xsl:choose>
  <xsl:for-each select="result/row">
    <tr>
      <xsl:choose>
        <xsl:when test="$type = 'properties'">
          <td>
            <xsl:if test="'url' = column[1]/@datatype">
              <a>
		<xsl:attribute name="href">/about/?url=<xsl:value-of select="urlify (column[1])"/>&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>Describe
              </a><xsl:text>&#160;</xsl:text>
            </xsl:if>
            <a>
	      <xsl:attribute name="href">
                /fct/facet.vsp?cmd=<xsl:value-of select="$cmd"/>&amp;iri=<xsl:value-of select="urlify (column[1])"/>&amp;lang=<xsl:value-of select="column[1]/@xml:lang"/>&amp;datatype=<xsl:value-of select="column[1]/@datatype"/>&amp;sid=<xsl:value-of select="$sid"/>
              </xsl:attribute>
	      <xsl:attribute name="title">
		<xsl:value-of select="column[1]"/>
	      </xsl:attribute>
	      <xsl:choose>
		<xsl:when test="'' != column[1]/@shortform">
		  <xsl:value-of select="column[1]/@shortform"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="column[1]"/>
		</xsl:otherwise>
	      </xsl:choose>
            </a>
          </td>
          <td>
	    <xsl:choose>
	      <xsl:when test="'' != ./@shortform"><xsl:value-of select="./@shortform"/></xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="column[2]"/>
	      </xsl:otherwise>
	    </xsl:choose>
          </td>
          <td>
            <xsl:apply-templates select="column[3]"/>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="column"> 
            <td>
              <xsl:choose>
		<xsl:when test="'url' = ./@datatype">
		  <a>
                    <xsl:attribute name="href">/about/?url=<xsl:value-of select="urlify (.)"/></xsl:attribute>
		    <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
                    <xsl:choose>
		      <xsl:when test="'' != ./@shortform"><xsl:value-of select="./@shortform"/></xsl:when>
		      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		    </xsl:choose>
		  </a>
		</xsl:when>
		<xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
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
    <xsl:attribute name="href">/fct/facet.vsp?cmd=next&amp;sid=<xsl:value-of select="$sid"/></xsl:attribute>
    Next page
  </a>
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

<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>


</xsl:stylesheet>

