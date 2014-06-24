(:~
: Example REST API endpoints
: for data.devon.gov.uk
:
: @author Adam Retter <adam.retter@googlemail.com>
:
: @collaborator Andy Shimmel <andy.shimell@devon.gov.uk>
: @collaborator Kevin Gillick <kevin.gillick@devon.gov.uk>
: @collaborator Mark Painter <mark.painter@devon.gov.uk>
:
: @authored 2014-06-23
:)

xquery version "3.0";

module namespace data = "http://data.devon.gov.uk";

declare namespace s = "http://schemas.devon.gov.uk/Services";
declare namespace m = "http://data.devon.gov.uk/metadata";

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(:

data.devon.gov.uk
=================
Initial attempt to define a RESTful API
for data.devon.gov.uk.

In the following examples it is assumed that,
http://data.devon.gov.uk/ would be mapped to /data/,
so for example http://data.devon.gov.uk/community would
map to /data/community.

/data
/data/{$topic}

$topic is just a means of naming a collection
of related records/data. For example:

/data/finance
/data/community

/data/{$topic}/${dataset}

$dataset is the name of a dataset within
a particular topic area. For example:

/data/finance/over500
/data/community/service

Each $dataset will potentially have it's own URI
scheme and Query API. However, where possible
consideration should be given to making the 
URI schemes and Query APIs similar or common
across datasets; This then allows developers
to learn how to use one dataset and apply the
same knowledge to other datasets (where possible).

In this script we then implement an
alpha API for Community Services.


Content Manifestation
---------------------
The RESTful API should provide HTML, XML and JSON
manifestation of the data it serves.

The default representation will be HTML, whilst
the other representations will be provided through
content negotiation by means of the HTTP Accept header.

It may also be desirable to provide an RDF
representation in future or to look at adding
RDFa to the HTML representation.


Community Services RESTful API
==============================
Base Endpoint: /data/community/service

URI Endpoints:

/data/community/service
    Provides links to all available service records. When
    the representation is expressed in HTML, it may also
    be pertinent to display a search form, or paging of the
    results.

/data/community/service/id/{$id}
    The relative $id of a record, is the part that
    would come at the end of http://data.devon.gov.uk/community/service/{$id}.
    It is recommended that simple numeric identifiers are used and that
    these are further Base-32 encoded and expressed in lower-case to remove
    problems that may occur in verbal or written transcription. For example
    for record 300: http://data.devon.gov.uk/community/service/9c

/data/community/service/audience
    Provides links to audiences which are generated
    by asking for the distinct-values of the s:Audience element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme /data/community/service/audience/{$audience}.

/data/community/service/audience/{$audience}
    Provides links to records in the form of
    /data/community/service/id/{$id} that are applicable
    to a specific audience.
    The $audience is taken from the controlled vocabularly
    provided by /data/community/service/audience above.
    
/data/community/service/location
    Provides links to locations which are generated
    by asking for the distinct-values of the s:GeographicArea element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme /data/community/service/location/{$location}.
    
/data/community/service/location/{$location}
    Provides links to records in the form of
    /data/community/service/id/{$id} that are applicable
    to a specific location.
    The $location is taken from the controlled vocabularly
    provided by /data/community/service/location above.

/data/community/service/category
    Provides links to categories which are generated
    by asking for the distinct-values of the s:Category element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme /data/community/service/category/{$category}.

/data/community/service/category/{$category}
    Provides links to records in the form of
    /data/community/service/id/{$id} that are applicable
    to a specific category.
    The $category is taken from the controlled vocabularly
    provided by /data/community/service/category above.


Query parameters
----------------
All query parameters should also be expressable in lower-case in the URL.
All query parameters are optional, and should be applicable to any of the
Community Services RESTful API endpoints.

ageFrom=int
    Matched on the s:ageFrom element of the Communuty Service XML documents.

ageTo=int
    Matched on the s:ageFrom element of the Communuty Service XML documents.
    
keyword=string
    Matched on the fulltext of the s:Name and s:Descriptions element of
    the Communuty Service XML documents.

TODO
====
At present only the following are implemented for HTML, JSON and XML:
    /data
    /data/{$topic}
    /data/community/service

and for just XML:
    /data/community/service/{$id}
:)

declare
    %rest:GET
    %rest:path("/data")
    %rest:produces("text/html")
    %output:method("html5")
function data:home() {
    data:collections-html(())
};

declare
    %rest:GET
    %rest:path("/data")
    %rest:produces("application/json")
    %output:method("json")
function data:home-json() {
    data:collections(())
};

declare
    %rest:GET
    %rest:path("/data")
    %rest:produces("application/xml")
function data:home-xml() {
    data:collections(())
};

declare
    %rest:GET
    %rest:path("/data/{$topic}")
    %rest:produces("text/html")
    %output:method("html5")
function data:home($topic) {
    data:collections-html("/" || $topic)
};

declare
    %rest:GET
    %rest:path("/data/{$topic}")
    %rest:produces("application/json")
    %output:method("json")
function data:home-json($topic) {
    data:collections("/" || $topic)
};

declare
    %rest:GET
    %rest:path("/data/{$topic}")
    %rest:produces("application/xml")
function data:home-xml($topic) {
    data:collections("/" || $topic)
};

(:~
: HTML endpoint for /data/community/service
: allows optional query parameters
: of ageFrom, ageTo and keyword
: 
: Currently provides links to the first 10
: matching community services. Realy it
: could return
: all, or should offer paging.
:)
declare
    %rest:GET
    %rest:path("/data/community/service")
    %rest:query-param("ageFrom", "{$age-from}")
    %rest:query-param("ageTo", "{$age-to}")
    %rest:query-param("keyword", "{$keyword}")
    %rest:produces("text/html")
    %output:method("html5")
function data:services($age-from, $age-to, $keyword) {
    <html>
        <head><title>services</title></head>
        <body>
            <h2>Search:</h2>
            <div>
                <p>You can further refine the list below by using any or all of the fields in this search form.</p>
                <form method="get" action="service">
                    <span>Age from: <input name="ageFrom" value="{$age-from}"/></span><br/>
                    <span>Keyword: <input name="keyword" value="{$keyword}"/></span><br/>
                    <input type="submit" value="Search"/>
                </form>
            </div>
            <h2>Community Services:</h2>
            <ul>
            {
                let $data :=
                    if($age-from and $keyword)then
                        collection("/db/data/community/service")/s:Service[s:Eligibility/s:Age/s:AgeFrom/@years ge $age-from][ft:query(s:Name, $keyword)]
                    else if($keyword)then
                        collection("/db/data/community/service")/s:Service[ft:query(s:Name, $keyword)]
                    else
                        collection("/db/data/community/service")/s:Service
                return
            
                    (: limit to the first 10 results :)
                    for $service in subsequence($data, 1, 10) 
                    return
                        <li><a href="service/{replace(document-uri(root($service)), ".*/(.*)", "$1")}">{$service/s:Name/text()}</a></li>
            }
            </ul>
        </body>
    </html>
};

(:~
: XML endpoint for /data/community/service/${id}
:)
declare
    %rest:GET
    %rest:path("/data/community/service/{$id}")
function data:services($id) {
    doc("/db/data/community/service/" || $id)
};

(: ~
: Example HTML endpoint for /data/community/service/${id}
: Uses an XSLT transformation (/db/data/community/service/to-html.xslt)
: to convert the XML to HTML
:)
(:
declare
    %rest:GET
    %rest:path("/data/community/service/{$id}")
    %rest:produces("text/html")
    %output:method("html5")
function data:services-html($id) {

    let $xml := doc("/db/data/community/service/" || $id)
    let $html := transform:transform($xml, "/db/data/community/service/to-html.xslt", ())
    return
        $html
};
:)
    
(:~
: HTML browsing function which just
: lists the sub-collections of a
: collection.
:
: This function really just calls data:collections
: function below and then wraps the results in HTML
:)
declare
    %private
function data:collections-html($start) {
    <html>
        <head><title>data.devon.gov.uk</title></head>
        <body>
        {
            let $metadata := data:collections($start)
            return
            (
                <h2>{$metadata/m:name/text()}</h2>,
                <div>
                    <p>{$metadata/m:description/text()}</p>
                    <a href="{$metadata/link/@href}">{$metadata/link/string(@title)}</a>
                </div>
            )
        }
        </body>
    </html>
};

(:~
: Browsing function which just
: lists the sub-collections of a
: collection.
:)
declare
    %private
function data:collections($start) {
    
    for $collection in xmldb:get-child-collections("/db/data" || $start)
    let $current := string-join(($start, $collection), "/")
    let $metadata := doc("/db/data/" || $current || "/metadata.xml")/m:collection
    return
        <m:collection>
        {
            $metadata/(@id, m:name, m:description),
            <link href=".{$current}" title="{$metadata/string(@id)}"/>
        }
        </m:collection>
};

