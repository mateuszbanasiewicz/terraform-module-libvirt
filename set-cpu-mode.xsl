<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes"/>

  <!-- Kopiuj wszystko -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Usuń istniejące <cpu> -->
  <xsl:template match="cpu" />

  <!-- Dodaj nową <cpu> przed <devices> -->
  <xsl:template match="devices">
    <cpu mode="custom" match="exact" check="partial">
      <model fallback="allow">Broadwell-noTSX-IBRS</model>
    </cpu>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
