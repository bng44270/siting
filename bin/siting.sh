#!/bin/bash

BASEDIR=$(dirname $0)
CONTENTDB="$BASEDIR/../db/content.db"

sqlite_binary() {
	ls /usr/bin/sqlite* | head -n1
}

newpage() {
	while true; do
		exec 3>&1
		PAGETITLE=$(dialog --inputbox "Enter Page Title" 10 40 2>&1 1>&3)
		exec 3>&-

		LABEL=$(echo "$PAGETITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[ \t]//g')
		if [ -n "$($(sqlite_binary) $CONTENTDB 'SELECT * FROM pages WHERE label="'"$LABEL"'";')" ]; then
			dialog --msgbox "Page '$PAGETITLE' already exists" 5 30
			continue
		fi
		
		[[ -f /tmp/$LABEL ]] && rm /tmp/$LABEL
		vim /tmp/$LABEL
		CONTENT="$(cat /tmp/$LABEL | openssl enc -base64)"
		rm /tmp/$LABEL

		if [ -z "$(cat <<<$PAGEDATA | grep -v '^[ \t]*$')" ]; then
			break
		elif [ $(cat <<<$PAGEDATA | grep -v '^[ \t]*$' | wc -l) -eq 2 ]; then
			$(sqlite_binary) $CONTENTDB 'INSERT INTO pages(title,label,content) VALUES("'"$TITLE"'","'"$LABEL"'","'"$CONTENT"'");'
			break
		else
			dialog --msgbox "Please fill in all fields" 5 30
		fi 
	done
}

editpage() {
	exec 3>&1
	PAGEID=$($(sqlite_binary) $CONTENTDB 'SELECT id,label FROM pages;' | sed 's/|/ /g' | tr '\n' ' ' | dialog --menu "Select Page" 15 40 10 $(cat -) 2>&1 1>&3)
	exec 3>&-

	
	PAGELABEL=$($(sqlite_binary) $CONTENTDB 'SELECT label FROM pages WHERE id='"$PAGEID"';')
	[[ -f /tmp/$PAGELABEL ]] && rm /tmp/$PAGELABEL
	$(sqlite_binary) $CONTENTDB 'SELECT content FROM pages WHERE id='"$PAGEID"';' | openssl enc -base64 -d > /tmp/$PAGELABEL
	
	while true; do
		vim /tmp/$PAGELABEL
		PAGEDATA=$(cat /tmp/$PAGELABEL | openssl enc -base64)
		rm /tmp/$PAGELABEL

                if [ -n "$PAGEDATA" ]; then
                        $(sqlite_binary) $CONTENTDB 'UPDATE pages SET content="'"$PAGEDATA"'" WHERE id='"$PAGEID"';'
                        break
                else
                        break
                fi
        done
}

newsubpage() {
        while true; do
                exec 3>&1
		PAGETITLE=$(dialog --inputbox "Enter Page Title" 10 40 2>&1 1>&3)
                exec 3>&-

		LABEL=$(echo "$PAGETITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[ \t]//g')
                if [ -n "$($(sqlite_binary) $CONTENTDB 'SELECT * FROM pages WHERE label="'"$LABEL"'";')" ]; then
                        dialog --msgbox "Page '$PAGETITLE' already exists" 5 30
                        continue
                fi

                [[ -f /tmp/$LABEL ]] && rm /tmp/$LABEL
                vim /tmp/$LABEL
                CONTENT="$(cat /tmp/$LABEL | openssl enc -base64)"
                rm /tmp/$LABEL
                
		if [ -z "$(cat <<<$PAGEDATA | grep -v '^[ \t]*$')" ]; then
                        break
                elif [ $(cat <<<$PAGEDATA | grep -v '^[ \t]*$' | wc -l) -eq 2 ]; then
                        $(sqlite_binary) $CONTENTDB 'INSERT INTO subpages(title,label,content) VALUES("'"$TITLE"'","'"$LABEL"'","'"$CONTENT"'");'
                        break
                else
                        dialog --msgbox "Please fill in all fields" 5 30
                fi
	done
}

editsubpage() {
        exec 3>&1
        PAGEID=$($(sqlite_binary) $CONTENTDB 'SELECT id,label FROM subpages;' | sed 's/|/ /g' | tr '\n' ' ' | dialog --menu "Select Subpage" 15 40 10 $(cat -) 2>&1 1>&3)
        exec 3>&-

        PAGELABEL=$($(sqlite_binary) $CONTENTDB 'SELECT label FROM subpages WHERE id='"$PAGEID"';')
	[[ -f /tmp/$PAGELABEL ]] && rm /tmp/$PAGELABEL
        $(sqlite_binary) $CONTENTDB 'SELECT content FROM pages WHERE id='"$PAGEID"';' | openssl enc -base64 -d > /tmp/$PAGELABEL

        while true; do
		vim /tmp/$PAGELABEL
		PAGEDATA=$(cat /tmp/$PAGELABEL | openssl enc -base64)
		rm /tmp/$PAGELABEL

                if [ -n "$PAGEDATA" ]; then
                        $(sqlite_binary) $CONTENTDB 'UPDATE subpages SET content="'"$PAGEDATA"'" WHERE id='"$PAGEID"';'
                        break
                else
                        break
                fi
        done
}

selecttemplate() {
	exec 3>&1
        TEMPLATEID=$($(sqlite_binary) $CONTENTDB 'SELECT id,file FROM templates;' | sed 's/|/ /g' | tr '\n' ' ' | dialog --menu "Select Element" 15 40 10 $(cat -) 2>&1 1>&3)
        exec 3>&-

	if [ -n "$TEMPLATEID" ]; then
		$(sqlite_binary) $CONTENTDB 'UPDATE elements SET value=(SELECT file FROM templates WHERE id='"$TEMPLATEID"') WHERE name="template";'
	fi
}

editelement() {
	exec 3>&1
	ELEMID=$($(sqlite_binary) $CONTENTDB 'SELECT id,name FROM elements WHERE name <> "template";' | sed 's/|/ /g' | tr '\n' ' ' | dialog --menu "Select Element" 15 40 10 $(cat -) 2>&1 1>&3)
	exec 3>&-
	
	if [ -n "$ELEMID" ]; then
		[[ -f /tmp/$ELEMID ]] && rm /tmp/$ELEMID
		$(sqlite_binary) $CONTENTDB 'SELECT value FROM elements WHERE id='"$ELEMID"';' | openssl enc -base64 -d > /tmp/$ELEMID
		vim /tmp/$ELEMID
		NEWVAL=$(cat /tmp/$ELEMID | openssl enc -base64)
		rm /tmp/$ELEMID
	
        	$(sqlite_binary) $CONTENTDB 'UPDATE elements SET value="'"$NEWVAL"'" WHERE id='"$ELEMID"';'
	fi
}

gettemplates() {
	$(sqlite_binary) $CONTENTDB 'DELETE FROM templates WHERE 1;'

	ls $BASEDIR/../assets/*xsl | while read line; do
		TEMPFILE=$(basename $line)
                $(sqlite_binary) $CONTENTDB 'INSERT INTO templates(file) VALUES ("'"$TEMPFILE"'");'
        done
}

siteinit() {
	TITLE=$($(sqlite_binary) $CONTENTDB 'SELECT value FROM elements WHERE name="title";')
	URL=$($(sqlite_binary) $CONTENTDB 'SELECT value FROM elements WHERE name="siteurl";')
	if [ -z "$TITLE" ] || [ -z "$URL" ]; then
		while true; do
        	        exec 3>&1
	                PAGEDATA=$(dialog --ok-label "Create Site" --backtitle "Site Initialization" --form "Site Info" 15 50 0 "Title:" 1 1 "" 1 10 15 0 "URL:" 2 1 "" 2 10 1000 0 2>&1 1>&3)
	                exec 3>&-
	
	                TITLE=$(echo "$PAGEDATA" | head -n1)
	                URL=$(echo "$PAGEDATA" | head -n3 | tail -n1)
	                if [ -z "$(cat <<<$PAGEDATA | grep -v '^[ \t]*$')" ]; then
	                        break
	                elif [ $(cat <<<$PAGEDATA | grep -v '^[ \t]*$' | wc -l) -eq 2 ]; then
				$(sqlite_binary) $CONTENTDB 'UPDATE elements SET value="'"$URL"'" WHERE name="siteurl";'
				$(sqlite_binary) $CONTENTDB 'UPDATE elements SET value="'"$TITLE"'" WHERE name="title";'
	                        break
	                else
	                        dialog --msgbox "Please fill in all fields" 5 30
       		         fi
	        done
	fi
}

dbinit() {
	[[ ! -d $(dirname $CONTENTDB) ]] && mkdir $(dirname $CONTENTDB)
	if [ ! -f $CONTENTDB ]; then
		cat << HERE | $(sqlite_binary) $CONTENTDB
CREATE TABLE pages(id integer primary key autoincrement,title text, label text, content text);
CREATE TABLE subpages(id integer primary key autoincrement,title text, label text, content text);
CREATE TABLE elements(id integer primary key autoincrement,name text, value text);
CREATE TABLE templates(id integer primary key autoincrement, file text);
INSERT INTO elements(name,value) VALUES("homepage",""),("title",""),("header",""),("footer",""),("belowpage",""),("theme",""),("template",""),("siteurl","");
HERE
		gettemplates
	fi
}

# BEGIN PROGRAM
dbinit

siteinit

while true; do
	exec 3>&1
	operation=$(dialog --menu "Main Menu" 15 40 8 "1" "Create New Page" "2" "Edit Page" "3" "Create Subpage" "4" "Edit Subpage" "5" "Edit Site Element" "6" "Select Site Template" "7" "Rebuild Template List" "8" "Exit" 2>&1 1>&3)
	exec 3>&-

	case "$operation" in
		"1")
			newpage
			;;
		"2")
			editpage
			;;
		"3")
			newsubpage
			;;
		"4")
			editsubpage
			;;
		"5")
			editelement
			;;
		"6")
			selecttemplate
			;;
		"7")
			gettemplates
			;;
		"8")
			break
			;;
		*)
			break
			;;
	esac
done
