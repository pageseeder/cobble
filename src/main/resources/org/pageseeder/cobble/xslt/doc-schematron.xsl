<!--
  Stylesheet generating the XSLT documentation in XML format

-->
<xsl:stylesheet version="2.0"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:f="local://functions"
exclude-result-prefixes="#all">

<xsl:output encoding="utf-8" method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:variable name="base" select="replace(base-uri(), '^(.*/)[^/]+', '$1')" as="xs:string"/>

<!-- -->
<xsl:template match="/">
<schematrondoc>
  <xsl:apply-templates select="sch:*"/>
</schematrondoc>
</xsl:template>

<xsl:template match="sch:*">
<xsl:element name="{local-name()}">
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <xsl:apply-templates select="sch:*"/>
</xsl:element>
</xsl:template>

<!-- 
  Title and p are documentation elements and are not documentated.
-->
<xsl:template match="sch:title|sch:p" priority="1">
<xsl:element name="{local-name()}">
  <xsl:copy-of select="@*"/>
  <xsl:value-of select="."/>
</xsl:element>
</xsl:template>

<xsl:template match="sch:assert|sch:report" priority="1">
<xsl:element name="{local-name()}">
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <message><xsl:apply-templates select="sch:*|text()"/></message>
</xsl:element>
</xsl:template>

<!-- FUNCTIONS =================================================================================================== -->

<!--

-->
<xsl:function name="f:get-description">
  <xsl:param name="e" as="element()"/>
  <xsl:variable name="comment" select="$e/preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
  <xsl:if test="$comment">
  <doc>
    <xsl:sequence select="f:analyse-comment($comment)"/>
  </doc>
  </xsl:if>
</xsl:function>

<xsl:function name="f:analyse-comment">
  <xsl:param name="c" as="comment()"/>
  <xsl:variable name="buffer">
	  <xsl:analyze-string regex="@([\w\-]+)\s+(.+)" select="$c">
	    <xsl:matching-substring>
	      <xsl:sequence select="f:analyse-annotation(regex-group(1), regex-group(2))"/>
	    </xsl:matching-substring>
	    <xsl:non-matching-substring>
	      <text><xsl:value-of select="." /></text>
	    </xsl:non-matching-substring>
	  </xsl:analyze-string>
  </xsl:variable>
  <description>
    <xsl:sequence select="f:analyse-description(string-join($buffer//text, ' '))"/>
  </description>
  <xsl:for-each select="$buffer//*[not(self::text)]">
    <xsl:sequence select="."/>
  </xsl:for-each>
</xsl:function>

<xsl:function name="f:analyse-annotation">
  <xsl:param name="name" as="xs:string"/>
  <xsl:param name="text" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="$name = 'param' and contains($text, ' ')">
      <parameter name="{f:trim(substring-before($text, ' '))}" description="{f:trim(substring-after($text, ' '))}"/>
    </xsl:when>
    <xsl:when test="$name = 'author'">
      <author name="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'return' or $name = 'returns'">
      <return name="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'context'">
      <context select="{f:trim(substring-before($text, ' '))}" description="{f:trim(substring-after($text, ' '))}"/>
    </xsl:when>
    <xsl:otherwise>
      <annotation name="{$name}" text="{f:trim($text)}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:analyse-description">
  <xsl:param name="description" as="xs:string"/>
  <xsl:variable name="p" select="tokenize($description, '\.\n')"/>
  <xsl:for-each select="$p">
    <xsl:variable name="trimmed" select="f:trim(.)"/>
    <xsl:if test="$trimmed != ' '">
      <p><xsl:value-of select="$trimmed"/><xsl:if test="not(matches($trimmed, '\.$'))">.</xsl:if></p>
    </xsl:if>
  </xsl:for-each>
</xsl:function>

<xsl:function name="f:trim">
  <xsl:param name="t" as="xs:string"/>
  <xsl:sequence select="replace($t, '^\s*(.+?)\s*$', '$1')"/>
</xsl:function>

</xsl:stylesheet>