<xsl:stylesheet version="2.0"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="local://functions"
exclude-result-prefixes="#all">

<xsl:import href="sample-a.xsl"/>
<xsl:import href="sample-b.xsl"/>

<xsl:output encoding="utf-8" method="xml" indent="yes" omit-xml-declaration="yes"/>

<xsl:variable name="base" select="replace(base-uri(), '^(.*/)[^/]+', '$1')"/>

<!-- -->
<xsl:template match="/">
<xsltdoc>
  <xsl:apply-templates select="xsl:*"/>
</xsltdoc>
</xsl:template>

<xsl:template match="xsl:stylesheet|xsl:transform">
<xsl:param name="done"/>
<stylesheet name="{tokenize(base-uri(), '/')[last()]}" path="{substring(base-uri(), string-length($base))}">
  <xsl:sequence select="f:get-description(.)"/>
  <xsl:apply-templates select="xsl:*" />
</stylesheet>
<!-- Include imported stylesheets -->
<!-- TODO avoid circular references -->
<xsl:variable name="todo" select="for $i in (xsl:import|xsl:include) return document($i/@href)/base-uri()"/>
<xsl:apply-templates select="xsl:import|xsl:include" mode="follow"/>
</xsl:template>

<xsl:template match="xsl:param">
<parameter>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</parameter>
</xsl:template>

<xsl:template match="xsl:variable">
<variable>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</variable>
</xsl:template>

<xsl:template match="xsl:import">
<import>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</import>
</xsl:template>

<xsl:template match="xsl:include">
<include>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</include>
</xsl:template>

<xsl:template match="xsl:output">
<output>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</output>
</xsl:template>

<xsl:template match="xsl:template">
<template>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates select="xsl:param"/>
  <xsl:sequence select="f:get-description(.)"/>
</template>
</xsl:template>

<xsl:template match="xsl:function">
<function>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates select="xsl:param"/>
  <xsl:sequence select="f:get-description(.)"/>
</function>
</xsl:template>


<xsl:template match="xsl:import|xsl:include" mode="follow">
<xsl:variable name="href" select="@href"/>
<xsl:apply-templates select="document(@href)//xsl:stylesheet" >
  <xsl:with-param name="ref" select="@href"/>
</xsl:apply-templates>
</xsl:template>


<xsl:template match="xs:*">
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