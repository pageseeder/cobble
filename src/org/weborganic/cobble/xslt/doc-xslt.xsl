<!--
  Stylesheet generating the documentation for XSLT 2.0 stylesheet in XML format.

  This stylesheet parses the code comments and annotations attached to declaration elements.

  It also computes some metadata that can be useful to understand how the stylesheet works.

  @author Christophe Lauret
-->
<xsl:stylesheet version="2.0"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="local://functions"
exclude-result-prefixes="#all">

<!-- Output as XML without declaration as it may be injected inside other XML content -->
<xsl:output encoding="utf-8" method="xml" indent="yes" omit-xml-declaration="yes"/>

<!-- Base folder URI to compute paths -->
<xsl:variable name="base" select="replace(base-uri(), '^(.*/)[^/]+', '$1')" as="xs:string"/>

<!--
  Start of XSLT documentation.

  Process all XSLT declarations in stylesheet
-->
<xsl:template match="/">
<xsltdoc>
  <xsl:apply-templates select="xsl:*"/>
</xsltdoc>
</xsl:template>

<!--
  Document element.

  Report namespaces in use, process all XSLT declarations in stylesheet, then follow all imported and included stylesheets.

  <stylesheet
    id? = id
    extension-element-prefixes? = tokens
    exclude-result-prefixes? = tokens
    version = number
    xpath-default-namespace? = uri
    default-validation? = "preserve" | "strip"
    default-collation? = uri-list
    input-type-annotations? = "preserve" | "strip" | "unspecified">

    <doc>?

    <namespaces>?
      <namespace prefix = qname uri = uri />
    </namespace>

    other declarations

  </stylesheet>


  @param processed The URI list of stylesheets which have already been processed.
-->
<xsl:template match="xsl:stylesheet|xsl:transform">
<xsl:param name="processed" as="xs:anyURI*" select="base-uri()"/>
<stylesheet name="{tokenize(base-uri(), '/')[last()]}" path="{substring(base-uri(), string-length($base))}">
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <!-- Compute namespaces in scope -->
  <namespaces>
    <xsl:variable name="stylesheet" select="."/>
    <xsl:for-each select="in-scope-prefixes($stylesheet)">
      <namespace prefix="{.}" uri="{namespace-uri-for-prefix(., $stylesheet)}"/>
    </xsl:for-each>
  </namespaces>
  <xsl:apply-templates select="xsl:*" />
</stylesheet>
<!-- Process included and imported stylesheets -->
<xsl:variable name="todo" select="for $i in (xsl:import|xsl:include) return document($i/@href)/base-uri()" as="xs:anyURI*"/>
<xsl:for-each select="xsl:import|xsl:include">
  <!-- Only follow the stylesheets which have already been processed -->
  <xsl:if test="count(index-of($processed, document(@href)/base-uri())) = 0">
    <xsl:apply-templates select="." mode="follow">
      <xsl:with-param name="processed" select="distinct-values(($processed, $todo))"/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:for-each>
</xsl:template>

<!-- ========================================================================================== -->
<!-- DECLARATION ELEMENTS                                                                       -->
<!-- ========================================================================================== -->

<!--
  Documentation for attribute sets.

  <attribute-set
    name = qname
    use-attribute-sets? = qnames>

    <doc>?

    <attribute
      name = { qname }
      namespace? = { uri-reference }
      select? = expression
      separator? = { string }
      type? = qname
      validation? = "strict" | "lax" | "preserve" | "strip">
      {sequence-constructor}
    </attribute> *

  </attribute-set>

-->
<xsl:template match="xsl:attribute-set">
<attribute-set>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <xsl:for-each select="xsl:attribute">
    <attribute>
      <xsl:copy-of select="@*" />
      <!-- TODO: sequence constructor -->
    </attribute>
  </xsl:for-each>
</attribute-set>
</xsl:template>

<!--
  Documentation for character maps.

  <character-map
    name = qname
    use-character-maps? = qnames>

    <doc>?

    <output-character
      character = char
      string = string />*

  </character-map>

-->
<xsl:template match="xsl:character-map">
<character-map>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <xsl:for-each select="xsl:output-character">
    <output-character>
      <xsl:copy-of select="@*"/>
    </output-character>
  </xsl:for-each>
</character-map>
</xsl:template>

<!--
  Documentation for decimal formats used in the stylesheet.

  <decimal-format
    name? = qname
    decimal-separator? = char
    grouping-separator? = char
    infinity? = string
    minus-sign? = char
    NaN? = string
    percent? = char
    per-mille? = char
    zero-digit? = char
    digit? = char
    pattern-separator? = char>

    <doc />?

  </decimal-format>
-->
<xsl:template match="decimal-format">
<decimal-format>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</decimal-format>
</xsl:template>

<!--
  Documentation for imported schemas declarations.

  <import-schema
    namespace? = uri-reference
    schema-location? = uri-reference>
    <doc>?
  </import-schema>
-->
<xsl:template match="xsl:import-schema">
<import-schema>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</import-schema>
</xsl:template>

<!--
  Documentation for imported style sheets declaration.

  <import href = uri-reference>
    <doc>?
  </import>
-->
<xsl:template match="xsl:import">
<import>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</import>
</xsl:template>

<!--
  Documentation for included style sheets declarations.

  <include href = uri-reference>
    <doc/>?
  </inlcude>
-->
<xsl:template match="xsl:include">
<include>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</include>
</xsl:template>

<!--
  Documentation for key declarations.

  <key
    name = qname
    match = pattern
    use? = expression
    collation? = uri>
    <doc/>?
  </key>
-->
<xsl:template match="xsl:key">
<key>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</key>
</xsl:template>

<!--
  Documentation for namespace aliases.

  <namespace-alias
    stylesheet-prefix = prefix | "#default"
    result-prefix = prefix | "#default">
    <doc/>?
  </namespace-alias>
-->
<xsl:template match="xsl:namespace-alias">
<namespace-alias>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</namespace-alias>
</xsl:template>

<!--
  Documentation for output specifications.

  <output
    name? = qname
    method? = "xml" | "html" | "xhtml" | "text" | qname-but-not-ncname
    byte-order-mark? = "yes" | "no"
    cdata-section-elements? = qnames
    doctype-public? = string
    doctype-system? = string
    encoding? = string
    escape-uri-attributes? = "yes" | "no"
    include-content-type? = "yes" | "no"
    indent? = "yes" | "no"
    media-type? = string
    normalization-form? = "NFC" | "NFD" | "NFKC" | "NFKD" | "fully-normalized" | "none" | nmtoken
    omit-xml-declaration? = "yes" | "no"
    standalone? = "yes" | "no" | "omit"
    undeclare-prefixes? = "yes" | "no"
    use-character-maps? = qnames
    version? = nmtoken>

    <doc/>?

  </output>
-->
<xsl:template match="xsl:output">
<output>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</output>
</xsl:template>

<!--
  Documentation for templates.

  This template also include the implicit mode and priority for the template.

  <template
    match? = pattern
    name? = qname
    priority? = number
    mode? = tokens
    as? = sequence-type
    implicit-mode? = #default
    implicit-priority? = numbers
    >
    <doc>?
    <parameter>*
  </template>
-->
<xsl:template match="xsl:template">
<template>
  <xsl:copy-of select="@*"/>
  <xsl:if test="not(@mode)">
    <xsl:attribute name="implicit-mode">#default</xsl:attribute>
  </xsl:if>
  <xsl:if test="not(@priority) and @match">
    <xsl:attribute name="implicit-priority"><xsl:value-of select="f:compute-priority(@match)" separator=","/></xsl:attribute>
  </xsl:if>
  <xsl:apply-templates select="xsl:param"/>
  <xsl:sequence select="f:get-description(.)"/>
</template>
</xsl:template>

<!--
  Documentation for functions.

  <function
    name = qname
    as? = sequence-type
    override? = "yes" | "no">
     <doc/>?
     <parameter >*
  </function>
-->
<xsl:template match="xsl:function">
<function>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates select="xsl:param"/>
  <xsl:sequence select="f:get-description(.)"/>
</function>
</xsl:template>

<!--
  Documentation for the strip space declaration.

  <strip-space elements = tokens >
    <doc/>?
  </strip-space>
-->
<xsl:template match="xsl:strip-space">
<strip-space>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</strip-space>
</xsl:template>

<!--
  Documentation for the preserv space declaration.

  <preserve-space elements = tokens>
    <doc/>?
  </preserve-space>
-->
<xsl:template match="xsl:preserve-space">
<preserve-space>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
</preserve-space>
</xsl:template>

<!-- ========================================================================================== -->
<!-- GOING DEEPER                                                                               -->
<!-- ========================================================================================== -->

<!--
  Process XSLT import and include declarations

  @param processed The list of URIs which have already been processed.
-->
<xsl:template match="xsl:import|xsl:include" mode="follow">
<xsl:param name="processed" as="xs:anyURI*"/>
<xsl:apply-templates select="document(@href)//xsl:stylesheet|document(@href)//xsl:transform" >
  <xsl:with-param name="processed" select="$processed"/>
</xsl:apply-templates>
</xsl:template>

<!-- ========================================================================================== -->
<!-- CONTEXTUAL ELEMENTS                                                                        -->
<!-- ========================================================================================== -->

<!--
  Documentation for XSLT parameters.

  <parameter
    name = qname
    select? = expression
    as? = sequence-type
    required? = "yes" | "no"
    tunnel? = "yes" | "no">

  </parameter>

-->
<xsl:template match="xsl:param">
<parameter>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <!-- TODO Compute type and value from sequence constructor -->
</parameter>
</xsl:template>

<!--
  Documentation for XSLT variables

  <variable
    name = qname
    select? = expression
    as? = sequence-type>
  </variable>
-->
<xsl:template match="xsl:variable">
<variable>
  <xsl:copy-of select="@*"/>
  <xsl:sequence select="f:get-description(.)"/>
  <!-- TODO Compute type and value from sequence constructor -->
</variable>
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
    <xsl:analyze-string regex="@([\w\-]+)(\s+(.+))?" select="$c">
      <xsl:matching-substring>
        <xsl:sequence select="f:analyse-annotation(regex-group(1), regex-group(3))"/>
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
  <xsl:param name="text" as="xs:string?"/>
  <xsl:choose>
    <xsl:when test="$name = 'param' and contains($text, ' ')">
      <parameter name="{f:trim(substring-before($text, ' '))}" description="{f:trim(substring-after($text, ' '))}"/>
    </xsl:when>
    <xsl:when test="$name = 'context'and contains($text, ' ')">
      <context select="{f:trim(substring-before($text, ' '))}" description="{f:trim(substring-after($text, ' '))}"/>
    </xsl:when>
    <xsl:when test="$name = 'see' and contains($text, ' ')">
      <see href="{f:trim(substring-before($text, ' '))}" description="{f:trim(substring-after($text, ' '))}"/>
    </xsl:when>
    <xsl:when test="$name = 'see'">
      <see href="{f:trim($text)}" description="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'version'">
      <version name="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'author'">
      <author name="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'return' or $name = 'returns'">
      <return description="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'context'">
      <context select="{f:trim($text)}"/>
    </xsl:when>
    <xsl:when test="$name = 'public' or $name = 'private'">
      <visibility is="{$name}"/>
    </xsl:when>
    <xsl:otherwise>
      <annotation name="{$name}">
        <xsl:if test="$text"><xsl:attribute name="text" select="f:trim($text)"/></xsl:if>
      </annotation>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:analyse-description">
  <xsl:param name="description" as="xs:string"/>
  <xsl:variable name="analysed" select="f:parse-lines(tokenize($description, '\n'))" as="element()*"/>
  <xsl:for-each-group select="$analysed" group-adjacent="boolean(self::p)">
    <xsl:choose>
      <xsl:when test="self::p">
        <p><xsl:sequence select="f:beautify(string-join(current-group()/text(), ' '))"/></p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each-group select="current-group()" group-adjacent="boolean(self::li)">
          <xsl:choose>
            <xsl:when test="self::li">
              <xsl:element name="{if (@numbered) then 'ol' else 'ul'}">
                <xsl:for-each select="current-group()">
                  <li><xsl:sequence select="f:beautify(text())"/></li>
                </xsl:for-each>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each-group select="current-group()" group-adjacent="boolean(self::pre)">
                <xsl:if test="self::pre">
                <pre><xsl:for-each select="current-group()">
                  <xsl:value-of select="."/><xsl:text>&#xa;</xsl:text>
                </xsl:for-each></pre>
                </xsl:if>
              </xsl:for-each-group>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each-group>
</xsl:function>

<xsl:function name="f:trim">
  <xsl:param name="t" as="xs:string"/>
  <xsl:sequence select="if (matches($t, '\S+')) then replace($t, '^\s*(.+?)\s*$', '$1') else ''"/>
</xsl:function>

<xsl:function name="f:linkify">
  <xsl:param name="t" as="xs:string"/>
  <xsl:analyze-string regex="(https?://\S+)" select="$t">
    <xsl:matching-substring>
      <a href="{.}"><xsl:value-of select="."/></a>
    </xsl:matching-substring>
    <xsl:non-matching-substring>
      <xsl:value-of select="."/>
    </xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:function>

<xsl:function name="f:parse-lines" as="element()*">
  <xsl:param name="lines" as="xs:string*"/>
  <xsl:sequence select="f:parse-line($lines, 1, count($lines))"/>
</xsl:function>

<xsl:function name="f:parse-line" as="element()*">
  <xsl:param name="lines"      as="xs:string*"/>
  <xsl:param name="i"    as="xs:integer"/>
  <xsl:param name="total" as="xs:integer"/>
  <xsl:if test="not($i gt $total)">
    <xsl:variable name="line" select="$lines[$i]"/>
    <xsl:choose>
      <xsl:when test="not(matches($line, '\S'))">
        <break/>
      </xsl:when>
      <xsl:when test="matches($line, '^\s*(-|\+|x|\d+\.)\s.+')">
        <li>
          <xsl:if test="matches($line, '^\s*(\d+\.)\s.+')"><xsl:attribute name="numbered">true</xsl:attribute></xsl:if>
          <xsl:if test="not(matches($lines[$i -1], '^\s*(-|\+|x|\d+\.)\s.+'))"><xsl:attribute name="start">true</xsl:attribute></xsl:if>
          <xsl:sequence select="f:trim(replace($line, '^\s*(-|\+|x|\d+\.)\s+(.+)$', '$2'))"/>
        </li>
      </xsl:when>
      <xsl:when test="matches($line, '^\s{4}')">
        <pre><xsl:sequence select="substring($line, 5)"/></pre>
      </xsl:when>
      <xsl:otherwise>
        <p><xsl:sequence select="f:trim($line)"/></p>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:sequence select="f:parse-line($lines, $i+1, $total)"/>
  </xsl:if>
</xsl:function>

<!--
  Beautify the code
-->
<xsl:function name="f:beautify" as="node()*">
  <xsl:param name="t" as="xs:string"/>
  <xsl:analyze-string select="$t" flags="x" regex='(__(.*?)__)
                                                 | (\*(.*?)\*)
                                                 | (`(.*?)`)
                                                 | ("(.*?)"\[(.*?)\])'>
   <xsl:matching-substring>
     <xsl:choose>
       <xsl:when test="regex-group(1)">
         <strong><xsl:sequence select="f:beautify(regex-group(2))"/></strong>
       </xsl:when>
       <xsl:when test="regex-group(3)">
         <em><xsl:sequence select="f:beautify(regex-group(4))"/></em>
       </xsl:when>
       <xsl:when test="regex-group(5)">
         <code><xsl:sequence select="regex-group(6)"/></code>
       </xsl:when>
       <xsl:when test="regex-group(7)">
         <a href="{regex-group(9)}"><xsl:sequence select="regex-group(8)"/></a>
       </xsl:when>
     </xsl:choose>
   </xsl:matching-substring>
   <xsl:non-matching-substring>
    <xsl:value-of select="."/>
   </xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Computes the implicit priority based on XSLT 2.0 conflict resolution rules.

  @see http://www.w3.org/TR/xslt20/#conflict

  @param pattern The value of the match attribute in the template

  @return the priority or sequence of priorities
-->
<xsl:function name="f:compute-priority">
<xsl:param name="pattern"/>
<xsl:choose>
  <!-- TODO: does not work in the '|' is inside a predicate -->
  <xsl:when test="contains($pattern, '|')">
    <xsl:sequence select="for $i in tokenize($pattern, '\|') return distinct-values(f:compute-priority(f:trim($i)))"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:choose>
      <!-- Lowest priority -->
      <xsl:when test="$pattern = '/'">-0.5</xsl:when>
      <xsl:when test="$pattern = 'node()'">-0.5</xsl:when>
      <xsl:when test="$pattern = '*'">-0.5</xsl:when>
      <xsl:when test="$pattern = '@*'">-0.5</xsl:when>
      <xsl:when test="$pattern = 'element()'">-0.5</xsl:when>
      <xsl:when test="$pattern = 'attribute()'">-0.5</xsl:when>
      <xsl:when test="$pattern = 'element(*)'">-0.5</xsl:when>
      <xsl:when test="$pattern = 'attribute(*)'">-0.5</xsl:when>
      <!--  -->
      <xsl:when test="matches($pattern, '^[\w\-]+:\*$')">-0.25</xsl:when>
      <xsl:when test="matches($pattern, '^\*:[\w\-]+$')">-0.25</xsl:when>
      <!-- Specify a predicate -->
      <xsl:when test="contains($pattern, '[')">0.5</xsl:when>
      <!-- Specify ancestry -->
      <xsl:when test="contains($pattern, '/')">0.5</xsl:when>
      <!-- Default to '0' -->
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:otherwise>
</xsl:choose>
</xsl:function>

</xsl:stylesheet>