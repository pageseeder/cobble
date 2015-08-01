/*
 * Copyright 2010-2015 Allette Systems (Australia)
 * http://www.allette.com.au
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.pageseeder.cobble;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;

import javax.xml.transform.Result;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.pageseeder.cobble.xslt.XSLT;

/**
 * Generates the documentation from code comments in XML-based languages (XSLT, Schematron)
 *
 * @author Christophe Lauret
 * @version 20 December 2013
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
   * The file to generate documentation for.
   */
  private final File _code;

  /**
   * Whether to include the XML declaration in the output.
   */
  private boolean _xmldeclaration = false;

  /**
   * The encoding for the output.
   */
  private String _encoding = null;

  /**
   * Sole constructor.
   *
   * @param code The file to the code to document.
   */
  public XMLGenerator(File code) {
    this._code = code;
  }

  /**
   * @param encoding the character encoding of the output XML.
   */
  public void setEncoding(String encoding) {
    this._encoding = encoding;
  }

  /**
   * @param yes <code>true</code> to include the XML declaration in the output
   *            <code>false</code> otherwise.
   */
  public void includeXMLDeclaration(boolean yes) {
    this._xmldeclaration = yes;
  }

  /**
   * Generates the documentation.
   *
   * @param result Where the results go.
   */
  public void generate(Result result) throws CobbleException  {
    try {
      Transformer transformer = newTransformer();
      transformer.transform(new StreamSource(this._code), result);
    } catch (TransformerException ex) {
      throw new CobbleException("Unable to generate documentation as XML", ex);
    } catch (IOException ex) {
      throw new CobbleException("Unable to generate documentation as XML", ex);
    }
  }

  /**
   * Generates the documentation onto an output stream.
   *
   * @param out The output where the documentation should be generated.
   */
  public void generate(OutputStream out) throws CobbleException {
    generate(new StreamResult(out));
  }

  /**
   * Generates the documentation onto a writer.
   *
   * @param out The writer where the documentation should be generated.
   *
   * @throws CobbleException Wraps any transform or I/O exception.
   */
  public void generate(Writer out) throws CobbleException {
    generate(new StreamResult(out));
  }

  /**
   * Generates the documentation to the specified file.
   *
   * @param target The target file where the XML documentation should go.
   *
   * @throws CobbleException Wraps any transform or I/O exception.
   */
  public void generate(File target) throws CobbleException  {
    File xml = target.isDirectory()? new File(target, this._code.getName()+".xml") : target;
    generate(new StreamResult(xml));
  }


  /**
   * Generates the documentation onto an output stream swallowing any occurring exception.
   *
   * @param out The output where the documentation should be generated.
   */
  public void generateSilent(OutputStream out) {
    try {
      generate(new StreamResult(out));
    } catch (CobbleException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * Generates the documentation onto a writer swallowing any occurring exception.
   *
   * @param out The writer where the documentation should be generated.
   *
   * @throws CobbleException Wraps any transform or I/O exception.
   */
  public void generateSilent(Writer out) {
    try {
      generate(new StreamResult(out));
    } catch (CobbleException ex) {
      ex.printStackTrace();
    }
  }

  /**
   * Generates the documentation to the specified file swallowing any occurring exception.
   *
   * @param target The target file where the XML documentation should go.
   */
  public void generateSilent(File target)  {
    try {
      generate(new StreamResult(target));
    } catch (CobbleException ex) {
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
   * Returns a new transformer with the output properties set correctly.
   *
   * @return new transformer with the output properties set correctly.
   *
   * @throws TransformerConfigurationException
   * @throws IOException
   */
  private Transformer newTransformer()
      throws TransformerConfigurationException, IOException {
    Templates templates = getTemplates(this._code.getName());
    Transformer transformer = templates.newTransformer();
    if (this._encoding != null)
      transformer.setOutputProperty("encoding", this._encoding);
    if (this._xmldeclaration)
      transformer.setOutputProperty("omit-xml-declaration", "no");
    return transformer;
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
