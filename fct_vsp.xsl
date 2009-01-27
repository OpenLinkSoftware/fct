<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version ="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match = "facets">

<div id="res">
<!--xsl:choose>
  <xsl:when test="$type = 'text'"><h3>Text match results</h3></xsl:when>
  <xsl:when test="$type = 'text-properties'"><h3>List of Properties With Matching Text</h3></xsl:when>
  <xsl:when test="$type = 'classes'"><h3>Types</h3></xsl:when>
  <xsl:when test="$type = 'properties'"><h3>Properties</h3></xsl:when>
  <xsl:when test="$type = 'properties-in'"><h3>Referencing Properties</h3></xsl:when>
  <xsl:when test="$type = 'list'"><h3>List</h3></xsl:when>
  <xsl:when test="$type = 'list-count'"><h3>Distinct values</h3></xsl:when>
  <xsl:when test="$type = 'geo'"><h3>Location</h3></xsl:when>
</xsl:choose-->
<!--xsl:message terminate="no"><xsl:value-of select="$type"/></xsl:message-->
<xsl:choose>
    <xsl:when test="$type = 'geo'">
	<script type="text/javascript" ><![CDATA[
		OAT.Preferences.imagePath = "oat/images/";
		function init(){
			var callback = function(commonMapObj) {
				var click = function (href, label) {
				    return function(marker) {
                                           var x;
					   if (href.length > 0) {
					     x = OAT.Dom.create ("a");
					     x.href = '/about/?url='+escape (href);
					     if (label.length > 0)
				               x.innerHTML = label;
					     else
				               x.innerHTML = href;
					   }
				           else
				             x = OAT.Dom.text(label);
				           commonMapObj.openWindow (marker, x);
					}
				  }
				window.m = commonMapObj;
				commonMapObj.centerAndZoom(0,0,0);
				commonMapObj.addTypeControl();
				commonMapObj.addMapControl();
				commonMapObj.setMapType(OAT.MapData.MAP_HYB);

				var markersArr = []; ]]>
				<xsl:for-each select="result/row">
				    commonMapObj.addMarker(1,<xsl:value-of select="column[3]"/>,<xsl:value-of select="column[4]"/>,
				    "oat/images/markers/01.png",18,41,
				    	click ("<xsl:value-of select="column[1]"/>", "<xsl:value-of select="column[2]"/>"));
				    markersArr.push([<xsl:value-of select="column[3]"/>,<xsl:value-of select="column[4]"/>]);
			        </xsl:for-each>

				<![CDATA[
				commonMapObj.optimalPosition(markersArr);
				return;
			}
			window.YMAPPID = "";

			var providerType = OAT.MapData.TYPE_Y;
			var containerDiv = document.getElementById('user_map');
			var map = new OAT.Map(containerDiv,providerType,{fix:OAT.MapData.FIX_ROUND1});
			map.loadApi(providerType, callback);
		}
	]]></script>
      <div id="user_map" style="position:relative; width:600px; height:400px;"></div>
    </xsl:when>
    <xsl:otherwise>
      
      <xsl:choose>
	<xsl:when test="count (/facets/result) &gt; 1">
	  <xsl:for-each select="result[@type = 'classes' or @type = 'properties']">
	    <div class="facet_ctr">
	      <xsl:choose>
		<xsl:when test="@type='properties'">
		  <h4 class="facet_hd">Properties</h4>
		</xsl:when>
		<xsl:otherwise>
		  <h4 class="facet_hd">Types</h4>
		</xsl:otherwise>
	      </xsl:choose>
	      <div class="facet">
		<xsl:call-template name="render-result">
		  <xsl:with-param name="view-type"><xsl:value-of select="@type"/></xsl:with-param>
		  <xsl:with-param name="command">
		    <xsl:choose>
		      <xsl:when test="@type = 'classes'">set_class</xsl:when>
		      <xsl:when test="@type = 'properties'">open_property</xsl:when>
		      <xsl:otherwise><xsl:value-of select="$cmd"/></xsl:otherwise>
		    </xsl:choose>
		  </xsl:with-param>
		</xsl:call-template>
	      </div>
	    </div> <!-- facet_ctr -->
	  </xsl:for-each>
	  <xsl:for-each select="/facets/result [@type != 'classes' and @type != 'properties']">
	    <xsl:call-template name="render-result">
	      <xsl:with-param name="view-type"><xsl:value-of select="$type"/></xsl:with-param>
	      <xsl:with-param name="command">
		<xsl:choose>
		  <xsl:when test="@type = 'classes'">set_class</xsl:when>
		  <xsl:when test="@type = 'properties'">open_property</xsl:when>
		  <xsl:otherwise><xsl:value-of select="$cmd"/></xsl:otherwise>
		</xsl:choose>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:for-each>
	  <div id="sparql_link">
	    <a class="sparql_link" href="sparql.vsp?q={urlify (/facets/sparql)}">SPARQL</a>
	  </div>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:for-each select="/facets/result">
	    <xsl:call-template name="render-result">
	      <xsl:with-param name="view-type"><xsl:value-of select="$type"/></xsl:with-param>
	      <xsl:with-param name="command">
		<xsl:choose>
		  <xsl:when test="@type = 'classes'">set_class</xsl:when>
		  <xsl:when test="@type = 'properties'">open_property</xsl:when>
		  <xsl:otherwise><xsl:value-of select="$cmd"/></xsl:otherwise>
		</xsl:choose>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:for-each>
	</xsl:otherwise>
      </xsl:choose>

      <xsl:if test="20 = count (/facets/result[@type='']/row)">
	<div id="pager">
	  <a>
	    <xsl:attribute name="class">pager</xsl:attribute>
	    <xsl:attribute name="href">/fct/facet.vsp?cmd=next&amp;sid=<xsl:value-of select="$sid"/>
	    </xsl:attribute>&#10140;Next page
	  </a>
	</div> <!-- #pager -->
      </xsl:if>
    </xsl:otherwise>
</xsl:choose>
<div id="result_nfo">
  <xsl:choose>
    <xsl:when test="/facets/complete = 'yes'">Complete results in </xsl:when>
    <xsl:otherwise>
      Partial results
      <a href="/fct/facet.vsp?cmd=refresh&amp;sid={$sid}&amp;timeout={$timeout}">Retry with <xsl:value-of select="($timeout div 1000)"/> seconds timeout</a>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="/facets/time"/> msec. Resource utilization:
  <xsl:value-of select="/facets/db-activity"/>
</div> <!-- #result_nfo -->
</div> <!-- #res -->
</xsl:template>

<xsl:template name="render-result">
<table class="result">
  <thead>
    <xsl:choose>
      <xsl:when test="$view-type = 'properties'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Property</th><th></th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'list-count'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Entity</th><th>Title</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'text-properties'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Property</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'properties-in'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Property</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'list'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th></th><th></th><th></th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'classes'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Type</th><th>Label</th><th>Count</th></tr>
      </xsl:when>
      <xsl:when test="$view-type = 'text'">
	<div class="dbg"><xsl:value-of select="$view-type"/></div>
	<tr><th>Entity</th><th>Title</th><th>Text excerpt</th></tr>
      </xsl:when>
    </xsl:choose>
  </thead>
  <tbody>
    <xsl:for-each select="row">
      <tr>
	<xsl:choose>
	  <xsl:when test="$view-type = 'properties' or
			  $view-type = 'classes' or
			  $view-type = 'properties-in' or
			  $view-type = 'text-properties' or
			  $view-type = 'list' or
			  $view-type = 'list-count'">
	    <td>
	      <xsl:if test="'url' = column[1]/@dataview-type">
		<a>
		  <xsl:attribute name="href">
		    /about/?url=<xsl:value-of select="urlify (column[1])"/>&amp;sid=<xsl:value-of select="$sid"/>
		  </xsl:attribute>
		  <xsl:attribute name="class">describe</xsl:attribute>
		    Describe
		</a>
	      </xsl:if>
	      <a>
		<xsl:attribute name="href">
		  /fct/facet.vsp?cmd=<xsl:value-of select="$command"/>&amp;iri=<xsl:value-of select="urlify (column[1])"/>&amp;lang=<xsl:value-of select="column[1]/@xml:lang"/>&amp;datatype=<xsl:value-of select="urlify (column[1]/@datatype)"/>&amp;sid=<xsl:value-of select="$sid"/>
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
</xsl:template>

<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>


</xsl:stylesheet>

