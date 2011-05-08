<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cce="http://cce.mitre.org">

<xsl:template match="/">
    <xsl:apply-templates
    select="cce:cce_list/cce:cces/cce:cce[@platform='rhel5']" />
</xsl:template>

<xsl:template match="cce:cce" xml:space="preserve">
# CCE-ID: <xsl:value-of select="@cce_id" />
# Orignal-platform: <xsl:value-of select="@platform"/>
# Modified: <xsl:value-of select="@modified"/>
# Description: <xsl:value-of select="cce:description" />
# Parameters: <xsl:apply-templates select="cce:parameters/cce:parameter" />
# Technical-mechanisms: <xsl:apply-templates select="cce:technical_mechanisms/cce:technical_mechanism" />
</xsl:template>

<xsl:template match="cce:parameter">
<xsl:value-of select="." />
<xsl:if test="position() != last()"><xsl:text>
#             </xsl:text></xsl:if></xsl:template>

<xsl:template match="cce:technical_mechanism">
<xsl:value-of select="." />
<xsl:if test="position() != last()"><xsl:text>
#                       </xsl:text></xsl:if></xsl:template>

</xsl:stylesheet>

