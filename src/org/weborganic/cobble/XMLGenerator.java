/*
 * Copyright (c) 1999-2012 weborganic systems pty. ltd.
 */
package org.weborganic.cobble;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.weborganic.cobble.xslt.XSLT;

/**
 * Generates the documentation from code comments in XML-based languages (XSLT, Schematron)
 *
 * @author Christophe Lauret
 * @version 13 November 2013
 */
public final class XMLGenerator {

  /**
   * The resource path to templates generating the XSLT documentation.
   */
  private static final String XSLTDOC_STYLESHEET = "org/weborganic/cobble/xslt/doc-xslt.xsl";

  /**
   * The resource path to templates generating the Schematron documentation.
   */
  private static final String SCHEMATRON_STYLESHEET = "org/weborganic/cobble/xslt/doc-schematron.xsl";

  /**
   *
   */
  private final File _code;

  /**
   * Sole constructor.
   *
   * @param code The file to the code to document.
   */
  public XMLGenerator(File code) {
    this._code = code;
  }

  /**
   * Generates the documentation
   *
   * @param path The path to the code to document within the model.
   */
  public void generate(OutputStream out) {
    try {
      Templates templates = getTemplates(this._code.getName());
      Transformer transformer = templates.newTransformer();
      transformer.transform(new StreamSource(this._code), new StreamResult(out));

    } catch (TransformerException ex) {
      // FIXME error handling
      ex.printStackTrace();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * Generates the documentation
   *
   * @param path The path to the code to document within the model.
   */
  public void generate(File target) {
    try {
      Templates templates = getTemplates(this._code.getName());
      Transformer transformer = templates.newTransformer();
      transformer.transform(new StreamSource(this._code), new StreamResult(target));

    } catch (TransformerException ex) {
      // FIXME error handling
      ex.printStackTrace();
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * Indicates whether documentation can be generated from the code denoted by the given file path.
   *
   * @param path The path within the model to the file containing the code to document.
   * @return <code>true</code> is the file extension is ".xsl", ".xslt" or ".sch";
   *         <code>false</code>.
   */
  public static final boolean isSupported(String path) {
    if (path == null) return false;
    return path.endsWith(".xslt") || path.endsWith(".xsl") || path.endsWith(".sch");
  }

  /**
   *
   */
  private static Templates getTemplates(String path) throws IOException, TransformerConfigurationException {
    Templates templates = null;
    if (path.endsWith(".xslt") || path.endsWith(".xsl")) {
      templates = XSLT.getTemplatesFromResource(XSLTDOC_STYLESHEET);
    } else if (path.endsWith(".sch")) {
      templates = XSLT.getTemplatesFromResource(SCHEMATRON_STYLESHEET);
    }
    return templates;
  }

}
