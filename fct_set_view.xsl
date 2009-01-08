<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="pos"/>
<xsl:param name="op"/>
<xsl:param name="type"/>
<xsl:param name="limit"/>
<xsl:param name="offset"/>
<xsl:param name="iri"/>
<xsl:param name="name"/>
<xsl:param name="timeout"/>

<xsl:template match = "query | property |property-of">

<xsl:if test="not ($op = 'close') or not ($pos = count (./ancestor::*[name () = 'query' or name () = 'property' or name () = 'property-of']) + count (./preceding::*[name () = 'query' or name () = 'property' or name () = 'property-of']))">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" />
    <xsl:if test="$op = 'view' and $pos = count (./ancestor::*[name () = 'query' or name () = 'property' or name () = 'property-of']) + count (./preceding::*[name () = 'query' or name () = 'property' or name () = 'property-of'])">
      <xsl:element name="view">
        <xsl:attribute name="type"> 
          <xsl:choose> 
            <xsl:when test="'list' = $type and ./text">text</xsl:when>
            <xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="limit"> <xsl:value-of select="$limit"/></xsl:attribute>
        <xsl:attribute name="offset"> <xsl:value-of select="$offset"/></xsl:attribute>
      </xsl:element>
</xsl:if>
<xsl:if test="$op = 'prop' and $pos = count (./ancestor::*[name () = 'query' or name () = 'property' or name () = 'property-of']) + count (./preceding::*[name () = 'query' or name () = 'property' or name () = 'property-of'])">
<xsl:element name="{$name}">
<xsl:attribute name="iri"><xsl:value-of select="$iri"/></xsl:attribute>
<xsl:element name="view">
<xsl:attribute name="type"> <xsl:value-of select="$type"/></xsl:attribute>
<xsl:attribute name="limit"> <xsl:value-of select="$limit"/></xsl:attribute>
<xsl:attribute name="offset"> <xsl:value-of select="$offset"/></xsl:attribute>
</xsl:element>
</xsl:element>
</xsl:if>
<xsl:if test="$op = 'class' and $pos = count (./ancestor::*[name () = 'query' or name () = 'property' or name () = 'property-of']) + count (./preceding::*[name () = 'query' or name () = 'property' or name () = 'property-of'])">
<class iri="{$iri}"/>
</xsl:if>
<xsl:if test="$op = 'value' and $pos = count (./ancestor::*[name () = 'query' or name () = 'property' or name () = 'property-of']) + count (./preceding::*[name () = 'query' or name () = 'property' or name () = 'property-of'])">
<value xml:lang="{$lang}" datatype="{$datatype}" op="{$cmp}" ><xsl:value-of select="$iri"/></value>
</xsl:if>

</xsl:copy>
</xsl:if>
</xsl:template>

<xsl:template match="view">
<xsl:if test="'class' = $op or 'value' = $op">
<xsl:copy>
<xsl:apply-templates select="@* | node()" />
</xsl:copy>
</xsl:if>
</xsl:template>
 

<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
