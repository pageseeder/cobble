<?xml version="1.0"?>
<!--
  Converts XSLT documentation into HTML.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:xf="http://weborganic.org/XSLT/Documentation"
                              exclude-result-prefixes="#all">

<!-- Specific documentation style sheet -->
<xsl:import href="html-schematrondoc.xsl"/>
<xsl:import href="html-xsltdoc.xsl"/>

<!-- Cobble version passed -->
<xsl:param name="cobble-version" select="'dev'"/>

<!-- General Output properties. -->
<xsl:output method="html" encoding="utf-8" indent="yes" undeclare-prefixes="no" media-type="text/html"/>

<!--
  Main template called in all cases.

  It provides the basic structure for HTML5 and loads the scripts and styles automatically from the bundler.
-->
<xsl:template match="/">
<!-- Display the HTML Doctype -->
<xsl:text disable-output-escaping="yes"><![CDATA[<!doctype html>
]]></xsl:text>
<html>
<head>
  <title>Cobble documentation</title>
  <!-- 
  <link href="//fonts.googleapis.com/css?family=Open+Sans:400,300,600&amp;subset=latin,latin-ext" rel="stylesheet" type="text/css"/>
   -->
  <link rel="stylesheet" href="cobble.css"></link>
</head>
<body>
  <header id="cobble-header" role="banner">
    <div class="center">
      <h1><xsl:value-of select="if (schematrondoc) then 'Schematron' else 'XSLT'"/> Documentation</h1>
    </div>
  </header>
  <!-- Generate the navigation if any -->
  <xsl:variable name="nav">
    <xsl:apply-templates mode="cobble-nav"/>
  </xsl:variable>
  <xsl:if test="$nav">
    <div id="cobble-nav" role="navigation">
	    <div class="center">
	      <xsl:sequence select="$nav"/>
	    </div>
    </div>
  </xsl:if>
  <!-- Generate the main content-->
  <div id="cobble-main" role="main">
    <div class="center">
	    <xsl:apply-templates mode="cobble-doc"/>
	  </div>
  </div>
  <!-- Footer -->
  <footer id="cobble-footer" role="contentinfo">
    <div class="center"><p>Documentation generated with <a href="http://pageseeder.org/code/cobble">cobble <xsl:value-of select="$cobble-version"/></a></p></div>
  </footer>
  <script src="jquery-1.10.2.min.js" />
  <script src="cobble.js" />
</body>
</html>
</xsl:template>

</xsl:stylesheet>
