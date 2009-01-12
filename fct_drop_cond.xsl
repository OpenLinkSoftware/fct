<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="pos"/>
<xsl:param name="op"/>
<xsl:param name="type"/>
<xsl:param name="limit"/>
<xsl:param name="offset"/>
<xsl:param name="iri"/>
<xsl:param name="name"/>
<xsl:param name="timeout"/>
<xsl:param name="cno"/>


<xsl:template match = "class | value">

  <xsl:if test="$cno != count (./ancestor::*[name () = 'class' or
	                                     name () = 'value']) +
                      count (./preceding::*[name () = 'class' or 
                                            name () = 'value'])">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:if>
</xsl:template>
 
<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
