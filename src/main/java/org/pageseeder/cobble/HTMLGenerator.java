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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.pageseeder.cobble.resource.Resources;
import org.pageseeder.cobble.xslt.XSLT;

/**
 * Generates the documentation from code comments in XML-based languages (XSLT, Schematron)
 *
 * @author Christophe Lauret
 */
public final class HTMLGenerator {

  private static final String VERSION = HTMLGenerator.class.getPackage().getImplementationVersion();

  /**
   * The resource path to templates generating the XSLT documentation.
   */
  private static final String HTML_STYLESHEET = "org/weborganic/cobble/xslt/html.xsl";


  private final File _code;

  private boolean _includeResources = true;

  /**
   * Sole constructor.
   *
   * @param code The file to the code to document.
   */
  public HTMLGenerator(File code) {
    this._code = code;
  }

  /**
   * @return the _includeResources
   */
  public boolean includeResources() {
    return this._includeResources;
  }

  /**
   * @param _includeResources the _includeResources to set
   */
  public void setIncludeResources(boolean include) {
    this._includeResources = include;
  }

  /**
   * Generates the documentation as HTML.
   *
   * @throws Wraps any occurring exception.
   */
  public void generate(final File target) throws CobbleException {
    File dir = target.isDirectory()? target : target.getParentFile();
    File html = target.isDirectory()? new File(target, this._code.getName()+".html") : target;

    // Generate the XML documentation first
    XMLGenerator xmlgenerator = new XMLGenerator(this._code);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
    xmlgenerator.generate(buffer);

    //
    ByteArrayInputStream xmldoc = new ByteArrayInputStream(buffer.toByteArray());

    try {
      Templates templates = XSLT.getTemplatesFromResource(HTML_STYLESHEET);
      Transformer transformer = templates.newTransformer();
      transformer.setParameter("cobble-version", VERSION);
      transformer.transform(new StreamSource(xmldoc), new StreamResult(html));

    } catch (TransformerException ex) {
      throw new CobbleException("Unable to generate HTML documentation", ex);
    } catch (IOException ex) {
      throw new CobbleException("Unable to generate HTML documentation", ex);
    }

    try {
      if (this._includeResources) {
        Resources.copyTo("cobble.css", dir);
        Resources.copyTo("cobble.js", dir);
        Resources.copyTo("favicon.ico", dir);
        Resources.copyTo("jquery-1.10.2.min.js", dir);
      }
    } catch (IOException ex) {
      throw new CobbleException("Unable to generate HTML documentation", ex);
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

}
