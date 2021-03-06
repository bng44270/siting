<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output />
<xsl:template match="/">
<html>
<head>
  <title><xsl:value-of select="site/title" /></title>
    <script type="text/javascript" src="assets/js/jquery-3.1.1.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $('article.page').hide();
        
        $('.navitem').click(function() {
          $('article.homepage').hide();
          $('article.page').hide();
          $("article#" + $(this).attr('id')).fadeIn();
          $(document).prop('title',$(this).text());
          $('html').animate({scrollTop:0},'fast');
        });
        
        $('.homenav').click(function() {
          $('article.page').hide();
          $('article.homepage').fadeIn();
          $(document).prop('title',$('h1#pageheader').text());
          $('html').animate({scrollTop:0},'fast');
        });

        if (location.hash == "") {
          $('a#homepage').click();
        }
        else {
          $('a' + (location.hash)).click();
        }
      });
    </script>
    <style>
      div.container {
	border-radius: 25px;
        width: 90%;
        border: 1px solid gray;
        margin: auto;
      }

      div header {
        border-top-left-radius: 25px;
        border-top-right-radius: 25px;
      }

      div footer {
        border-bottom-left-radius: 25px;
        border-bottom-right-radius: 25px;
      }

      div header, div footer {
        padding: 1em;
        color: white;
	background-color: <xsl:for-each select="site">
            <xsl:choose>
              <xsl:when test="theme='blue'">#0000dd</xsl:when>
              <xsl:when test="theme='green'">#00cc00</xsl:when>
              <xsl:when test="theme='red'">#dd0000</xsl:when>
	      <xsl:when test="theme='purple'">#800080</xsl:when>
              <xsl:when test="theme='gray'">#666666</xsl:when>
	      <xsl:otherwise><xsl:value-of select="theme" /></xsl:otherwise>
            </xsl:choose>
	  </xsl:for-each>;  
	  clear: left;
        text-align: center;
      }
      
      footer a {
      	color: white;
        text-decoration: none;      
      }
      
      footer span {
        display: inline-block;
        width: 20px;
      }

      footer p {
        font-size: 10pt;
      }

      belowpage {
        padding-top: 30px;
        display: flex;
        margin:auto;
        width: 300px;
      }

      belowpage div {
        text-align: center;
        width: 100px;
      }
      
      belowpage div a {
        text-decoration: none;
        color: #000000;
      }

      belowpage div.left {
        float: left;
      }

      belowpage div.right {
        float: right;
      }

      nav {
        float: left;
        max-width: 20%;
        margin: 0;
        padding: 1em;
      }

      nav ul {
        list-style-type: none;
        padding: 0;
      }
      
      nav ul li {
        margin:3px;
      }
   
      nav ul li:hover {
        background-color: <xsl:for-each select="site">
          <xsl:choose>
            <xsl:when test="theme='blue'">#8888dd</xsl:when>
            <xsl:when test="theme='green'">#88cc88</xsl:when>
            <xsl:when test="theme='red'">#dd8888</xsl:when>
            <xsl:when test="theme='purple'">#9370DB</xsl:when>
            <xsl:when test="theme='gray'">#999999</xsl:when>
            <xsl:otherwise><xsl:value-of select="theme" /></xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>;
      }
   
      nav ul a {
        color: #000000;
        text-decoration: none;
      }
      
      nav ul a:hover {
        color: #ffffff;
      }

      content {
        float: left;
        left: 190px;
        border-left: 0px solid gray;
        padding: 1em;
        overflow: hidden;
        width:80%;
      }
      
      article {
        display: none;
      }
      
      iframe {
        border-width: 0px;
      }

      section div.image-right {
        float: right;
      }

      section div.image-left {
        float: left;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <header>
        <h1 id="pageheader"><xsl:value-of select="site/title" /></h1>
      </header>
      <nav>
        <ul>
          <li><a href="#homepage" id="homepage" class="homenav">Home</a></li>
          <xsl:for-each select="site/page">
            <li><a>
              <xsl:attribute name="href">
                <xsl:value-of select="concat('#',label)"/>
              </xsl:attribute>
              <xsl:attribute name="id">
                <xsl:value-of select="label"/>
              </xsl:attribute>
              <xsl:attribute name="class">navitem</xsl:attribute>
              <xsl:value-of select="title" />
            </a></li>
          </xsl:for-each>
        </ul>
        <xsl:for-each select="site/subpage">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#',label)"/>
            </xsl:attribute>
            <xsl:attribute name="style">display:none;</xsl:attribute>
            <xsl:attribute name="id">
              <xsl:value-of select="label"/>
            </xsl:attribute>
            <xsl:attribute name="class">navitem</xsl:attribute>
            <xsl:value-of select="title" />
          </a>
        </xsl:for-each>
      </nav>
      <content>
        <xsl:for-each select="site/homepage">
          <article>
            <xsl:attribute name="class">homepage</xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
        <xsl:for-each select="site/page">
          <article>
            <xsl:attribute name="class">page</xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="label" /></xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
        <xsl:for-each select="site/subpage">
          <article>
            <xsl:attribute name="class">page</xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="label" /></xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
      </content>
      <xsl:copy-of select="site/footer" />
    </div>
    <xsl:copy-of select="site/belowpage" />
    <script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
         m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-50366970-3', 'auto');
      ga('send', 'pageview');

    </script>
  </body>
</html>
</xsl:template>
</xsl:stylesheet>
