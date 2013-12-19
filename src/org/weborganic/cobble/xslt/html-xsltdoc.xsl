<?xml version="1.0"?>
<!--
  Converts XSLT documentation into HTML.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:xf="http://weborganic.org/XSLT/Documentation"
                              exclude-result-prefixes="#all">

<!--
  Root template to generate the HTML from generated XSLT documentation.
-->
<xsl:template match="xsltdoc" mode="cobble-nav">
<xsl:if test="count(stylesheet) > 1">
  <nav>
    <ul>
      <li class="active"><a href="#xslt-summary">SUMMARY</a></li>
      <li><a href="#xslt-templates">Templates</a></li>
      <li><a href="#xslt-functions">Functions</a></li>
      <!-- TODO: Details of variables -->
      <!-- TODO: Details of parameters -->
      <!-- TODO: Generate an index -->
      <li class="files">
        <ul>
          <li><a href="#xslt-stylesheets">Stylesheets <small>&#x25bc;</small></a></li>
        <xsl:for-each select="stylesheet">
          <li><a href="#stylesheet-{replace(@path, '\W', '_')}"><xsl:value-of select="@name"/></a></li>
        </xsl:for-each>
        </ul>
      </li>
    </ul>
  </nav>
</xsl:if>
</xsl:template>

<!--
  Root template to generate the HTML from generated XSLT documentation.
-->
<xsl:template match="xsltdoc" mode="cobble-doc">
<article id="cobble-doc">
<xsl:if test="count(stylesheet) > 1">
  <xsl:apply-templates select="." mode="xsltdoc-summary"/>
</xsl:if>
<xsl:apply-templates mode="xsltdoc"/>
</article>
</xsl:template>

<!--
  Generates the navigation and summary page for when a collection of templates is being viewed.
-->
<xsl:template match="xsltdoc" mode="xsltdoc-summary">
  <section class="xsltdoc" id="xslt-summary">
    <h1>Summary</h1>
    <xsl:apply-templates select="stylesheet[1]/output" mode="xsltdoc"/>
    <xsl:call-template name="global-parameters"/>
    <xsl:call-template name="global-variables"/>
    <xsl:call-template name="template-summary"/>
    <xsl:call-template name="function-summary"/>
  </section>
  <section class="xsltdoc" id="xslt-functions">
    <h1>All functions</h1>
    <xsl:apply-templates select="stylesheet/function" mode="xsltdoc">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </section>
  <section class="xsltdoc" id="xslt-templates">
    <h1>All templates</h1>
    <xsl:apply-templates select="stylesheet/template" mode="xsltdoc">
      <xsl:sort select="if (@match) then 0 else 1"/>
      <xsl:sort select="@mode"/>
      <xsl:sort select="@match|@name"/>
    </xsl:apply-templates>
  </section>
  <section class="xsltdoc" id="xslt-stylesheets">
    <h1>All Stylesheets</h1>
    <xsl:for-each select="stylesheet">
      <h4><xsl:value-of select="@name"/></h4>
      <p><code><xsl:value-of select="@path"/></code></p>
    </xsl:for-each>
  </section>
</xsl:template>

<!--
  Generates documentation for a single stylesheet.
-->
<xsl:template match="stylesheet" mode="xsltdoc">
<section class="xsltdoc" id="stylesheet-{replace(@path, '\W', '_')}">
  <h1>Stylesheet: <xsl:value-of select="@name"/></h1>
  <p class="path"><xsl:value-of select="@path"/></p>
  <xsl:copy-of select="doc/description/*"/>
  <xsl:if test="import">
    <h2>Imports</h2>
    <ul class="imports"><xsl:apply-templates select="import" mode="xsltdoc"/></ul>
  </xsl:if>
  <xsl:if test="include">
    <h2>Includes</h2>
    <ul class="includes"><xsl:apply-templates select="include" mode="xsltdoc"/></ul>
  </xsl:if>
  <xsl:apply-templates select="output" mode="xsltdoc"/>
  <xsl:call-template name="namespaces"/>
  <xsl:call-template name="global-parameters"/>
  <xsl:call-template name="global-variables"/>
  <xsl:call-template name="template-summary"/>
  <xsl:call-template name="function-summary"/>
  <!-- details -->
  <xsl:if test="template">
    <h2>Templates</h2>
    <p><small>(In stylesheet order)</small></p>
    <xsl:apply-templates select="template" mode="xsltdoc"/>
  </xsl:if>
  <xsl:if test="function">
    <h2>Functions</h2>
    <xsl:apply-templates select="function" mode="xsltdoc">
      <xsl:sort select="@name"/>
    </xsl:apply-templates>
  </xsl:if>
</section>
</xsl:template>

<!-- Display a single include or import declaration -->
<xsl:template match="import|include" mode="xsltdoc">
  <li><a href="#stylesheet-{replace(@href, '\W', '_')}" class="goto"><xsl:value-of select="@href"/></a></li>
</xsl:template>

<xsl:template match="output" mode="xsltdoc">
<h2>Output</h2>
<table>
  <xsl:for-each select="@*">
    <tr>
      <td><xsl:value-of select="name()"/></td>
      <td><xsl:value-of select="."/></td>
    </tr>
  </xsl:for-each>
</table>
</xsl:template>

<!-- Display the summary of namespaces -->
<xsl:template name="namespaces">
<h2>Namespaces</h2>
<table class="namespaces">
  <thead>
    <tr><th>Prefix</th><th>URI</th></tr>
  </thead>
  <tbody>
    <xsl:for-each select="namespaces/namespace">
      <tr>
        <td><xsl:value-of select="@prefix"/></td>
        <td><xsl:value-of select="@uri"/></td>
      </tr>
    </xsl:for-each>
  </tbody>
</table>
</xsl:template>

<!-- Display the summary of global parameters -->
<xsl:template name="global-parameters">
<xsl:if test="stylesheet/parameter|parameter">
  <h2>Global parameters</h2>
  <table class="parameters">
    <thead>
      <tr><th>Name</th><th>Value</th><th>Type</th><th>Description</th></tr>
    </thead>
    <tbody>
      <xsl:apply-templates select="stylesheet/parameter|parameter" mode="xsltdoc"/>
    </tbody>
  </table>
</xsl:if>
</xsl:template>

<!-- Display the summary of global variables -->
<xsl:template name="global-variables">
<xsl:if test="stylesheet/variable|variable">
<h2>Global variables</h2>
  <table class="variables">
    <thead>
      <tr><th>Name</th><th>Value</th><th>Type</th><th>Description</th></tr>
    </thead>
    <tbody>
      <xsl:apply-templates select="stylesheet/variable|variable" mode="xsltdoc"/>
    </tbody>
  </table>
</xsl:if>
</xsl:template>

<!-- Display the summary of templates -->
<xsl:template name="template-summary">
<xsl:if test="stylesheet/template|template">
  <h2>Templates summary</h2>
  <table class="templates">
    <thead>
      <tr><th>Match/Name</th><th>Priority</th><th>Mode</th><th>Description</th></tr>
    </thead>
    <tbody>
    <xsl:for-each select="stylesheet/template|template">
      <tr>
        <td>
          <xsl:if test="@match"><a href="#{replace(@match, '\W', '_')}"><code class="pattern"><xsl:value-of select="@match" /></code></a></xsl:if>
          <xsl:if test="@name"><i><xsl:value-of select="@name" /></i></xsl:if>
        </td>
        <td><xsl:sequence select="xf:priority-for-template(@priority, @implicit-priority)"/></td>
        <td><xsl:sequence select="xf:mode-for-template(@mode)"/></td>
        <td><xsl:value-of select="doc/description/p[1]"/></td>
      </tr>
    </xsl:for-each>
    </tbody>
  </table>
</xsl:if>
</xsl:template>

<!-- Display the summary of functions -->
<xsl:template name="function-summary">
<xsl:if test="stylesheet/function|function">
  <h2>Functions summary</h2>
  <table class="functions">
    <thead>
      <tr><th>Returns</th><th>Name/Description</th></tr>
    </thead>
    <tbody>
      <xsl:for-each select="stylesheet/function|function">
        <xsl:sort select="@name"/>
        <tr>
          <td><code><xsl:value-of select="if (@as) then @as else '?'" /></code></td>
          <td>
            <a href="#{replace(@name, '\W', '_')}"><var><xsl:value-of select="@name" /></var> (
            <xsl:for-each select="parameter">
              <var><xsl:value-of select="@name"/></var> as <code><xsl:value-of select="if (@as) then @as else '?'"/></code>
              <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            )</a>
            <div class="description"><xsl:value-of select="doc/description/p[1]"/></div>
          </td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
</xsl:if>
</xsl:template>

<xsl:template match="template" mode="xsltdoc">
<a name="{replace(@match, '\W', '_')}"/>
<h3 class="template-title">Template
<xsl:if test="@match">
  matching <var><xsl:value-of select="@match"/></var>
</xsl:if>
<xsl:if test="@name">
  named <var><xsl:value-of select="@name"/></var>
</xsl:if>
<xsl:if test="@mode">
  <xsl:for-each select="tokenize(@mode, '\s+')">
    <span class="mode"><xsl:value-of select="."/></span>
  </xsl:for-each>
</xsl:if>
<xsl:if test="@priority">
  <span class="priority"><xsl:value-of select="@priority"/></span>
</xsl:if>
</h3>
<xsl:if test="@match">
  <p>Priority: <var><xsl:value-of select="if (@priority) then @priority else @implicit-priority"/></var><xsl:if test="not(@priority)"><xsl:text> </xsl:text><small>(implicit)</small></xsl:if></p>
  <p>Mode: <var><xsl:value-of select="if (@mode) then @mode else '#default'"/></var><xsl:if test="not(@mode)"><xsl:text> </xsl:text><small>(implicit)</small></xsl:if></p>
</xsl:if>
<xsl:copy-of select="doc/description/*" />
<xsl:call-template name="local-parameters"/>
</xsl:template>

<xsl:template match="function" mode="xsltdoc">
<a name="function-{replace(@name, '\W', '_')}"/>
<h3 class="function-title">Function: <i><xsl:value-of select="@name"/></i></h3>
<xsl:copy-of select="doc/description/*" />
<h5>Usage</h5>
<div class="signature">
<var><xsl:value-of select="@name" /></var> (
<xsl:for-each select="parameter">
  <var><xsl:value-of select="@name"/></var> as <code><xsl:value-of select="if (@as) then @as else '?'"/></code>
  <xsl:if test="position() != last()">,</xsl:if>
</xsl:for-each>
) &#x2192; <code><xsl:value-of select="if (@as) then @as else '?'"/></code></div>
<xsl:call-template name="local-parameters"/>
</xsl:template>

<xsl:template name="local-parameters">
<xsl:variable name="doc" select="doc" />
<xsl:if test="parameter">
  <h5>Parameters</h5>
  <table class="parameters">
    <thead>
      <tr>
        <th>Name</th>
        <th>Type</th>
        <xsl:if test="self::template">
          <th>Value</th>
          <th>Tunnel</th>
        </xsl:if>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <xsl:for-each select="parameter">
        <tr>
          <td><var><xsl:value-of select="@name"/></var></td>
          <td><code><xsl:value-of select="@as"/></code></td>
          <xsl:if test="parent::template">
            <td><xsl:value-of select="@select"/></td>
            <td><xsl:value-of select="@tunnel"/></td>
          </xsl:if>
          <td><xsl:copy-of select="$doc/parameter[@name = current()/@name]/@description"/></td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
</xsl:if>
</xsl:template>


<xsl:template match="parameter|variable" mode="xsltdoc">
<tr>
  <td><code><xsl:value-of select="@name"/></code></td>
  <td><xsl:value-of select="@select"/></td>
  <td><xsl:value-of select="@as"/></td>
  <td><xsl:copy-of select="doc/description"/></td>
</tr>
</xsl:template>

<!--
  Display the mode for a template.

  @param mode The template mode

  @return the mode
-->
<xsl:function name="xf:mode-for-template" as="element(span)">
<xsl:param name="mode" as="xs:string?"/>
<xsl:choose>
  <xsl:when test="$mode"><span class="specified"><xsl:value-of select="$mode"/></span></xsl:when>
  <xsl:otherwise><span class="implied">#default</span></xsl:otherwise>
</xsl:choose>
</xsl:function>

<!--
  Display the priority for a template.

  @param priority The template priority
  @param implicit The implicit priority computed by the XSLT doc tool

  @return the specified or implied priority.
-->
<xsl:function name="xf:priority-for-template" as="element(span)">
<xsl:param name="priority" as="xs:string?"/>
<xsl:param name="implicit" as="xs:string?"/>
<xsl:choose>
  <xsl:when test="$priority"><span class="specified"><xsl:value-of select="$priority"/></span></xsl:when>
  <xsl:when test="$implicit"><span class="implied"><xsl:value-of select="$implicit"/></span></xsl:when>
  <xsl:otherwise><span class="implied">N/A</span></xsl:otherwise>
</xsl:choose>
</xsl:function>

</xsl:stylesheet>
