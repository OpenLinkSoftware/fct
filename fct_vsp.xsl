<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match = "facets">

<div id="res">
<xsl:choose>
  <xsl:when test="$type = 'text'"><h3>Text match results</h3></xsl:when>
  <xsl:when test="$type = 'text-properties'"><h3>List of Properties With Matching Text</h3></xsl:when>
  <xsl:when test="$type = 'classes'"><h3>Types</h3></xsl:when>
  <xsl:when test="$type = 'properties'"><h3>Properties</h3></xsl:when>
  <xsl:when test="$type = 'properties-in'"><h3>Referencing Properties</h3></xsl:when>
  <xsl:when test="$type = 'list'"><h3>List</h3></xsl:when>
  <xsl:when test="$type = 'list-count'"><h3>Distinct values</h3></xsl:when>
</xsl:choose>

<table class="result">
  <thead>
    <xsl:choose>
      <xsl:when test="$type = 'properties'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Property</th><th></th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$type = 'list-count'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Entity</th><th>Title</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$type = 'text-properties'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Property</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$type = 'properties-in'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Property</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$type = 'list'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th></th><th></th><th></th></tr>
      </xsl:when>
      <xsl:when test="$type = 'classes'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Type</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$type = 'text'">
	<div class="dbg"><xsl:value-of select="$type"/></div>
	<tr><th>Entity</th><th>Title</th><th>Text excerpt</th></tr>
      </xsl:when>
    </xsl:choose>
  </thead>
  <tbody>
    <xsl:for-each select="result/row">
      <tr>
	<xsl:choose>
	  <xsl:when test="$type = 'properties' or 
			  $type = 'classes' or
			  $type = 'properties-in' or 
			  $type = 'text-properties' or 
			  $type = 'list' or
			  $type = 'list-count'">
	    <td>
	      <xsl:if test="'url' = column[1]/@datatype">
		<a>
		  <xsl:attribute name="href">
		    /about/?url=<xsl:value-of select="urlify (column[1])"/>&amp;sid=<xsl:value-of select="$sid"/>
		  </xsl:attribute>
		  <xsl:attribute name="class">describe</xsl:attribute>
		    Describe
		</a>&#160;
	      </xsl:if>
	      <a>
		<xsl:attribute name="href">
		  /fct/facet.vsp?cmd=<xsl:value-of select="$cmd"/>&amp;iri=<xsl:value-of select="urlify (column[1])"/>&amp;lang=<xsl:value-of select="column[1]/@xml:lang"/>&amp;datatype=<xsl:value-of select="urlify (column[1]/@datatype)"/>&amp;sid=<xsl:value-of select="$sid"/>
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
  </tbody>
</table>

<xsl:if test="20 = count (/facets/result/row)">
  <div id="pager">
    <a>
      <xsl:attribute name="class">pager</xsl:attribute>
      <xsl:attribute name="href">/fct/facet.vsp?cmd=next&amp;sid=<xsl:value-of select="$sid"/>
      </xsl:attribute>&#10140;Next page
    </a>
  </div> <!-- #pager -->
</xsl:if>

<div id="result_nfo">
  <xsl:choose>
    <xsl:when test="/facets/complete = 'yes'">Complete results in </xsl:when>
    <xsl:otherwise>
      Partial results 
      <a href="/fct/facet.vsp?cmd=refresh&amp;sid={$sid}&amp;timeout=$timeout">Retry with <xsl:value-of select="($timeout div 1000)"/>seconds timeout</a>
    </xsl:otherwise>
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

