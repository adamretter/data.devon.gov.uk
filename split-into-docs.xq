xquery version "3.0";

declare namespace s = "http://schemas.devon.gov.uk/Services";

(:
: This XQuery script will:
:
: 1) Create collections
: for Community Services.
:
: 2) Create an Index Configuration
: for Community Services documents
:
: 3) Take all XML files from $source-folder
: load them into /db/in-temp collection
:
: 4) Extract each Service from documents in
: /db/in-temp and store them into their own
: documents in /db/data/community/service.
:
: 5) Remove the /db/in-temp collection.
:)

(:
: Folder on your computer containing XML document(s)
: of Community Services
:)
declare varibale $source-folder := "/Users/aretter/Desktop/dcc-consultancy"



(: creates a collection path :)
declare function local:create-collection($path as xs:string) as xs:string {
	let $segments := tokenize($path, "/")
	return
		local:create-collections($segments, ())
};

declare %private function local:create-collections($segments as xs:string*, $created as xs:string*) as xs:string {
	
	let $created-path := string-join($created, '/')
	return
		if(empty($segments))then
			$created-path
		else
			let $current := string-join(($created-path, $segments[1]), '/')
			return
				let $_ :=
					if(not(xmldb:collection-available($current)))then
						xmldb:create-collection($created-path, $segments[1])
					else()
				return
					local:create-collections(subsequence($segments, 2), ($created, $segments[1]))
	
};

(: create db and system collections :)
(
   
	local:create-collection("/db/in-temp"),
	local:create-collection("/db/data/community/service"),
	local:create-collection("/db/system/config/db/data/community/service")
),

(: load initial data document into a temporary collection :)
xmldb:store-files-from-pattern("/db/in-temp", $source-folder, "*.xml", "application/xml"),


(: create and store an index configuration for community service documents :)
let $index-conf := document {
	<collection xmlns="http://exist-db.org/collection-config/1.0">
		<index xmlns:s="http://schemas.devon.gov.uk/Services">
			<lucene>
            	<text qname="s:Description"/>
            	<text qname="s:Name"/>
				<text qname="s:Postcode"/>
        	</lucene>
			<range>
				<create qname="@id" type="xs:string"/>
            	<create qname="s:Category" type="xs:string"/>
				<create qname="s:Audience" type="xs:string"/>
				<create qname="@lat" type="xs:decimal"/>
				<create qname="@long" type="xs:decimal"/>
			</range>
		</index>
	</collection>
} return
	xmldb:store("/db/system/config/db/data/community/service", "collection.xconf", $index-conf, "application/xml")
,

(: store the individual service documents :)
for $service in collection("/db/in-temp")/s:Services/s:Service
return
    let $service-with-id :=
    return
	   xmldb:store("/db/data/community/service", (), $service-with-id)
,

(: remove our temporary collection :)
xmldb:remove("/db/in-temp")