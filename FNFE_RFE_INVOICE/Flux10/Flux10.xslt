<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->

   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->

   <!--KEYS AND FUNCTIONS-->

   <!--DEFAULT RULES-->

   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="PPF — Flux 10 e-reporting — v1.8"
                              schemaVersion="ISO19757-3">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSMISSION-G1.104</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSMISSION-G1.104</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M1"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSMISSION-G7.53</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSMISSION-G7.53</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M2"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSMISSION-G8.01</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSMISSION-G8.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M3"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSMISSION-G6.29</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSMISSION-G6.29</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-EMETTEUR-G6.22</xsl:attribute>
            <xsl:attribute name="name">F10-EMETTEUR-G6.22</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-EMETTEUR-G7.51</xsl:attribute>
            <xsl:attribute name="name">F10-EMETTEUR-G7.51</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-DECLARANT-G6.26</xsl:attribute>
            <xsl:attribute name="name">F10-DECLARANT-G6.26</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-DECLARANT-G7.52</xsl:attribute>
            <xsl:attribute name="name">F10-DECLARANT-G7.52</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-TX-G1.09a</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-TX-G1.09a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-TX-G1.09b</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-TX-G1.09b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-TX-G6.25</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-TX-G6.25</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.01</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.02</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.02</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.60</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.60</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-S1.12</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-S1.12</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.05a</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.05a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.09a</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.09a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.09b</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.09b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-P1.11</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-P1.11</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G6.21</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G6.21</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.32a</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.32a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.32b</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.32b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G6.28</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G6.28</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.09c</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.09c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-FACTURE-G1.05b</xsl:attribute>
            <xsl:attribute name="name">F10-FACTURE-G1.05b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19a</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19b</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19c</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19d</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19d</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19e</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19e</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.19f</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.19f</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.33a</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.33a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.33b</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.33b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G1.102</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G1.102</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-VENDEUR-G2.01</xsl:attribute>
            <xsl:attribute name="name">F10-VENDEUR-G2.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19a</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19b</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19c</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19d</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19d</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19e</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19e</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.19f</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.19f</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M41"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.33a</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.33a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.33b</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.33b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-ACHETEUR-G2.01</xsl:attribute>
            <xsl:attribute name="name">F10-ACHETEUR-G2.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIVRAISON-G1.09</xsl:attribute>
            <xsl:attribute name="name">F10-LIVRAISON-G1.09</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIVRAISON-G2.01</xsl:attribute>
            <xsl:attribute name="name">F10-LIVRAISON-G2.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-FAC-G1.09a</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-FAC-G1.09a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-FAC-G1.09b</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-FAC-G1.09b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-FAC-G6.25</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-FAC-G6.25</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-REMISE-G2.31</xsl:attribute>
            <xsl:attribute name="name">F10-REMISE-G2.31</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-REMISE-G1.24</xsl:attribute>
            <xsl:attribute name="name">F10-REMISE-G1.24</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-REMISE-G1.14</xsl:attribute>
            <xsl:attribute name="name">F10-REMISE-G1.14</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TOTAL-G1.14a</xsl:attribute>
            <xsl:attribute name="name">F10-TOTAL-G1.14a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TOTAL-TAXAMOUNT</xsl:attribute>
            <xsl:attribute name="name">F10-TOTAL-TAXAMOUNT</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TOTAL-G1.53</xsl:attribute>
            <xsl:attribute name="name">F10-TOTAL-G1.53</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TVA-G2.31</xsl:attribute>
            <xsl:attribute name="name">F10-TVA-G2.31</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TVA-G1.24</xsl:attribute>
            <xsl:attribute name="name">F10-TVA-G1.24</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TVA-G1.40</xsl:attribute>
            <xsl:attribute name="name">F10-TVA-G1.40</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TVA-G1.14a</xsl:attribute>
            <xsl:attribute name="name">F10-TVA-G1.14a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TVA-G1.14b</xsl:attribute>
            <xsl:attribute name="name">F10-TVA-G1.14b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.09a</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.09a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.09b</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.09b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G6.25</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G6.25</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G2.01</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G2.01</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.14</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.14</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M65"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.15</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.15</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M66"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.16a</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.16a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M67"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.16b</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.16b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M68"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.16c</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.16c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.55</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.55</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.09c</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.09c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-LIGNE-G1.05</xsl:attribute>
            <xsl:attribute name="name">F10-LIGNE-G1.05</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.09</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.09</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.68</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.68</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-P1.11</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-P1.11</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.24b</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.24b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.14a</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.14a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.14b</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.14b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.14c</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.14c</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.14d</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.14d</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TRANSAC-G1.53</xsl:attribute>
            <xsl:attribute name="name">F10-TRANSAC-G1.53</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M81"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-PMT-G1.09a</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-PMT-G1.09a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M82"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-PMT-G1.09b</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-PMT-G1.09b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M83"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PERIODE-PMT-G6.25</xsl:attribute>
            <xsl:attribute name="name">F10-PERIODE-PMT-G6.25</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M84"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-FACTURE-G1.05</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-FACTURE-G1.05</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M85"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-FACTURE-G1.09</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-FACTURE-G1.09</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M86"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-ENCAISSEMENT-G1.09</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-ENCAISSEMENT-G1.09</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M87"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-ENCAISSEMENT-G1.24</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-ENCAISSEMENT-G1.24</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M88"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-ENCAISSEMENT-G6.27a</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-ENCAISSEMENT-G6.27a</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M89"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-ENCAISSEMENT-G1.16</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-ENCAISSEMENT-G1.16</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M90"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-AGREGE-G1.09</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-AGREGE-G1.09</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M91"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-AGREGE-G1.24</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-AGREGE-G1.24</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M92"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-AGREGE-G6.27b</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-AGREGE-G6.27b</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M93"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-AGREGE-G1.16</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-AGREGE-G1.16</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M94"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-PMT-DEVISE-G1.10</xsl:attribute>
            <xsl:attribute name="name">F10-PMT-DEVISE-G1.10</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M95"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10-TX-DEVISE-G1.10</xsl:attribute>
            <xsl:attribute name="name">F10-TX-DEVISE-G1.10</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M96"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">PPF — Flux 10 e-reporting — v1.8</svrl:text>
   <!--PATTERN F10-TRANSMISSION-G1.104-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/Id" priority="1000" mode="M1">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/Id"/>
      <xsl:variable name="v" select="string(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($v) &lt;= 50"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length($v) &lt;= 50">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.104] L'identifiant de transmission ne peut pas dépasser 50 caractères. | Source : Annexe 7 v1.8 G1.104</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with($v, ' ') or ends-with($v, ' '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(starts-with($v, ' ') or ends-with($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.104] L'identifiant de transmission ne peut pas commencer ni terminer par un espace. | Source : Annexe 7 v1.8 G1.104</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($v, '  '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.104] L'identifiant de transmission ne peut pas contenir d'espaces consécutifs. | Source : Annexe 7 v1.8 G1.104</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.104] L'identifiant de transmission contient des caractères non autorisés. | Source : Annexe 7 v1.8 G1.104</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M1"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M1"/>
   <xsl:template match="@*|node()" priority="-2" mode="M1">
      <xsl:apply-templates select="*" mode="M1"/>
   </xsl:template>
   <!--PATTERN F10-TRANSMISSION-G7.53-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/IssueDateTime/DateTimeString"
                 priority="1000"
                 mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/IssueDateTime/DateTimeString"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{14}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{14}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G7.53] La date-heure de transmission doit être au format AAAAMMJJHHMMSS. | Source : Annexe 7 v1.8 G7.53</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{14}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{14}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date-heure de transmission doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M2"/>
   <xsl:template match="@*|node()" priority="-2" mode="M2">
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>
   <!--PATTERN F10-TRANSMISSION-G8.01-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/TypeCode" priority="1000" mode="M3">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/TypeCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('IN', 'RE')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = ('IN', 'RE')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G8.01] Le type de transmission doit être IN (initiale) ou RE (rectificative). | Source : Annexe 7 v1.8 G8.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M3"/>
   <xsl:template match="@*|node()" priority="-2" mode="M3">
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>
   <!--PATTERN F10-TRANSMISSION-G6.29-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count((/Report/TransactionsReport, /Report/PaymentsReport)) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count((/Report/TransactionsReport, /Report/PaymentsReport)) = 1">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.29] La transmission doit contenir exactement un rapport : soit un rapport de transactions (TB-2), soit un rapport de paiements (TB-3), mais pas les deux. | Source : Annexe 7 v1.8 G6.29</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>
   <!--PATTERN F10-EMETTEUR-G6.22-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/Sender/Id" priority="1000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/Sender/Id"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@schemeId = '0238'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@schemeId = '0238'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.22] Le type d'identifiant de l'émetteur doit être 0238 (plateforme agréée). | Source : Annexe 7 v1.8 G6.22</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(.) = 4"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) = 4">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.22] Le matricule de la plateforme émettrice doit comporter exactement 4 caractères. | Source : Annexe 7 v1.8 G6.22</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <!--PATTERN F10-EMETTEUR-G7.51-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/Sender/RoleCode"
                 priority="1000"
                 mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/Sender/RoleCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = 'WK'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = 'WK'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G7.51] Le code rôle de l'émetteur doit être WK (plateforme agréée). | Source : Annexe 7 v1.8 G7.51</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <!--PATTERN F10-DECLARANT-G6.26-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/Issuer/Id" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/Issuer/Id"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@schemeId = '0002'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@schemeId = '0002'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.26] Le type d'identifiant du déclarant doit être 0002 (SIREN). | Source : Annexe 7 v1.8 G6.26</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.26] Le SIREN du déclarant doit comporter exactement 9 caractères numériques. | Source : Annexe 7 v1.8 G6.26</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <!--PATTERN F10-DECLARANT-G7.52-->

   <!--RULE -->
   <xsl:template match="/Report/ReportDocument/Issuer/RoleCode"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/ReportDocument/Issuer/RoleCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('BY', 'SE')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = ('BY', 'SE')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G7.52] Le code rôle du déclarant doit être BY (acheteur) ou SE (vendeur). | Source : Annexe 7 v1.8 G7.52</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-TX-G1.09a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/ReportPeriod/StartDate"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/ReportPeriod/StartDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : la date de début de période de transmission doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : l'année doit être comprise entre 2000 et 2099 (début période transmission). | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-TX-G1.09b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/ReportPeriod/EndDate"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/ReportPeriod/EndDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : la date de fin de période de transmission doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : l'année doit être comprise entre 2000 et 2099 (fin période transmission). | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-TX-G6.25-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/ReportPeriod[StartDate and EndDate]"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/ReportPeriod[StartDate and EndDate]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="EndDate &gt; StartDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="EndDate &gt; StartDate">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.25] La date de fin de période de transmission ne peut pas être antérieure ou égale à la date de début. | Source : Annexe 7 v1.8 G6.25</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.01-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TypeCode"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TypeCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('261','380','381','384','386','389','393','396','471','472','473','500','501','502','503')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('261','380','381','384','386','389','393','396','471','472','473','500','501','502','503')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.01] Le type de facture n'est pas autorisé par le PPF. | Source : Annexe 7 v1.8 G1.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.02-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/BusinessProcess/ID"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/BusinessProcess/ID"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('B1','S1','M1','B2','S2','M2','B4','S4','M4','S5','S6','B7','S7')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('B1','S1','M1','B2','S2','M2','B4','S4','M4','S5','S6','B7','S7')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.02] Le cadre de facturation n'est pas autorisé. | Source : Annexe 7 v1.8 G1.02</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.60-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(BusinessProcess/ID = ('B4','S4','M4') and                         TypeCode = ('386','500','503'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(BusinessProcess/ID = ('B4','S4','M4') and TypeCode = ('386','500','503'))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.60] Le type de facture est incompatible avec le cadre de facturation (acomptes interdits avec B4/S4/M4). | Source : Annexe 7 v1.8 G1.60</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-S1.12-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/BusinessProcess/TypeID"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/BusinessProcess/TypeID"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = 'urn.cpro.gouv.fr:1p0:ereporting'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = 'urn.cpro.gouv.fr:1p0:ereporting'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[S1.12] L'identifiant de profil doit être urn.cpro.gouv.fr:1p0:ereporting. | Source : Annexe 7 v1.8 S1.12</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.05a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/ID"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/ID"/>
      <xsl:variable name="v" select="string(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($v) &lt;= 35"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length($v) &lt;= 35">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture ne peut pas dépasser 35 caractères. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with($v, ' ') or ends-with($v, ' '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(starts-with($v, ' ') or ends-with($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture ne peut pas commencer ni terminer par un espace. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($v, '  '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture ne peut pas contenir d'espaces consécutifs. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture contient des caractères non autorisés. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.09a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/IssueDate"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/IssueDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date d'émission de la facture doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date d'émission de la facture doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.09b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/DueDate"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/DueDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date d'échéance de la facture doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date d'échéance de la facture doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-P1.11-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxDueDateTypeCode"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxDueDateTypeCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('5','29','72','3','35','432')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('5','29','72','3','35','432')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[P1.11] Le code d'exigibilité de la TVA doit appartenir à UNTDID 2475 (5, 29, 72) ou UNTDID 2005 (3, 35, 432). | Source : Annexe 7 v1.8 P1.11</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G6.21-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(TaxSubTotal/TaxCategory/TaxExemptionReasonCode = 'VATEX-FR-CNWVAT')                     or TypeCode = ('261','381','396')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(TaxSubTotal/TaxCategory/TaxExemptionReasonCode = 'VATEX-FR-CNWVAT') or TypeCode = ('261','381','396')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.21] Le code VATEX-FR-CNWVAT est réservé aux avoirs (types 261, 381, 396). | Source : Annexe 7 v1.8 G6.21</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.32a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice[TypeCode = ('384','471','472','473')]"
                 priority="1000"
                 mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice[TypeCode = ('384','471','472','473')]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(ReferencedDocument) = 1 and ReferencedDocument/IssueDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ReferencedDocument) = 1 and ReferencedDocument/IssueDate">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.32] Une facture rectificative doit comporter une et une seule référence de facture antérieure avec sa date. | Source : Annexe 7 v1.8 G1.32</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.32b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice[TypeCode = ('261','381','396','502','503')]"
                 priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice[TypeCode = ('261','381','396','502','503')]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(count(ReferencedDocument) &gt;= 1 and ReferencedDocument/IssueDate)                     or (exists(Line) and                         (every $l in Line satisfies                            (exists($l/ReferencedDocument/ID) and                            exists($l/ReferencedDocument/IssueDate))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(count(ReferencedDocument) &gt;= 1 and ReferencedDocument/IssueDate) or (exists(Line) and (every $l in Line satisfies (exists($l/ReferencedDocument/ID) and exists($l/ReferencedDocument/IssueDate))))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.32] Un avoir doit comporter au moins une référence de facture antérieure avec sa date, en entête ou sur chaque ligne. | Source : Annexe 7 v1.8 G1.32</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G6.28-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice"
                 priority="1000"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="Buyer/CompanyId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="Buyer/CompanyId">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.28] L'identifiant de l'acheteur est obligatoire pour une transmission B2B international. | Source : Annexe 7 v1.8 G6.28</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.09c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/ReferencedDocument/IssueDate"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/ReferencedDocument/IssueDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de la facture antérieure doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de la facture antérieure doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <!--PATTERN F10-FACTURE-G1.05b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/ReferencedDocument/ID"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/ReferencedDocument/ID"/>
      <xsl:variable name="v" select="string(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($v) &lt;= 35"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length($v) &lt;= 35">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure ne peut pas dépasser 35 caractères. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with($v, ' ') or ends-with($v, ' '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(starts-with($v, ' ') or ends-with($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure ne peut pas commencer ni terminer par un espace. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($v, '  '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure ne peut pas contenir d'espaces consécutifs. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure contient des caractères non autorisés. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@schemeId = ('0002','0223','0227','0228','0229')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@schemeId = ('0002','0223','0227','0228','0229')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] Le type d'identifiant du vendeur doit être 0002, 0223, 0227, 0228 ou 0229. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0002']"
                 priority="1000"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0002']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant vendeur de type 0002 (SIREN) doit comporter exactement 9 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0223']"
                 priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0223']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(.) &lt;= 18"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) &lt;= 18">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant vendeur de type 0223 (UE_HORS_FRANCE) ne peut pas dépasser 18 caractères. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19d-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0227']"
                 priority="1000"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0227']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(.) &lt;= 18"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) &lt;= 18">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant vendeur de type 0227 (HORS_UE) ne peut pas dépasser 18 caractères. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19e-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0228']"
                 priority="1000"
                 mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0228']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9,10}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9,10}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant vendeur de type 0228 (RIDET) doit comporter 9 ou 10 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.19f-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0229']"
                 priority="1000"
                 mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/CompanyId[@schemeId = '0229']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant vendeur de type 0229 (TAHITI) doit comporter exactement 9 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.33a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller[CompanyId/@schemeId = ('0002','0223')]"
                 priority="1000"
                 mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller[CompanyId/@schemeId = ('0002','0223')]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="TaxRegistrationId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="TaxRegistrationId">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.33] L'identifiant TVA du vendeur est obligatoire quand le type d'identifiant est 0002 ou 0223. | Source : Annexe 7 v1.8 G2.33</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.33b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/TaxRegistrationId"
                 priority="1000"
                 mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/TaxRegistrationId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@qualifyingId = 'VAT'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@qualifyingId = 'VAT'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.33] Le qualifiant de l'identifiant TVA du vendeur doit être VAT. | Source : Annexe 7 v1.8 G2.33</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G1.102-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice[TaxSubTotal/TaxCategory/Code = 'E']"
                 priority="1000"
                 mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice[TaxSubTotal/TaxCategory/Code = 'E']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="Seller/TaxRegistrationId or                     SellerTaxRepresentative/TaxRegistrationId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="Seller/TaxRegistrationId or SellerTaxRepresentative/TaxRegistrationId">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.102] L'identifiant TVA du vendeur ou du représentant fiscal est obligatoire quand un code de catégorie TVA "E" est présent. | Source : Annexe 7 v1.8 G1.102</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <!--PATTERN F10-VENDEUR-G2.01-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Seller/PostalAddress/CountryId"
                 priority="1000"
                 mode="M35">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Seller/PostalAddress/CountryId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{2}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.01] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit être au format ISO 3166 alpha-2 (existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G2.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId"
                 priority="1000"
                 mode="M36">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@schemeId = ('0002','0223','0227','0228','0229')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@schemeId = ('0002','0223','0227','0228','0229')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] Le type d'identifiant de l'acheteur doit être 0002, 0223, 0227, 0228 ou 0229. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0002']"
                 priority="1000"
                 mode="M37">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0002']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant acheteur de type 0002 (SIREN) doit comporter exactement 9 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0223']"
                 priority="1000"
                 mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0223']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(.) &lt;= 18"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) &lt;= 18">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant acheteur de type 0223 (UE_HORS_FRANCE) ne peut pas dépasser 18 caractères. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19d-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0227']"
                 priority="1000"
                 mode="M39">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0227']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(.) &lt;= 18"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.) &lt;= 18">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant acheteur de type 0227 (HORS_UE) ne peut pas dépasser 18 caractères. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19e-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0228']"
                 priority="1000"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0228']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9,10}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9,10}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant acheteur de type 0228 (RIDET) doit comporter 9 ou 10 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.19f-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0229']"
                 priority="1000"
                 mode="M41">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/CompanyId[@schemeId = '0229']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{9}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{9}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.19] L'identifiant acheteur de type 0229 (TAHITI) doit comporter exactement 9 chiffres. | Source : Annexe 7 v1.8 G2.19</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M41"/>
   <xsl:template match="@*|node()" priority="-2" mode="M41">
      <xsl:apply-templates select="*" mode="M41"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.33a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer[CompanyId/@schemeId = ('0002','0223')]"
                 priority="1000"
                 mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer[CompanyId/@schemeId = ('0002','0223')]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="TaxRegistrationId"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="TaxRegistrationId">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.33] L'identifiant TVA de l'acheteur est obligatoire quand le type d'identifiant est 0002 ou 0223. | Source : Annexe 7 v1.8 G2.33</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.33b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/TaxRegistrationId"
                 priority="1000"
                 mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/TaxRegistrationId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@qualifyingId = 'VAT'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@qualifyingId = 'VAT'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.33] Le qualifiant de l'identifiant TVA de l'acheteur doit être VAT. | Source : Annexe 7 v1.8 G2.33</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <!--PATTERN F10-ACHETEUR-G2.01-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Buyer/PostalAddress/CountryId"
                 priority="1000"
                 mode="M44">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Buyer/PostalAddress/CountryId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{2}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.01] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit être au format ISO 3166 alpha-2 (existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G2.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <!--PATTERN F10-LIVRAISON-G1.09-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Delivery/Date"
                 priority="1000"
                 mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Delivery/Date"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de livraison doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de livraison doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <!--PATTERN F10-LIVRAISON-G2.01-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Delivery/Location/CountryId"
                 priority="1000"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Delivery/Location/CountryId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{2}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.01] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit être au format ISO 3166 alpha-2 (existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G2.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-FAC-G1.09a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/InvoicePeriod/StartDate"
                 priority="1000"
                 mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/InvoicePeriod/StartDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de début de période de facturation doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de début de période de facturation doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-FAC-G1.09b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/InvoicePeriod/EndDate"
                 priority="1000"
                 mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/InvoicePeriod/EndDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de fin de période de facturation doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de fin de période de facturation doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-FAC-G6.25-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/InvoicePeriod[StartDate and EndDate]"
                 priority="1000"
                 mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/InvoicePeriod[StartDate and EndDate]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="EndDate &gt; StartDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="EndDate &gt; StartDate">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.25] La date de fin de période de facturation ne peut pas être antérieure ou égale à la date de début. | Source : Annexe 7 v1.8 G6.25</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--PATTERN F10-REMISE-G2.31-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/AllowanceCharge/TaxCategoryCode"
                 priority="1000"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/AllowanceCharge/TaxCategoryCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('S','E','AE','K','G','O','Z')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('S','E','AE','K','G','O','Z')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.31] Le code de catégorie TVA des remises/charges doit appartenir à UNTDID 5305 (S, E, AE, K, G, O, Z). | Source : Annexe 7 v1.8 G2.31</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--PATTERN F10-REMISE-G1.24-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/AllowanceCharge/TaxPercent"
                 priority="1000"
                 mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/AllowanceCharge/TaxPercent"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.24] Le taux de TVA des remises/charges n'est pas dans la liste autorisée. | Source : Annexe 7 v1.8 G1.24</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--PATTERN F10-REMISE-G1.14-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/AllowanceCharge/Amount"
                 priority="1000"
                 mode="M52">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/AllowanceCharge/Amount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--PATTERN F10-TOTAL-G1.14a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/MonetaryTotal/TaxExclusiveAmount"
                 priority="1000"
                 mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/MonetaryTotal/TaxExclusiveAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--PATTERN F10-TOTAL-TAXAMOUNT-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/MonetaryTotal/TaxAmount"
                 priority="1000"
                 mode="M54">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/MonetaryTotal/TaxAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@CurrencyCode = 'EUR'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@CurrencyCode = 'EUR'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.23] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : le montant de TVA de la facture doit être exprimé en euros. | Source : Annexe 7 v1.8 G6.23</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--PATTERN F10-TOTAL-G1.53-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice[CurrencyCode = 'EUR']"
                 priority="1000"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice[CurrencyCode = 'EUR']"/>
      <xsl:variable name="totalHT" select="number(MonetaryTotal/TaxExclusiveAmount)"/>
      <xsl:variable name="sommeBasesHT" select="sum(TaxSubTotal/TaxableAmount)"/>
      <xsl:variable name="totalTVA" select="number(MonetaryTotal/TaxAmount)"/>
      <xsl:variable name="sommeTVA" select="sum(TaxSubTotal/TaxAmount)"/>
      <xsl:variable name="toleranceHT" select="0.01 * count(TaxSubTotal/TaxableAmount)"/>
      <xsl:variable name="toleranceTVA" select="0.01 * count(TaxSubTotal/TaxAmount)"/>
      <xsl:variable name="amountsHTValides"
                    select="every $m in (MonetaryTotal/TaxExclusiveAmount, TaxSubTotal/TaxableAmount) satisfies (matches(string($m), '^-?\d+(\.\d{1,2})?$') and string-length(translate(string($m), '.', '')) &lt;= 19)"/>
      <xsl:variable name="amountsTVAValides"
                    select="every $m in (MonetaryTotal/TaxAmount, TaxSubTotal/TaxAmount) satisfies (matches(string($m), '^-?\d+(\.\d{1,2})?$') and string-length(translate(string($m), '.', '')) &lt;= 19)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(MonetaryTotal/TaxExclusiveAmount) or not($amountsHTValides) or (abs($totalHT - $sommeBasesHT) &lt;= $toleranceHT)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(MonetaryTotal/TaxExclusiveAmount) or not($amountsHTValides) or (abs($totalHT - $sommeBasesHT) &lt;= $toleranceHT)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.53] Le montant total hors taxe (<xsl:text/>
                  <xsl:value-of select="$totalHT"/>
                  <xsl:text/>) doit être égal à la somme des bases d'imposition TVA (<xsl:text/>
                  <xsl:value-of select="$sommeBasesHT"/>
                  <xsl:text/>), avec une tolérance de 0,01 EUR par montant HT additionné. | Source : Annexe 7 v1.8 G1.53</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(MonetaryTotal/TaxAmount) or not($amountsTVAValides) or (abs($totalTVA - $sommeTVA) &lt;= $toleranceTVA)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(MonetaryTotal/TaxAmount) or not($amountsTVAValides) or (abs($totalTVA - $sommeTVA) &lt;= $toleranceTVA)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.53] Le montant total de TVA (<xsl:text/>
                  <xsl:value-of select="$totalTVA"/>
                  <xsl:text/>) doit être égal à la somme des montants de TVA par ventilation (<xsl:text/>
                  <xsl:value-of select="$sommeTVA"/>
                  <xsl:text/>), avec une tolérance de 0,01 EUR par montant TVA additionné. | Source : Annexe 7 v1.8 G1.53</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--PATTERN F10-TVA-G2.31-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxCategory/Code"
                 priority="1000"
                 mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxCategory/Code"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('S','E','AE','K','G','O','Z')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('S','E','AE','K','G','O','Z')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.31] Le code de catégorie TVA doit appartenir à UNTDID 5305 (S, E, AE, K, G, O, Z). | Source : Annexe 7 v1.8 G2.31</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--PATTERN F10-TVA-G1.24-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxCategory/Percent"
                 priority="1000"
                 mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxCategory/Percent"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.24] Le taux de TVA n'est pas dans la liste autorisée. | Source : Annexe 7 v1.8 G1.24</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--PATTERN F10-TVA-G1.40-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxSubTotal[TaxCategory/Code = 'E']"
                 priority="1000"
                 mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxSubTotal[TaxCategory/Code = 'E']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="TaxCategory/TaxExemptionReasonCode and TaxCategory/TaxExemptionReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="TaxCategory/TaxExemptionReasonCode and TaxCategory/TaxExemptionReason">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.40] Le code et le libellé du motif d'exonération sont obligatoires quand le code de catégorie TVA est "E". | Source : Annexe 7 v1.8 G1.40</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--PATTERN F10-TVA-G1.14a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxableAmount"
                 priority="1000"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxableAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--PATTERN F10-TVA-G1.14b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxAmount"
                 priority="1000"
                 mode="M60">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/TaxSubTotal/TaxAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.09a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/InvoicePeriod/StartDate"
                 priority="1000"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/InvoicePeriod/StartDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de début de période de ligne doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de début de période de ligne doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.09b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/InvoicePeriod/EndDate"
                 priority="1000"
                 mode="M62">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/InvoicePeriod/EndDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de fin de période de ligne doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de fin de période de ligne doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G6.25-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/InvoicePeriod[StartDate and EndDate]"
                 priority="1000"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/InvoicePeriod[StartDate and EndDate]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="EndDate &gt; StartDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="EndDate &gt; StartDate">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.25] La date de fin de période de ligne ne peut pas être antérieure ou égale à la date de début. | Source : Annexe 7 v1.8 G6.25</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G2.01-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/Delivery/Location/CountryId"
                 priority="1000"
                 mode="M64">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/Delivery/Location/CountryId"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{2}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G2.01] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit être au format ISO 3166 alpha-2 (existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G2.01</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.14-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/AllowanceCharge/Amount"
                 priority="1000"
                 mode="M65">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/AllowanceCharge/Amount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M65"/>
   <xsl:template match="@*|node()" priority="-2" mode="M65">
      <xsl:apply-templates select="*" mode="M65"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.15-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/BilledQuantity"
                 priority="1000"
                 mode="M66">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/BilledQuantity"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,4})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,4})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.15] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 4 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.15</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.15] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.15</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M66"/>
   <xsl:template match="@*|node()" priority="-2" mode="M66">
      <xsl:apply-templates select="*" mode="M66"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.16a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/Price/PriceAmount"
                 priority="1000"
                 mode="M67">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/Price/PriceAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d+(\.\d{1,6})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^\d+(\.\d{1,6})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 6 décimales, sans signe négatif, avec un séparateur point. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M67"/>
   <xsl:template match="@*|node()" priority="-2" mode="M67">
      <xsl:apply-templates select="*" mode="M67"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.16b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/Price/AllowanceChargeAmount"
                 priority="1000"
                 mode="M68">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/Price/AllowanceChargeAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d+(\.\d{1,6})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^\d+(\.\d{1,6})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 6 décimales, sans signe négatif, avec un séparateur point. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M68"/>
   <xsl:template match="@*|node()" priority="-2" mode="M68">
      <xsl:apply-templates select="*" mode="M68"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.16c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/Price/AllowanceChargeBaseAmount"
                 priority="1000"
                 mode="M69">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/Price/AllowanceChargeBaseAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d+(\.\d{1,6})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^\d+(\.\d{1,6})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 6 décimales, sans signe négatif, avec un séparateur point. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*" mode="M69"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.55-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/Price[PriceAmount and AllowanceChargeAmount and AllowanceChargeBaseAmount]"
                 priority="1000"
                 mode="M70">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/Price[PriceAmount and AllowanceChargeAmount and AllowanceChargeBaseAmount]"/>
      <xsl:variable name="prixValides"
                    select="every $m in (PriceAmount, AllowanceChargeAmount, AllowanceChargeBaseAmount) satisfies (matches(string($m), '^\d+(\.\d{1,6})?$') and string-length(translate(string($m), '.', '')) &lt;= 19)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($prixValides) or abs(number(PriceAmount) - (number(AllowanceChargeBaseAmount) - number(AllowanceChargeAmount))) &lt;= 0.01"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($prixValides) or abs(number(PriceAmount) - (number(AllowanceChargeBaseAmount) - number(AllowanceChargeAmount))) &lt;= 0.01">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.55] Le prix net doit être égal au prix brut diminué du rabais (tolérance 0,01). | Source : Annexe 7 v1.8 G1.55</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*" mode="M70"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.09c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/ReferencedDocument/IssueDate"
                 priority="1000"
                 mode="M71">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/ReferencedDocument/IssueDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de la facture antérieure à la ligne doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de la facture antérieure à la ligne doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*" mode="M71"/>
   </xsl:template>
   <!--PATTERN F10-LIGNE-G1.05-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/Line/ReferencedDocument/ID"
                 priority="1000"
                 mode="M72">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/Line/ReferencedDocument/ID"/>
      <xsl:variable name="v" select="string(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($v) &lt;= 35"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length($v) &lt;= 35">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure à la ligne ne peut pas dépasser 35 caractères. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with($v, ' ') or ends-with($v, ' '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(starts-with($v, ' ') or ends-with($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure à la ligne ne peut pas commencer ni terminer par un espace. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($v, '  '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure à la ligne ne peut pas contenir d'espaces consécutifs. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de la facture antérieure à la ligne contient des caractères non autorisés. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*" mode="M72"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.09-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/Date"
                 priority="1000"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/Date"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date des transactions doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date des transactions doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*" mode="M73"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.68-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/CategoryCode"
                 priority="1000"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/CategoryCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('TLB1','TPS1','TNT1','TMA1')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('TLB1','TPS1','TNT1','TMA1')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.68] La catégorie de transactions doit être TLB1, TPS1, TNT1 ou TMA1. | Source : Annexe 7 v1.8 G1.68</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*" mode="M74"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-P1.11-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxDueDateTypeCode"
                 priority="1000"
                 mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxDueDateTypeCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test=". = ('5','29','72','3','35','432')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". = ('5','29','72','3','35','432')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[P1.11] Le code d'exigibilité de la TVA doit appartenir à UNTDID 2475 (5, 29, 72) ou UNTDID 2005 (3, 35, 432). | Source : Annexe 7 v1.8 P1.11</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*" mode="M75"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.24b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxPercent"
                 priority="1000"
                 mode="M76">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxPercent"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.24] Le taux de TVA des transactions n'est pas dans la liste autorisée. | Source : Annexe 7 v1.8 G1.24</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*" mode="M76"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.14a-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxExclusiveAmount"
                 priority="1000"
                 mode="M77">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxExclusiveAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*" mode="M77"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.14b-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxTotal"
                 priority="1000"
                 mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxTotal"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*" mode="M78"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.14c-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxableAmount"
                 priority="1000"
                 mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxableAmount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*" mode="M79"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.14d-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxTotal"
                 priority="1000"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions/TaxSubtotal/TaxTotal"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^-?\d+(\.\d{1,2})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^-?\d+(\.\d{1,2})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 2 décimales avec un séparateur point. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.14] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.14</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*" mode="M80"/>
   </xsl:template>
   <!--PATTERN F10-TRANSAC-G1.53-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Transactions[TransactionsCurrency = 'EUR']"
                 priority="1000"
                 mode="M81">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Transactions[TransactionsCurrency = 'EUR']"/>
      <xsl:variable name="totalHT" select="number(TaxExclusiveAmount)"/>
      <xsl:variable name="sommeBasesHT" select="sum(TaxSubtotal/TaxableAmount)"/>
      <xsl:variable name="totalTVA" select="number(TaxTotal)"/>
      <xsl:variable name="sommeTVA" select="sum(TaxSubtotal/TaxTotal)"/>
      <xsl:variable name="toleranceHT" select="0.01 * count(TaxSubtotal/TaxableAmount)"/>
      <xsl:variable name="toleranceTVA" select="0.01 * count(TaxSubtotal/TaxTotal)"/>
      <xsl:variable name="amountsHTValides"
                    select="every $m in (TaxExclusiveAmount, TaxSubtotal/TaxableAmount) satisfies (matches(string($m), '^-?\d+(\.\d{1,2})?$') and string-length(translate(string($m), '.', '')) &lt;= 19)"/>
      <xsl:variable name="amountsTVAValides"
                    select="every $m in (TaxTotal, TaxSubtotal/TaxTotal) satisfies (matches(string($m), '^-?\d+(\.\d{1,2})?$') and string-length(translate(string($m), '.', '')) &lt;= 19)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($amountsHTValides) or abs($totalHT - $sommeBasesHT) &lt;= $toleranceHT"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($amountsHTValides) or abs($totalHT - $sommeBasesHT) &lt;= $toleranceHT">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.53] TaxExclusiveAmount (<xsl:text/>
                  <xsl:value-of select="$totalHT"/>
                  <xsl:text/>) doit être égal à la somme TaxableAmount (<xsl:text/>
                  <xsl:value-of select="$sommeBasesHT"/>
                  <xsl:text/>), avec une tolérance de 0,01 EUR par montant HT additionné. | Source : Annexe 7 v1.8 G1.53</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not($amountsTVAValides) or abs($totalTVA - $sommeTVA) &lt;= $toleranceTVA"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($amountsTVAValides) or abs($totalTVA - $sommeTVA) &lt;= $toleranceTVA">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.53] TaxTotal (<xsl:text/>
                  <xsl:value-of select="$totalTVA"/>
                  <xsl:text/>) doit être égal à la somme TaxSubtotal/TaxTotal (<xsl:text/>
                  <xsl:value-of select="$sommeTVA"/>
                  <xsl:text/>), avec une tolérance de 0,01 EUR par montant TVA additionné. | Source : Annexe 7 v1.8 G1.53</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M81"/>
   <xsl:template match="@*|node()" priority="-2" mode="M81">
      <xsl:apply-templates select="*" mode="M81"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-PMT-G1.09a-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/ReportPeriod/StartDate"
                 priority="1000"
                 mode="M82">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/ReportPeriod/StartDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de début de période de paiements doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de début de période de paiements doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M82"/>
   <xsl:template match="@*|node()" priority="-2" mode="M82">
      <xsl:apply-templates select="*" mode="M82"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-PMT-G1.09b-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/ReportPeriod/EndDate"
                 priority="1000"
                 mode="M83">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/ReportPeriod/EndDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date de fin de période de paiements doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date de fin de période de paiements doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M83"/>
   <xsl:template match="@*|node()" priority="-2" mode="M83">
      <xsl:apply-templates select="*" mode="M83"/>
   </xsl:template>
   <!--PATTERN F10-PERIODE-PMT-G6.25-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/ReportPeriod[StartDate and EndDate]"
                 priority="1000"
                 mode="M84">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/ReportPeriod[StartDate and EndDate]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="EndDate &gt; StartDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="EndDate &gt; StartDate">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.25] La date de fin de période de paiements ne peut pas être antérieure ou égale à la date de début. | Source : Annexe 7 v1.8 G6.25</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M84"/>
   <xsl:template match="@*|node()" priority="-2" mode="M84">
      <xsl:apply-templates select="*" mode="M84"/>
   </xsl:template>
   <!--PATTERN F10-PMT-FACTURE-G1.05-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/InvoiceID"
                 priority="1000"
                 mode="M85">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/InvoiceID"/>
      <xsl:variable name="v" select="string(.)"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($v) &lt;= 35"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length($v) &lt;= 35">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture dans le rapport de paiements ne peut pas dépasser 35 caractères. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(starts-with($v, ' ') or ends-with($v, ' '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(starts-with($v, ' ') or ends-with($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture dans le rapport de paiements ne peut pas commencer ni terminer par un espace. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(contains($v, '  '))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(contains($v, ' '))">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture dans le rapport de paiements ne peut pas contenir d'espaces consécutifs. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($v, '^[a-zA-Z0-9 \-\+_/]+$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.05] L'identifiant de facture dans le rapport de paiements contient des caractères non autorisés. | Source : Annexe 7 v1.8 G1.05</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M85"/>
   <xsl:template match="@*|node()" priority="-2" mode="M85">
      <xsl:apply-templates select="*" mode="M85"/>
   </xsl:template>
   <!--PATTERN F10-PMT-FACTURE-G1.09-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/IssueDate"
                 priority="1000"
                 mode="M86">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/IssueDate"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date d'émission de facture dans le rapport de paiements doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date d'émission de facture dans le rapport de paiements doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M86"/>
   <xsl:template match="@*|node()" priority="-2" mode="M86">
      <xsl:apply-templates select="*" mode="M86"/>
   </xsl:template>
   <!--PATTERN F10-PMT-ENCAISSEMENT-G1.09-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/Payment/Date"
                 priority="1000"
                 mode="M87">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/Payment/Date"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date d'encaissement doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date d'encaissement doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M87"/>
   <xsl:template match="@*|node()" priority="-2" mode="M87">
      <xsl:apply-templates select="*" mode="M87"/>
   </xsl:template>
   <!--PATTERN F10-PMT-ENCAISSEMENT-G1.24-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/Payment/SubTotals/TaxPercent"
                 priority="1000"
                 mode="M88">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/Payment/SubTotals/TaxPercent"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.24] Le taux de TVA dans le rapport de paiements n'est pas dans la liste autorisée. | Source : Annexe 7 v1.8 G1.24</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M88"/>
   <xsl:template match="@*|node()" priority="-2" mode="M88">
      <xsl:apply-templates select="*" mode="M88"/>
   </xsl:template>
   <!--PATTERN F10-PMT-ENCAISSEMENT-G6.27a-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/Payment/SubTotals[CurrencyCode]"
                 priority="1000"
                 mode="M89">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/Payment/SubTotals[CurrencyCode]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(CurrencyCode, '^[A-Z]{3}$')) or CurrencyCode = 'EUR'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(CurrencyCode, '^[A-Z]{3}$')) or CurrencyCode = 'EUR'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.27] Le montant encaissé doit être exprimé en euros. | Source : Annexe 7 v1.8 G6.27</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M89"/>
   <xsl:template match="@*|node()" priority="-2" mode="M89">
      <xsl:apply-templates select="*" mode="M89"/>
   </xsl:template>
   <!--PATTERN F10-PMT-ENCAISSEMENT-G1.16-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/Payment/SubTotals/Amount"
                 priority="1000"
                 mode="M90">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/Payment/SubTotals/Amount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d+(\.\d{1,6})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^\d+(\.\d{1,6})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 6 décimales, sans signe négatif, avec un séparateur point. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M90"/>
   <xsl:template match="@*|node()" priority="-2" mode="M90">
      <xsl:apply-templates select="*" mode="M90"/>
   </xsl:template>
   <!--PATTERN F10-PMT-AGREGE-G1.09-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Transactions/Payment/Date"
                 priority="1000"
                 mode="M91">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Transactions/Payment/Date"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d{8}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^\d{8}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.09] La date d'encaissement agrégé doit être au format AAAAMMJJ. | Source : Annexe 7 v1.8 G1.09</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(., '^\d{8}$')) or                     (number(substring(., 1, 4)) &gt;= 2000 and                      number(substring(., 1, 4)) &lt;= 2099)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(., '^\d{8}$')) or (number(substring(., 1, 4)) &gt;= 2000 and number(substring(., 1, 4)) &lt;= 2099)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.36] L'année de la date d'encaissement agrégé doit être comprise entre 2000 et 2099. | Source : Annexe 7 v1.8 G1.36</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M91"/>
   <xsl:template match="@*|node()" priority="-2" mode="M91">
      <xsl:apply-templates select="*" mode="M91"/>
   </xsl:template>
   <!--PATTERN F10-PMT-AGREGE-G1.24-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Transactions/Payment/SubTotals/TaxPercent"
                 priority="1000"
                 mode="M92">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Transactions/Payment/SubTotals/TaxPercent"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number(.) = (0, 0.9, 1.05, 1.75, 2.1, 5.5, 7, 8.5, 9.2, 9.6, 10, 13, 19.6, 20, 20.6)">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.24] Le taux de TVA de l'encaissement agrégé n'est pas dans la liste autorisée. | Source : Annexe 7 v1.8 G1.24</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M92"/>
   <xsl:template match="@*|node()" priority="-2" mode="M92">
      <xsl:apply-templates select="*" mode="M92"/>
   </xsl:template>
   <!--PATTERN F10-PMT-AGREGE-G6.27b-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Transactions/Payment/SubTotals[CurrencyCode]"
                 priority="1000"
                 mode="M93">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Transactions/Payment/SubTotals[CurrencyCode]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(matches(CurrencyCode, '^[A-Z]{3}$')) or CurrencyCode = 'EUR'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(matches(CurrencyCode, '^[A-Z]{3}$')) or CurrencyCode = 'EUR'">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G6.27] Le montant encaissé agrégé doit être exprimé en euros. | Source : Annexe 7 v1.8 G6.27</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M93"/>
   <xsl:template match="@*|node()" priority="-2" mode="M93">
      <xsl:apply-templates select="*" mode="M93"/>
   </xsl:template>
   <!--PATTERN F10-PMT-AGREGE-G1.16-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Transactions/Payment/SubTotals/Amount"
                 priority="1000"
                 mode="M94">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Transactions/Payment/SubTotals/Amount"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^\d+(\.\d{1,6})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(., '^\d+(\.\d{1,6})?$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit comporter au maximum 6 décimales, sans signe négatif, avec un séparateur point. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(translate(., '.', '')) &lt;= 19"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(translate(., '.', '')) &lt;= 19">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.16] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : ne peut pas dépasser 19 chiffres hors séparateur. | Source : Annexe 7 v1.8 G1.16</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M94"/>
   <xsl:template match="@*|node()" priority="-2" mode="M94">
      <xsl:apply-templates select="*" mode="M94"/>
   </xsl:template>
   <!--PATTERN F10-PMT-DEVISE-G1.10-->

   <!--RULE -->
   <xsl:template match="/Report/PaymentsReport/Invoice/Payment/SubTotals/CurrencyCode |                    /Report/PaymentsReport/Transactions/Payment/SubTotals/CurrencyCode"
                 priority="1000"
                 mode="M95">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/PaymentsReport/Invoice/Payment/SubTotals/CurrencyCode |                    /Report/PaymentsReport/Transactions/Payment/SubTotals/CurrencyCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{3}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.10] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit respecter le format ISO 4217 (3 lettres majuscules — existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G1.10</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M95"/>
   <xsl:template match="@*|node()" priority="-2" mode="M95">
      <xsl:apply-templates select="*" mode="M95"/>
   </xsl:template>
   <!--PATTERN F10-TX-DEVISE-G1.10-->

   <!--RULE -->
   <xsl:template match="/Report/TransactionsReport/Invoice/CurrencyCode |                    /Report/TransactionsReport/Transactions/TransactionsCurrency"
                 priority="1000"
                 mode="M96">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/Report/TransactionsReport/Invoice/CurrencyCode |                    /Report/TransactionsReport/Transactions/TransactionsCurrency"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches(., '^[A-Z]{3}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="matches(., '^[A-Z]{3}$')">
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[G1.10] <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> : doit respecter le format ISO 4217 (3 lettres majuscules — existence dans le référentiel non contrôlée). | Source : Annexe 7 v1.8 G1.10</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M96"/>
   <xsl:template match="@*|node()" priority="-2" mode="M96">
      <xsl:apply-templates select="*" mode="M96"/>
   </xsl:template>
</xsl:stylesheet>
