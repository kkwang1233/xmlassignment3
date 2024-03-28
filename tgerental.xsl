<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:my="http://example.com/my-functions"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">
   <xsl:variable name="customersDoc" select="doc('tgecustomers.xml')" />
   <xsl:variable name="toolsDoc" select="doc('tgetools.xml')" />
   <xsl:output method="html" encoding="UTF-8" indent="yes"/>
   <xsl:template match="/">
      <html>
         <head>
            <title>The Good Earth Rentals</title>
            <link rel="icon" href="icon.png"/>
            <link href="tgestyles.css" rel="stylesheet" type="text/css" />
         </head>
         <body>
            <div id="wrap">
               <header>
                  <img src="tgelogo.png" id="logo" alt="Good Earth Rentals" />
                  <hr></hr>
               </header>
               <h1>Current Rentals</h1>
               <xsl:for-each-group select="rentals/rental" group-by="Start_Date">
                  <xsl:sort select="Start_Date"/>
                  <xsl:variable name="startDateFormat" select="format-date(current-grouping-key(), '[MNn] [D], [Y]')" />
                  <h2 id="datelabel">
                     <xsl:value-of select="$startDateFormat"/>
                  </h2>
                  <table class="head">
                     <tr>
                        <th id="customer">Customer</th>
                        <th id="toolID">Tool ID</th>
                        <th id="tool">Tool</th>
                        <th id="category">Category</th>
                        <th id="due">Due Back</th>
                        <th id="charge">Charge</th>
                     </tr>
                     <xsl:apply-templates select="current-group()"/>
                  </table>

               </xsl:for-each-group>

            </div>
         </body>
      </html>
   </xsl:template>
   <xsl:template match="rental">
      <xsl:variable name="customerID" select="Customer"/>
      <xsl:variable name="toolID" select="Tool"/>
      <xsl:variable name="cust" select="$customersDoc/customers/customer[@custID = $customerID]" />
      <xsl:variable name="custName" select="$cust/concat(firstName, ' ', lastName)" />
      <xsl:variable name="custAddr1" select="$cust/street" />
      <xsl:variable name="custAddr2" select="$cust/concat(city, ', ', state, ' ', ZIP)" />
      <xsl:variable name="tool" select="$toolsDoc/equipment/tool[@toolID = $toolID]" />
      <xsl:variable name="toolDailyRate" select="$tool/dailyRate" />
      <xsl:variable name="toolWeeklyRate" select="$tool/weeklyRate" />
      <tr>
         <td>
            <xsl:value-of select="$custName"/>
            <br></br>
            <xsl:value-of select="$custAddr1"/>
            <br></br>
            <xsl:value-of select="$custAddr2"/>
         </td>
         <td>
            <xsl:value-of select="Tool"/>
         </td>
         <td>
            <xsl:value-of select="$tool/description"/>
         </td>
         <td>
            <xsl:value-of select="$tool/category"/>
         </td>
         <td>
            <xsl:value-of select="my:due(Days, Weeks, xs:date(Start_Date))"/>
         </td>
         <td>
            <xsl:value-of select="my:cost(Days, Weeks, $toolDailyRate, $toolWeeklyRate)"/>
         </td>
      </tr>
   </xsl:template>
   <xsl:function name="my:cost" as="xs:string">
      <xsl:param name="d" as="xs:integer"/>
      <xsl:param name="w" as="xs:integer"/>
      <xsl:param name="dRate" as="xs:integer"/>
      <xsl:param name="wRate" as="xs:integer"/>
      <xsl:variable name="calcCost" select="$d * $dRate + $w * $wRate" />
      <xsl:sequence select="concat('$', $calcCost)"/>
   </xsl:function>
   <xsl:function name="my:due" as="xs:string">
      <xsl:param name="rentalDays" as="xs:integer"/>
      <xsl:param name="rentalWeeks" as="xs:integer"/>
      <xsl:param name="rentalStart" as="xs:date"/>
      <xsl:variable name="dueDays" select="$rentalDays + $rentalWeeks * 7"/>
      <xsl:variable name="dueDate" select="$rentalStart + xs:dayTimeDuration(concat('P', $dueDays, 'D'))"/>
      <xsl:variable name="dueDateFormat" select="format-date($dueDate, '[MNn] [D], [Y]')" />
      <xsl:sequence select="$dueDateFormat"/>
   </xsl:function>
</xsl:stylesheet>