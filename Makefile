contentdb=db/content.db

all: build/sitemap.xml build/site.xml
	mkdir -p build/assets/js
	cp assets/*js build/assets/js
	cp assets/$$($(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="template";') build

clean:
	rm -rf tmp
	rm -rf build

build/sitemap.xml: tmp/mapbody.m4 build
	cat tmp/mapbody.m4 sitemap.m4 | m4 | sed 's/^[ \t]*//g' | grep -v '^[ \t]*$$' > build/sitemap.xml

tmp/mapbody.m4: build/site.xml tmp/mapset.cnf
	echo "define(\`URLENTRIES',\`" > tmp/mapbody.m4
	$(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT label FROM pages;' | awk '{ printf "<url>\n<loc>'"$$(grep '^URL' tmp/mapset.cnf | sed 's/^URL //g')"'/#%s</loc>\n<lastmod>'"$$(grep '^MOD' tmp/mapset.cnf | sed 's/^MOD //g')"'</lastmod>\n<changefreq>weekly</changefreq>\n<priority>0.6</priority>\n</url>\n",$$1 }' >> tmp/mapbody.m4
	echo "')" >> tmp/mapbody.m4

tmp/mapset.cnf:
	echo "MOD $$(date -u -d "$$(stat ../site.xml | grep '^Modify' | sed 's/^Modify: //g;s/\.[0-9]*//g')" +"%Y-%m-%dT%H:%M:%S+00:00")" > tmp/mapset.cnf
	echo "URL $$(read -p 'Enter site URL (omit trailing slash): ' siteurl ; echo $$siteurl)" >> tmp/mapset.cnf
	

build/site.xml: tmp/pages.m4 tmp/top.m4 tmp/bottom.m4 build
	cat tmp/pages.m4 tmp/top.m4 tmp/bottom.m4 site.m4 | m4 > build/site.xml

tmp/pages.m4: $(contentdb) tmp
	echo "define(\`PAGEOBJECTS',\`" > tmp/pages.m4
	printf "<homepage>\n<section>\n" >> tmp/pages.m4
	$(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="homepage";' | openssl enc -base64 -d >> tmp/pages.m4
	printf "\n</section>\n</homepage>" >> tmp/pages.m4
	$(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT title,label FROM pages;' | awk 'BEGIN { FS="|" } { printf "<page>\n<title>%s</title>\n<label>%s</label>\n",$$1,$$2, }' >> tmp/pages.m4
	$(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) '
	$(shell ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT title,label,content FROM subpages;' | awk 'BEGIN { FS="|" } { printf "<page>\n<title>%s</title>\n<label>%s</label>\n<section>\n%s\n</section>\n</page>\n",$$1,$$2,$$3 }' >> tmp/pages.m4
	echo "')" >> tmp/pages.m4

tmp/top.m4: $(contentdb) tmp
	echo "define(\`STYLESHEET',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="template";')')" > tmp/top.m4
	echo "define(\`SITETITLE',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="title";')')" >> tmp/top.m4
	echo "define(\`HEADERTEXT',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="header";')')" >> tmp/top.m4
	echo "define(\`THEME',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="theme";')')" >> tmp/top.m4

tmp/bottom.m4: $(contentdb) tmp
	echo "define(\`FOOTERHTML',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="footer";')')" > tmp/bottom.m4
	echo "define(\`BELOWPAGEHTML',\`$$($$(ls /usr/bin/sqlite* | head -n1) $(contentdb) 'SELECT value FROM elements WHERE name="belowpage";')')" >> tmp/bottom.m4

tmp:
	mkdir tmp

build:
	mkdir build
