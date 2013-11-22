<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Default schema for checking a DOCX document post-simplification.
  
  Conventions:
   - the 'flag' attributes values indicate severity: 
      "debug", "info" (default for <sch:report>), "warn", "error" (default for <sch:report>), "fatal"
   -  '' (single quote) is used to emphasize the style, type of markup
   -  "" (double quote) is used to quote text to provide context

-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" >

  <sch:title>Validation for importing DOCX</sch:title>

  <sch:ns prefix="w" uri="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
  <sch:ns prefix="r" uri="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
  <sch:ns prefix="ve" uri="http://schemas.openxmlformats.org/markup-compatibility/2006" />
  <sch:ns prefix="o" uri="urn:schemas-microsoft-com:office:office"/>
  <sch:ns prefix="r" uri="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/> 
  <sch:ns prefix="m" uri="http://schemas.openxmlformats.org/officeDocument/2006/math" /> 
  <sch:ns prefix="v" uri="urn:schemas-microsoft-com:vml" />
  <sch:ns prefix="wp" uri="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" />
  <sch:ns prefix="w10" uri="urn:schemas-microsoft-com:office:word" />
  <sch:ns prefix="w" uri="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
  <sch:ns prefix="wne" uri="http://schemas.microsoft.com/office/word/2006/wordml"/>
  <sch:ns prefix="fn" uri="http://www.pageseeder.com/function"/>

  <!-- ============================================================================================
       Rules to check that the data has been simplified as expected.
  -->
  <sch:pattern id="Simplification">

    <sch:title>DOCX Simplification</sch:title>

    <!-- Rule against the body as we don't want to report every instance -->
    <sch:rule context="w:body" >

        <sch:assert test="not(descendant::w:proofErr|descendant::w:noProof)" flag="error">Word document should not contain any proofing errors: <sch:value-of select="count(descendant::w:proofErr|descendant::w:noProof)"/> found</sch:assert>
        
        <sch:assert test="not(descendant::w:permEnd|descendant::w:permStart)" flag="error">Word document should not contain any permissions: <sch:value-of select="count(descendant::w:permEnd|descendant::w:permStart)"/> found</sch:assert>
        
        <sch:assert test="not(descendant::w:bookmarkStart[@w:name='_GoBack'])" flag="error">Word document should not contain any bookmarks referencing _GoBack (Word's default position marker)</sch:assert>
        
    </sch:rule>

  </sch:pattern>


  <!-- ============================================================================================
       Rules that trap common markup issues which aren't generally supported
  -->
  <sch:pattern id="Aberrations">

    <sch:title>Aberrations</sch:title>

    <sch:rule context="w:tbl">
        
        <sch:let name="callout-table-styles" value="(
        'Callout-Attention',
        'Callout-Complete', 
        'Callout-Danger',
        'Callout-Direction',
        'Callout-Direction-findoutmore',
        'Callout-Direction-getitdone',
        'Callout-Direction-help',
        'Callout-Direction-listen',
        'Callout-Direction-watch',
        'Callout-Direction-workitout', 
        'Callout-Error',
        'Callout-Example'
        )"/>
        
        <sch:let name="table-styles" value="(
        'Tablewithoutborder', 
        'Tableindent1',
        'Tableindent2',
        'Tableindent3',
        'Tablewithborder'
        )"/>
        
        <sch:assert test=" (count(index-of($table-styles, if(w:tblPr/w:tblStyle/@w:val) then w:tblPr/w:tblStyle/@w:val else '')) gt 0) or (count(index-of($callout-table-styles, if(w:tblPr/w:tblStyle/@w:val) then w:tblPr/w:tblStyle/@w:val else '')) gt 0)">Unsupported table style '<sch:value-of select="w:tblPr/w:tblStyle/@w:val"/>' cannot be imported</sch:assert>
        
        
        <sch:assert test="not(descendant::w:tbl) or (if (descendant::w:tbl) then descendant::w:tbl[w:tblPr/w:tblStyle[count(index-of($table-styles, @w:val)) gt 0]] else true())">
                      Nested tables are not supported
        </sch:assert>
        <!--
        <sch:assert test="not(descendant::w:tbl) and (count(index-of($callout-table-styles, w:tblPr/w:tblStyle/@w:val)) gt 0)">A table inside a table is not supported</sch:assert>
        -->
        <sch:assert test="w:tr" flag="error">A table must contain at least one row: near text "<sch:value-of select="."/>"</sch:assert>

    </sch:rule>

    <sch:rule context="w:tr" >

      <sch:assert test="w:tc" flag="error">A row must contain at least one cell: near text "<sch:value-of select="."/>"</sch:assert>

    </sch:rule>

  </sch:pattern>


  <!-- ============================================================================================
       Useful reports
  -->
  <sch:pattern id="Info">

    <!-- Let's check that we have a DOCX document first! -->
    <sch:rule context="/">

      <!-- We must have a body somewhere -->
      <sch:assert test="//w:body" flag="fatal">This document is probably not a DOCX document!</sch:assert>

    </sch:rule>

    <sch:rule context="w:body">
      
      <!-- Count the tables -->
      <sch:report test="descendant::w:tbl"><sch:value-of select="count(descendant::w:tbl)"/> tables found</sch:report>

      <!-- Count the paragraphs -->
      <sch:report test="descendant::w:p"><sch:value-of select="count(descendant::w:p)"/> paragraphs found</sch:report>

    </sch:rule>

  </sch:pattern>


  <!-- ============================================================================================
       All defined styles are here. 
   -->
  <sch:pattern id="Styles">

    <!-- List supported paragraph styles -->
    <sch:let name="paragraph-styles" value="(
      'Pagetitle', 
      'Heading1',
      'Heading2',
      'Heading3',
      'Heading4',
      'Heading5',
      'Heading6',
      'Heading1numbered',
      'Heading2numbered', 
      'Heading3numbered', 
      'Heading4numbered',
      'Caption', 
      'ListParagraph', 
      'Normalcentre', 
      'Normalright', 
      'Small', 
      'Blockquote',
      'Primarybutton', 
      'Secondarybutton',
      'Indent1', 
      'Indent2', 
      'Indent3',
      'Tableheading', 
      'Tablecaption', 
      'Tableheadingcentre', 
      'Tableheadingright', 
      'Tablesummary',
      'Unformatted'
    )"/>

    <!-- List supported paragraph styles -->
    <sch:let name="text-run-styles" value="(
      'StyleBold', 
      'StyleBoldItalic',
      'Superscript',
      'StyleItalic',
      'StyleUnderline',
      'Nobreak',
      'Heading6',
      'Link-Internal',
      'Link-Internalbold', 
      'Link-Internalitalics', 
      'Link-External',
      'Link-Newwindow', 
      'Link-Bookmark', 
      'Link-Footnote'
    )"/>

    <!--
      Check paragraph styles 
    --> 
    <sch:rule context="w:pStyle">

      <!-- Check that all styles in use are supported -->
      <sch:report test="count(index-of($paragraph-styles, @w:val)) = 0" flag="warn">Unsupported style '<sch:value-of select="@w:val"/>' will be imported as paragraph: "<sch:value-of select="../../w:r/w:t"/>"</sch:report>

      <!-- Warn the user when unformatted content is detected -->
      <sch:report test="@w:val='Unformatted'" flag="warn">Paragraph contains 'Unformatted' content: "<sch:value-of select="../../w:r/w:t"/>"</sch:report>

    </sch:rule>

    <!--
      Check run styles 
    --> 
    <sch:rule context="w:rStyle">

      <!-- Check that all styles in use are supported -->
      <sch:report test="count(index-of($text-run-styles, @w:val)) = 0" flag="warn">Unsupported style '<sch:value-of select="@w:val"/>' will not be imported, only text will be imported : "<sch:value-of select="../../w:t"/>"</sch:report>

    </sch:rule>

  </sch:pattern>

  <!-- ============================================================================================
       Lists and numbering 
   -->
  <sch:pattern id="Lists">

    <sch:let name="numbering-file" value="concat(substring-before(base-uri(),'document.xml'),'numbering.xml')"/>

    <sch:let name="numbering" value="document($numbering-file)"/>

    <sch:let name="list-styles" value="(
      'Bulletedlist', 
      'Numberedlistalphastart',
      'Numberedlistnumericstart',
      'Redundant',
      'Blockquotelist'
    )"/>

    <sch:rule context="w:body[descendant::w:numPr]">

      <!-- Only need to check that the file exists once -->
      <sch:assert test="document($numbering-file)" >Numbering file must exist '<sch:value-of select="$numbering-file"/>'</sch:assert>

      <!-- Report named styles link from numbering definitions found in numbering doc -->
      <sch:report test="count($numbering//w:abstractNum[w:styleLink|w:numStyleLink]) > 0" >'<sch:value-of select="count($numbering//w:abstractNum[w:styleLink|w:numStyleLink])"/>' styled numbering definitions found: "<sch:value-of select="string-join($numbering//w:styleLink/@w:val|$numbering//w:numStyleLink/@w:val, ', ')"/>"</sch:report>

    </sch:rule>

    <!-- Check List styles --> 
    <sch:rule context="w:numPr">

      <!-- Reference to the num -->
      <sch:let name="matching-num" value="$numbering//w:num[@w:numId = current()/w:numId/@w:val]"/>

      <!-- Reference to the corresponding abstract num -->
      <sch:let name="matching-abstractnum" value="$numbering//w:abstractNum[@w:abstractNumId = $matching-num/w:abstractNumId/@w:val]"/>

      <!-- Reference to the corresponding abstract num -->
      <sch:let name="matching-stylelink" value="$matching-abstractnum/w:styleLink/@w:val|$matching-abstractnum/w:numStyleLink/@w:val"/>

      <!-- Let's check that it exists -->
      <sch:assert test="$matching-num">Unable to find matching numbering (Num ID='<sch:value-of select="w:numId/@w:val"/>') for item "<sch:value-of select="following::w:t[1]"/>"</sch:assert>

      <!-- Let's check that it exists -->
      <sch:assert test="count($matching-abstractnum) = 1">Unable to find the matching abstract numbering (Num ID='<sch:value-of select="w:numId/@w:val"/>') for item "<sch:value-of select="following::w:t[1]"/>"</sch:assert>

      <!-- Let's check that the asbtract numbering has a style link -->
      <sch:assert test="count($matching-stylelink) = 1">Unable to find the matching numbering style name (Num ID='<sch:value-of select="w:numId/@w:val"/>') for item "<sch:value-of select="following::w:t[1]"/>"</sch:assert>

      <!-- Finally we ensure that it is a valid one --> 
      <sch:assert test="count($matching-stylelink) = 0 or count(index-of($list-styles, if ($matching-stylelink) then $matching-stylelink[1] else '')) gt 0"
      >Matching numbering style '<sch:value-of select="$matching-stylelink"/>' is not valid for item  "<sch:value-of select="following::w:t[1]"/>"</sch:assert>

    </sch:rule>

  </sch:pattern>
  
   
</sch:schema>
