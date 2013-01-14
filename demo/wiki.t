proc GetQuery {r key} {
	send [send [getf $r URL] Query] Get $key
}

proc ModeHtml {w} {
	send [send $w Header] Set "Content-Type" "text/html"
}

proc starter {w r} {
	ModeHtml $w

	/fmt/Fprintf $w "<ul>"
	/fmt/Fprintf $w {<li> <a href="/list">List Of Pages</a>}
	/fmt/Fprintf $w {<li> <a href="/">Home Page</a>}
	/fmt/Fprintf $w "<li>(xyz=( %s ))  " [GetQuery $r xyz]
	/fmt/Fprintf $w "<li>(Path=( %s ))  " [getf $r URL Path]
	/fmt/Fprintf $w "<li>(RawQuery=( %s ))  " [getf $r URL RawQuery]
	/fmt/Fprintf $w "<li>(User=( %s ))  " [getf $r URL User]
	/fmt/Fprintf $w "<li>(Host=( %s ))  " [getf $r URL Host]
	/fmt/Fprintf $w "<li>(Scheme=( %s ))  " [getf $r URL Scheme]
	/fmt/Fprintf $w "</ul>"
}

proc Home {w r} {
	starter $w $r
	Display "HomePage" $w
}

proc Display {page w} {
	set pagef "$page.wik"
	/fmt/Fprintf $w "(Display( %s ))" [/io/ioutil/ReadFile $pagef]
}

proc View {w r} {
	starter $w $r
	set page [GetQuery $r page]
	if {[catch {/io/ioutil/ReadFile "$page.wik"} junk]} {
		/fmt/Fprintf $w "Page Not Found: $page"
	} else {
		Display $page $w
	}
}

proc List {w r} {
	starter $w $r
	/fmt/Fprintf $w "<ul>"
	foreach f [/io/ioutil/ReadDir .] {
		set fname [send $f Name]
		set m [send $ValidName FindStringSubmatch $fname]
		if {[null $m]} {
			/fmt/Fprintf $w {<li> Invalid Filename: %s} $fname
		} else {
			set name [lat $m 1]
			/fmt/Fprintf $w {<li> <a href="/view?page=%s">"%s"</a> for filename %s} $name $name $fname
		}
	}
	/fmt/Fprintf $w "</ul>"
}

set ValidName [/regexp/MustCompile {^([A-Z]+[a-z]+[A-Z][A-Za-z0-9_]*)[.]wik$}]

/net/http/HandleFunc / [http_handler Home]
/net/http/HandleFunc /view [http_handler View]
/net/http/HandleFunc /list [http_handler List]

/net/http/ListenAndServe 127.0.0.1:8080 ""
