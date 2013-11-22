<?xml version="1.0"?>
<!--
  Converts Schematron documentation into HTML.
  
  @see ISO/IEC 19757-3, Information technology - Document Schema Definition Languages (DSDL)
  
  @author Christophe Lauret
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:sf="http://weborganic.org/Schematron/Documentation"
                              exclude-result-prefixes="#all">

<!-- 
  Root template to generate the HTML from generated XSLT documentation.  
-->
<xsl:template match="schematrondoc" mode="doc">
<article class="schematrondoc">
  <xsl:apply-templates mode="schdoc"/>
</article>
</xsl:template>

<!-- Template for a single schema -->
<xsl:template match="schema" mode="schdoc">
  <h2>
    <xsl:value-of select="if (title) then title else 'Untitled Schema'"/>
    <xsl:for-each select="@schemaVersion"> [v<small class="schemaversion"><xsl:value-of select="."/></small>]</xsl:for-each>
  </h2>
  <xsl:copy-of select="doc/description/*"/>
  <xsl:apply-templates select="p"/>
  <xsl:call-template name="sch-authors"/>
  <xsl:call-template name="sch-namespaces"/>
  <xsl:call-template name="sch-variables"/>
  <!-- Summary table -->
  <h4>Patterns Summary</h4>
  <table>
    <thead>
      <th>Pattern</th><th>Rules</th><th>Assertions</th><th>Reports</th><th>Description</th>
    </thead>
    <tbody>
		  <xsl:for-each select="pattern">
  		  <tr>
			    <td><a href="#schpattern-{@id}"><xsl:value-of select="if (title/text) then title/text else @id"/></a></td>
			    <td><xsl:value-of select="count(rule)"/></td>
			    <td><xsl:value-of select="count(descendant::assert)"/></td>
			    <td><xsl:value-of select="count(descendant::report)"/></td>
          <td><xsl:value-of select="doc/description/*[1]"/></td>
		    </tr>
		  </xsl:for-each>
    </tbody>
  </table>
  <xsl:apply-templates select="pattern" mode="schdoc"/>
</xsl:template>

<xsl:template match="pattern" mode="schdoc">
<div id="schpattern-{@id}">
  <h3>Pattern: <xsl:value-of select="if (title/text) then title/text else @id"/></h3>
  <xsl:call-template name="sch-variables"/>
  <xsl:copy-of select="doc/description/*"/>
  <xsl:apply-templates select="rule" mode="schdoc"/>
</div>
</xsl:template>

<xsl:template match="rule" mode="schdoc">
  <h4>Rule: <var><xsl:value-of select="@context"/></var></h4>
  <xsl:copy-of select="doc/description/*"/>
  <xsl:call-template name="sch-variables"/>
  <h5>Summary</h5>
  <table>
    <thead>
      <tr>
        <th>Type</th>
        <th>Test &amp; Description </th>
      </tr>
    </thead>
    <tbody>
      <xsl:for-each select="assert|report">
        <tr>
          <td><xsl:value-of select="name()"/></td>
          <td>
            <code><xsl:value-of select="@test"/></code>
            <div class="description"><xsl:value-of select="doc/description/*[1]"/></div>
          </td>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>

  <xsl:if test="assert">
    <h5>Assertions</h5>
    <table>
      <thead>
        <tr>
          <th>Test</th>
          <th>Flag</th>
          <th>Description/Message</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="assert">
          <tr>
            <td><code><xsl:value-of select="@test"/></code></td>
            <td><xsl:value-of select="@flag"/></td>
            <td>
              <xsl:value-of select="doc/description/*[1]"/>
              <div class="message">
                <xsl:apply-templates select="message" mode="schdoc"/>
              </div>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:if>
  <xsl:if test="report">
    <h5>Reports</h5>
    <table>
      <thead>
        <tr>
          <th>Pattern</th>
          <th>Flag</th>
          <th>Description/Message</th>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="report">
          <tr>
            <td><code><xsl:value-of select="@test"/></code></td>
            <td><xsl:value-of select="@flag"/></td>
            <td>
              <xsl:value-of select="doc/description/*[1]"/>
              <div class="message">
                <xsl:apply-templates select="message" mode="schdoc"/>
              </div>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:if>
</xsl:template>

<!-- 

  @context assert|report
-->
<xsl:template match="value-of" mode="schdoc">
<var>{<xsl:value-of select="@select"/>}</var>
</xsl:template>

<!-- ========================================================================================== -->
<!-- NAMED TEMPLATES                                                                            -->
<!-- ========================================================================================== -->

<!--
  Display the documentation for the namespaces declared in Schematron

  @context schema
-->
<xsl:template name="sch-namespaces">
  <xsl:if test="ns">
    <h4>Namespaces</h4>
    <table class="namespaces">
      <thead>
        <tr><th>Prefix</th><th>URI</th></tr>
      </thead>
      <tbody>
        <xsl:for-each select="ns">
          <tr>
            <td><xsl:value-of select="@prefix"/></td>
            <td><xsl:value-of select="@uri"/></td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:if>
</xsl:template>

<!--
  Display the documentation for the variable at that scope
  
  @context schema|phase|pattern|rule
-->
<xsl:template name="sch-variables">
<xsl:if test="let">
  <h4>Variables</h4>
  <p>Scope: <code><xsl:value-of select="sf:scope-for-let(.)"/></code></p>
  <table class="variables">
    <thead>
      <tr>
        <th>Name</th>
        <th>Value</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
    <xsl:for-each select="let">
      <tr>
        <td><var><xsl:value-of select="@name"/></var></td>
        <td><code><xsl:value-of select="@value"/></code></td>
        <td><xsl:value-of select="doc/description/*[1]"/></td>
      </tr>    
    </xsl:for-each>
    </tbody>
  </table>
</xsl:if>
</xsl:template>


<!--
  Display the list of authors
  
  @context schema
-->
<xsl:template name="sch-authors">
<xsl:if test="doc/author">
<dl class="authors">
  <dt>Authors</dt>
  <xsl:for-each select="doc/author">
    <dd><xsl:value-of select="@name"/></dd>
  </xsl:for-each>  
</dl>
</xsl:if>
</xsl:template>

<!-- ========================================================================================== -->
<!-- FUNCTIONS                                                                                  -->
<!-- ========================================================================================== -->

<!-- 
  Computes the scope of a variable
  
  @see ISO/IEC 19757-3, Information technology - Document Schema Definition Languages (DSDL) - Rule-based validation - Schematron 5.4.5
-->
<xsl:function name="sf:scope-for-let" as="xs:string">
  <xsl:param name="context" as="element()"/>
  <xsl:choose>
    <xsl:when test="$context/self::rule"><xsl:value-of select="$context/@context"/></xsl:when>
    <xsl:otherwise>/</xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
